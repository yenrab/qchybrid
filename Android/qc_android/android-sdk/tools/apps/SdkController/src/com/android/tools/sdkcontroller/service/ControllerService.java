/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package com.android.tools.sdkcontroller.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import com.android.tools.sdkcontroller.R;
import com.android.tools.sdkcontroller.activities.MainActivity;
import com.android.tools.sdkcontroller.handlers.BaseHandler;
import com.android.tools.sdkcontroller.handlers.BaseHandler.HandlerType;
import com.android.tools.sdkcontroller.handlers.MultiTouchHandler;
import com.android.tools.sdkcontroller.handlers.SensorsHandler;
import com.android.tools.sdkcontroller.lib.EmulatorConnection;
import com.android.tools.sdkcontroller.lib.EmulatorConnection.EmulatorConnectionType;
import com.android.tools.sdkcontroller.lib.EmulatorListener;

/**
 * The background service of the SdkController.
 * There can be only one instance of this.
 * <p/>
 * The service manages a number of action "handlers" which can be seen as individual tasks
 * that the user might want to accomplish, for example "sending sensor data to the emulator"
 * or "sending multi-touch data and displaying an emulator screen".
 * <p/>
 * Each handler currently has its own emulator connection associated to it (cf class
 * {@code EmuCnxHandler} below. However our goal is to later move to a single connection channel
 * with all data multiplexed on top of it.
 * <p/>
 * All the handlers are created when the service starts, and whether the emulator connection
 * is successful or not, and whether there's any UI to control it. It's up to the handlers
 * to deal with these specific details. <br/>
 * For example the {@link SensorsHandler} initializes its sensor list as soon as created
 * and then tries to send data as soon as there's an emulator connection.
 * On the other hand the {@link MultiTouchHandler} lays dormant till there's an UI interacting
 * with it.
 */
public class ControllerService extends Service {

    /*
     * Implementation reference:
     * http://developer.android.com/reference/android/app/Service.html#LocalServiceSample
     */

    public static String TAG = ControllerService.class.getSimpleName();
    private static boolean DEBUG = true;

    /** Identifier for the notification. */
    private static int NOTIF_ID = 'S' << 24 + 'd' << 16 + 'k' << 8 + 'C' << 0;

    private final IBinder mBinder = new ControllerBinder();

    private List<ControllerListener> mListeners = new ArrayList<ControllerListener>();

    /**
     * Whether the service is running. Set to true in onCreate, false in onDestroy.
     */
    private static volatile boolean gServiceIsRunning = false;

    /** Internal error reported by the service. */
    private String mServiceError = "";

    private final Set<EmuCnxHandler> mHandlers = new HashSet<ControllerService.EmuCnxHandler>();

    /**
     * Interface that the service uses to notify binded activities.
     * <p/>
     * As a design rule, implementations of this listener should be aware that most calls
     * will NOT happen on the UI thread. Any access to the UI should be properly protected
     * by using {@link Activity#runOnUiThread(Runnable)}.
     */
    public interface ControllerListener {
        /**
         * The error string reported by the service has changed. <br/>
         * Note this may be called from a thread different than the UI thread.
         */
        void onErrorChanged();

        /**
         * The service status has changed (emulator connected/disconnected.)
         */
        void onStatusChanged();
    }

    /** Interface that callers can use to access the service. */
    public class ControllerBinder extends Binder {

        /**
         * Adds a new listener that will be notified when the service state changes.
         *
         * @param listener A non-null listener. Ignored if already listed.
         */
        public void addControllerListener(ControllerListener listener) {
            assert listener != null;
            if (listener != null) {
                synchronized(mListeners) {
                    if (!mListeners.contains(listener)) {
                        mListeners.add(listener);
                    }
                }
            }
        }

        /**
         * Removes a listener.
         *
         * @param listener A listener to remove. Can be null.
         */
        public void removeControllerListener(ControllerListener listener) {
            assert listener != null;
            synchronized(mListeners) {
                mListeners.remove(listener);
            }
        }

        /**
         * Returns the error string accumulated by the service.
         * Typically these would relate to failures to establish the communication
         * channel(s) with the emulator, or unexpected disconnections.
         */
        public String getServiceError() {
            return mServiceError;
        }

        /**
         * Indicates when <em>all</all> the communication channels for all handlers
         * are properly connected.
         *
         * @return True if all the handler's communication channels are connected.
         */
        public boolean isEmuConnected() {
            for (EmuCnxHandler handler : mHandlers) {
                if (!handler.isConnected()) {
                    return false;
                }
            }
            return true;
        }

        /**
         * Returns the handler for the given type.
         *
         * @param type One of the {@link HandlerType}s. Must not be null.
         * @return Null if the type is not found, otherwise the handler's unique instance.
         */
        public BaseHandler getHandler(HandlerType type) {
            for (EmuCnxHandler handler : mHandlers) {
                BaseHandler h = handler.getHandler();
                if (h.getType() == type) {
                    return h;
                }
            }
            return null;
        }
    }

    /**
     * Whether the service is running. Set to true in onCreate, false in onDestroy.
     */
    public static boolean isServiceIsRunning() {
        return gServiceIsRunning;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (DEBUG) Log.d(TAG, "Service onCreate");
        gServiceIsRunning = true;
        showNotification();
        onServiceStarted();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // We want this service to continue running until it is explicitly
        // stopped, so return sticky.
        if (DEBUG) Log.d(TAG, "Service onStartCommand");
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        if (DEBUG) Log.d(TAG, "Service onBind");
        return mBinder;
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.d(TAG, "Service onDestroy");
        gServiceIsRunning = false;
        removeNotification();
        resetError();
        onServiceStopped();
        super.onDestroy();
    }

    // ------

    /**
     * Wrapper that associates one {@link EmulatorConnection} with
     * one {@link BaseHandler}. Ideally we would not need this if all
     * the action handlers were using the same port, so this wrapper
     * is just temporary.
     */
    private class EmuCnxHandler implements EmulatorListener {

        private EmulatorConnection mCnx;
        private boolean mConnected;
        private final BaseHandler mHandler;

        public EmuCnxHandler(BaseHandler handler) {
            mHandler = handler;
        }

        @Override
        public void onEmulatorConnected() {
            mConnected = true;
            notifyStatusChanged();
        }

        @Override
        public void onEmulatorDisconnected() {
            mConnected = false;
            notifyStatusChanged();
        }

        @Override
        public String onEmulatorQuery(String query, String param) {
            if (DEBUG) Log.d(TAG, mHandler.getType().toString() +  " Query " + query);
            return mHandler.onEmulatorQuery(query, param);
        }

        @Override
        public String onEmulatorBlobQuery(byte[] array) {
            if (DEBUG) Log.d(TAG, mHandler.getType().toString() +  " BlobQuery " + array.length);
            return mHandler.onEmulatorBlobQuery(array);
        }

        EmuCnxHandler connect() {
            assert mCnx == null;

            mCnx = new EmulatorConnection(this);

            // Apps targeting Honeycomb SDK can't do network IO on their main UI
            // thread. So just start the connection from a thread.
            Thread t = new Thread(new Runnable() {
                @Override
                public void run() {
                    // This will call onEmulatorBindResult with the result.
                    mCnx.connect(mHandler.getPort(), EmulatorConnectionType.SYNC_CONNECTION);
                }
            }, "EmuCnxH.connect-" + mHandler.getType().toString());
            t.start();

            return this;
        }

        @Override
        public void onEmulatorBindResult(boolean success, Exception e) {
            if (success) {
                mHandler.onStart(mCnx, ControllerService.this /*context*/);
            } else {
                Log.e(TAG, "EmuCnx failed for " + mHandler.getType(), e);
                String msg = mHandler.getType().toString() + " failed: " +
                    (e == null ? "n/a" : e.toString());
                addError(msg);
            }
        }

        void disconnect() {
            if (mCnx != null) {
                mHandler.onStop();
                mCnx.disconnect();
                mCnx = null;
            }
        }

        boolean isConnected() {
            return mConnected;
        }

        public BaseHandler getHandler() {
            return mHandler;
        }
    }

    private void disconnectAll() {
        for(EmuCnxHandler handler : mHandlers) {
            handler.disconnect();
        }
        mHandlers.clear();
    }

    /**
     * Called when the service has been created.
     */
    private void onServiceStarted() {
        try {
            disconnectAll();

            assert mHandlers.isEmpty();
            mHandlers.add(new EmuCnxHandler(new MultiTouchHandler()).connect());
            mHandlers.add(new EmuCnxHandler(new SensorsHandler()).connect());
        } catch (Exception e) {
            addError("Connection failed: " + e.toString());
        }
    }

    /**
     * Called when the service is being destroyed.
     */
    private void onServiceStopped() {
        disconnectAll();
    }

    private void notifyErrorChanged() {
        synchronized(mListeners) {
            for (ControllerListener listener : mListeners) {
                listener.onErrorChanged();
            }
        }
    }

    private void notifyStatusChanged() {
        synchronized(mListeners) {
            for (ControllerListener listener : mListeners) {
                listener.onStatusChanged();
            }
        }
    }

    /**
     * Resets the error string and notify listeners.
     */
    private void resetError() {
        mServiceError = "";

        notifyErrorChanged();
    }

    /**
     * An internal utility method to add a line to the error string and notify listeners.
     * @param error A non-null non-empty error line. \n will be added automatically.
     */
    private void addError(String error) {
        Log.e(TAG, error);
        if (mServiceError.length() > 0) {
            mServiceError += "\n";
        }
        mServiceError += error;

        notifyErrorChanged();
    }

    /**
     * Displays a notification showing that the service is running.
     * When the user touches the notification, it opens the main activity
     * which allows the user to stop this service.
     */
    @SuppressWarnings("deprecated")
    private void showNotification() {
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        String text = getString(R.string.service_notif_title);

        // Note: Notification is marked as deprecated -- in API 11+ there's a new Builder class
        // but we need to have API 7 compatibility so we ignore that warning.

        Notification n = new Notification(R.drawable.ic_launcher, text, System.currentTimeMillis());
        n.flags |= Notification.FLAG_ONGOING_EVENT | Notification.FLAG_NO_CLEAR;
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pi = PendingIntent.getActivity(
                this,     //context
                0,        //requestCode
                intent,   //intent
                0         // pending intent flags
                );
        n.setLatestEventInfo(this, text, text, pi);

        nm.notify(NOTIF_ID, n);
    }

    private void removeNotification() {
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.cancel(NOTIF_ID);
    }
}
