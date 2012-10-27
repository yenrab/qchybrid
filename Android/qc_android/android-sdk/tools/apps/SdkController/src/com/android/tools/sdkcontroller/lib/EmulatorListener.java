/*
 * Copyright (C) 2011 The Android Open Source Project
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

package com.android.tools.sdkcontroller.lib;


/**
 * Encapsulates a listener to emulator events. An object implementing this
 * interface must be registered with the EmulatorConnection instance via
 * setEmulatorListener method of the EmulatorConnection class.
 */
public interface EmulatorListener {

    /**
     * Called as a side effect of constructing a new {@link EmulatorConnection} to
     * indicate whether the when emulator is bound with its communication socket.
     *
     * @param success True if the socket bind was successful.
     *   False when the socket bind failed.
     * @param e Any exception thrown whilst trying to bind to the communication socket.
     *   Null if there's no exception (typically when {@code success==true}).
     */
    public void onEmulatorBindResult(boolean success, Exception e);

    /**
     * Called when emulator is connected. NOTE: This method is called from the
     * I/O loop, so all communication with the emulator will be "on hold" until
     * this method returns.
     */
    public void onEmulatorConnected();

    /**
     * Called when emulator is disconnected. NOTE: This method could be called
     * from the I/O loop, in which case all communication with the emulator will
     * be "on hold" until this method returns.
     */
    public void onEmulatorDisconnected();

    /**
     * Called when a query is received from the emulator. NOTE: This method is
     * called from the I/O loop, so all communication with the emulator will be
     * "on hold" until this method returns.
     *
     * @param query Name of the query received from the emulator.
     * @param param Query parameters.
     * @return Zero-terminated reply string. If not an empty string is returned,
     *         it must be formatted as such: "ok|ko[:reply data]"
     */
    public String onEmulatorQuery(String query, String param);

    /**
     * Called when a BLOB query is received from the emulator. NOTE: This method
     * is called from the I/O loop, so all communication with the emulator will
     * be "on hold" until this method returns.
     *
     * @param array contains BLOB data for the query.
     * @return Zero-terminated reply string. If not an empty string is returned,
     *         it must be formatted as such: "ok|ko[:reply data]"
     */
    public String onEmulatorBlobQuery(byte[] array);
}
