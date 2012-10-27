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

package com.android.tools.sdkcontroller.handlers;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

import android.content.Context;
import android.os.Message;
import android.util.Log;

import com.android.tools.sdkcontroller.lib.EmulatorConnection;
import com.android.tools.sdkcontroller.lib.EmulatorListener;
import com.android.tools.sdkcontroller.service.ControllerService;


/**
 * An abstract base class for all "action handlers".
 * <p/>
 * The {@link ControllerService} can deal with several handlers, each have a specific
 * purpose as described by {@link HandlerType}.
 * <p/>
 * The {@link BaseHandler} class adds support for activities to connect by providing
 * an {@link android.os.Handler} (which we'll call a "UI Handler" to differentiate it
 * from our "Service Handler"). The service handler will provide events via this
 * UI handler directly on the activity's UI thread.
 * <p/>
 * The {@link BaseHandler} keeps track of the current {@link EmulatorConnection} given
 * via {@link #onStart(EmulatorConnection, Context)}.
 * <p/>
 * The {@link BaseHandler} provides a simple way for activities to send event messages
 * back to the emulator by using {@link #sendEventToEmulator(String)}. This method
 * is safe to call from any thread, even the UI thread.
 */
public abstract class BaseHandler {

    protected static final boolean DEBUG = false;
    protected static final String TAG = null;

    private EmulatorConnection mConnection;

    private final AtomicInteger mEventCount = new AtomicInteger(0);
    private volatile boolean mRunEventQueue = true;
    private final BlockingQueue<String> mEventQueue = new LinkedBlockingQueue<String>();
    private static String EVENT_QUEUE_END = "@end@";
    private final List<android.os.Handler> mUiHandlers = new ArrayList<android.os.Handler>();
    private final HandlerType mHandlerType;
    private final Thread mEventThread;
    private int mPort;

    /**
     * The type of action that this handler manages.
     */
    public enum HandlerType {
        /** A handler to send multitouch events from the device to the emulator and display
         *  the emulator screen on the device. */
        MultiTouch,
        /** A handler to send sensor events from the device to the emulaotr. */
        Sensor
    }

    /**
     * Initializes a new base handler.
     *
     * @param type A non-null {@link HandlerType} value.
     * @param port A non-null communication port number.
     */
    protected BaseHandler(HandlerType type, int port) {
        mHandlerType = type;
        mPort = port;

        final String name = type.toString();
        mEventThread = new Thread(new Runnable() {
            @Override
            public void run() {
                if (DEBUG) Log.d(TAG, "EventThread.started-" + name);
                while(mRunEventQueue) {
                    try {
                        String msg = mEventQueue.take();
                        if (msg != null && mConnection != null && !msg.equals(EVENT_QUEUE_END)) {
                            mConnection.sendNotification(msg);
                            mEventCount.incrementAndGet();
                        }
                    } catch (InterruptedException e) {
                        Log.e(TAG, "EventThread-" + name, e);
                    }
                }
                if (DEBUG) Log.d(TAG, "EventThread.terminate-" + name);
            }
        }, "EventThread-" + name);
    }

    /**
     * Returns the type of this handler, as given to the constructor.
     *
     * @return One of the {@link HandlerType} values.
     */
    public HandlerType getType() {
        return mHandlerType;
    }

    /**
     * Returns he communication port used by this handler to communicate with the emulator,
     * as given to the constructor.
     * <p/>
     * Note that right now we have 2 handlers that each use their own port. The goal is
     * to move to a single-connection mechanism where all the handlers' data will be
     * multiplexed on top of a single {@link EmulatorConnection}.
     *
     * @return A non-null port value.
     */
    public int getPort() {
        return mPort;
    }

    /**
     * Returns the last {@link EmulatorConnection} passed to
     * {@link #onStart(EmulatorConnection, Context)}.
     * It becomes null when {@link #onStop()} is called.
     *
     * @return The current {@link EmulatorConnection}.
     */
    public EmulatorConnection getConnection() {
        return mConnection;
    }

    /**
     * Called once the {@link EmulatorConnection} has been successfully initialized.
     * <p/>
     * Note that this will <em>not</em> be called if the {@link EmulatorConnection}
     * fails to bind to the underlying socket.
     * <p/>
     * This base implementation keeps tracks of the connection.
     *
     * @param connection The connection that has just been created.
     *   A handler might want to use this to send data to the emulator via
     *   {@link EmulatorConnection#sendNotification(String)}. However handlers
     *   need to be particularly careful in <em>not</em> sending network data
     *   from the main UI thread.
     * @param context The controller service' context.
     * @see #getConnection()
     */
    public void onStart(EmulatorConnection connection, Context context) {
        assert connection != null;
        mConnection = connection;
        mRunEventQueue = true;
        mEventThread.start();
    }

    /**
     * Called once the {@link EmulatorConnection} is being disconnected.
     * This nullifies the connection returned by {@link #getConnection()}.
     */
    public void onStop() {
        // Stop the message queue
        mConnection = null;
        if (mRunEventQueue) {
            mRunEventQueue = false;
            mEventQueue.offer(EVENT_QUEUE_END);
        }
    }

    public int getEventSentCount() {
        return mEventCount.get();
    }

    /**
     * Utility for handlers or activities to sends a string event to the emulator.
     * This method is safe for the activity to call from any thread, including the UI thread.
     *
     * @param msg Event message. Must not be null.
     */
    public void sendEventToEmulator(String msg) {
        try {
            mEventQueue.put(msg);
        } catch (InterruptedException e) {
            Log.e(TAG, "EventQueue.put", e);
        }
    }

    // ------------
    // Interaction from the emulator connection towards the handler

    /**
     * Emulator query being forwarded to the handler.
     *
     * @see EmulatorListener#onEmulatorQuery(String, String)
     */
    public abstract String onEmulatorQuery(String query, String param);

    /**
     * Emulator blob query being forwarded to the handler.
     *
     * @see EmulatorListener#onEmulatorBlobQuery(byte[])
     */
    public abstract String onEmulatorBlobQuery(byte[] array);

    // ------------
    // Interaction from handler towards listening UI

    /**
     * Indicates any UI handler is currently registered with the handler.
     * If no UI is displaying the handler's state, maybe the handler can skip UI related tasks.
     *
     * @return True if there's at least one UI handler registered.
     */
    public boolean hasUiHandler() {
        return !mUiHandlers.isEmpty();
    }

    /**
     * Registers a new UI handler.
     *
     * @param uiHandler A non-null UI handler to register.
     *   Ignored if the UI handler is null or already registered.
     */
    public void addUiHandler(android.os.Handler uiHandler) {
        assert uiHandler != null;
        if (uiHandler != null) {
            if (!mUiHandlers.contains(uiHandler)) {
                mUiHandlers.add(uiHandler);
            }
        }
    }

    /**
     * Unregisters an UI handler.
     *
     * @param uiHandler A non-null UI listener to unregister.
     *   Ignored if the listener is null or already registered.
     */
    public void removeUiHandler(android.os.Handler uiHandler) {
        assert uiHandler != null;
        mUiHandlers.remove(uiHandler);
    }

    /**
     * Protected method to be used by handlers to send an event to all UI handlers.
     *
     * @param event An integer event code with no specific parameters.
     *   To be defined by the handler itself.
     */
    protected void notifyUiHandlers(int event) {
        for (android.os.Handler uiHandler : mUiHandlers) {
            uiHandler.sendEmptyMessage(event);
        }
    }

    /**
     * Protected method to be used by handlers to send an event to all UI handlers.
     *
     * @param msg An event with parameters. To be defined by the handler itself.
     */
    protected void notifyUiHandlers(Message msg) {
        for (android.os.Handler uiHandler : mUiHandlers) {
            uiHandler.sendMessage(msg);
        }
    }

}
