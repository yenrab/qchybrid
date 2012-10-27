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

import android.content.Context;
import android.graphics.Point;
import android.os.Message;
import android.util.Log;

import com.android.tools.sdkcontroller.lib.EmulatorConnection;


public class MultiTouchHandler extends BaseHandler {

    @SuppressWarnings("hiding")
    private static final String TAG = MultiTouchHandler.class.getSimpleName();
    /**
     * A new frame buffer has been received from the emulator.
     * Parameter {@code obj} is a {@code byte[] array} containing the screen data.
     */
    public static final int EVENT_FRAME_BUFFER = 1;
    /**
     * A multi-touch "start" command has been received from the emulator.
     * Parameter {@code obj} is the string parameter from the start command.
     */
    public static final int EVENT_MT_START = 2;
    /**
     * A multi-touch "stop" command has been received from the emulator.
     * There is no {@code obj} parameter associated.
     */
    public static final int EVENT_MT_STOP = 3;

    private static final Point mViewSize = new Point(0, 0);

    public MultiTouchHandler() {
        super(HandlerType.MultiTouch, EmulatorConnection.MULTITOUCH_PORT);
    }

    public void setViewSize(int width, int height) {
        mViewSize.set(width, height);
    }

    @Override
    public void onStart(EmulatorConnection connection, Context context) {
        super.onStart(connection, context);
    }

    @Override
    public void onStop() {
        super.onStop();
    }

    /**
     * Called when a query is received from the emulator. NOTE: This method is
     * called from the I/O loop.
     *
     * @param query Name of the query received from the emulator. The allowed
     *            queries are: - 'start' - Starts delivering touch screen events
     *            to the emulator. - 'stop' - Stops delivering touch screen
     *            events to the emulator.
     * @param param Query parameters.
     * @return Zero-terminated reply string. String must be formatted as such:
     *         "ok|ko[:reply data]"
     */
    @Override
    public String onEmulatorQuery(String query, String param) {
        if (query.contentEquals("start")) {
            Message msg = Message.obtain();
            msg.what = EVENT_MT_START;
            msg.obj = param;
            notifyUiHandlers(msg);
            return "ok:" + mViewSize.x + "x" + mViewSize.y + "\0";

        } else if (query.contentEquals("stop")) {
            notifyUiHandlers(EVENT_MT_STOP);
            return "ok\0";

        } else {
            Log.e(TAG, "Unknown query " + query + "(" + param + ")");
            return "ko:Unknown query\0";
        }
    }

    /**
     * Called when a BLOB query is received from the emulator.
     * <p/>
     * This query is used to deliver framebuffer updates in the emulator. The
     * blob contains an update header, followed by the bitmap containing updated
     * rectangle. The header is defined as MTFrameHeader structure in
     * external/qemu/android/multitouch-port.h
     * <p/>
     * NOTE: This method is called from the I/O loop, so all communication with
     * the emulator will be "on hold" until this method returns.
     *
     * @param array contains BLOB data for the query.
     * @return Empty string: this query doesn't require any response.
     */
    @Override
    public String onEmulatorBlobQuery(byte[] array) {
        Message msg = Message.obtain();
        msg.what = EVENT_FRAME_BUFFER;
        msg.obj = array;
        notifyUiHandlers(msg);
        return "";
    }

}
