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

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.ClosedSelectorException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.channels.spi.SelectorProvider;
import java.util.Iterator;
import java.util.Set;
import java.util.Vector;

import android.util.Log;

/**
 * Encapsulates a connection with the emulator. The connection is established
 * over a TCP port forwarding enabled with 'adb forward' command.
 * <p/>
 * Communication with the emulator is performed via two socket channels
 * connected to the forwarded TCP port. One channel is a query channel that is
 * intended solely for receiving queries from the emulator. Another channel is
 * an event channel that is intended for sending notification messages (events)
 * to the emulator.
 * <p/>
 * EmulatorConnection is considered to be "connected" when both channels are connected.
 * EmulatorConnection is considered to be "disconnected" when connection with any of the
 * channels is lost.
 * <p/>
 * Instance of this class is operational only for a single connection with the
 * emulator. Once connection is established and then lost, a new instance of
 * this class must be created to establish new connection.
 * <p/>
 * Note that connection with the device over TCP port forwarding is extremely
 * fragile at the moment. For whatever reason the connection is even more
 * fragile if device uses asynchronous sockets (based on java.nio API). So, to
 * address this issue EmulatorConnection class implements two types of connections. One is
 * using synchronous sockets, and another is using asynchronous sockets. The
 * type of connection is selected when EmulatorConnection instance is created (see
 * comments to EmulatorConnection's constructor).
 * <p/>
 * According to the exchange protocol with the emulator, queries, responses to
 * the queries, and notification messages are all zero-terminated strings.
 */
public class EmulatorConnection {
    /** Defines connection types supported by the EmulatorConnection class. */
    public enum EmulatorConnectionType {
        /** Use asynchronous connection (based on java.nio API). */
        ASYNC_CONNECTION,
        /** Use synchronous connection (based on synchronous Socket objects). */
        SYNC_CONNECTION,
    }

    /** TCP port reserved for the sensors emulation. */
    public static final int SENSORS_PORT = 1968;
    /** TCP port reserved for the multitouch emulation. */
    public static final int MULTITOUCH_PORT = 1969;
    /** Tag for logging messages. */
    private static final String TAG = "EmulatorConnection";
    /** EmulatorConnection events listener. */
    private EmulatorListener mListener;
    /** I/O selector (looper). */
    private Selector mSelector;
    /** Server socket channel. */
    private ServerSocketChannel mServerSocket;
    /** Query channel. */
    private EmulatorChannel mQueryChannel;
    /** Event channel. */
    private EmulatorChannel mEventChannel;
    /** Selector for the connection type. */
    private EmulatorConnectionType mConnectionType;
    /** Connection status */
    private boolean mIsConnected = false;
    /** Disconnection status */
    private boolean mIsDisconnected = false;
    /** Exit I/O loop flag. */
    private boolean mExitIoLoop = false;
    /** Disconnect flag. */
    private boolean mDisconnect = false;

    /***************************************************************************
     * EmulatorChannel - Base class for sync / async channels.
     **************************************************************************/

    /**
     * Encapsulates a base class for synchronous and asynchronous communication
     * channels.
     */
    private abstract class EmulatorChannel {
        /** Identifier for a query channel type. */
        private static final String QUERY_CHANNEL = "query";
        /** Identifier for an event channel type. */
        private static final String EVENT_CHANNEL = "event";
        /** BLOB query string. */
        private static final String BLOBL_QUERY = "$BLOB";

        /***********************************************************************
         * Abstract API
         **********************************************************************/

        /**
         * Sends a message via this channel.
         *
         * @param msg Zero-terminated message string to send.
         */
        public abstract void sendMessage(String msg) throws IOException;

        /**
         * Closes this channel.
         */
        abstract public void closeChannel() throws IOException;

        /***********************************************************************
         * Public API
         **********************************************************************/

        /**
         * Constructs EmulatorChannel instance.
         */
        public EmulatorChannel() {
        }

        /**
         * Handles a query received in this channel.
         *
         * @param socket A socket through which the query has been received.
         * @param query_str Query received from this channel. All queries are
         *            formatted as such: <query>:<query parameters> where -
         *            <query> Is a query name that identifies the query, and -
         *            <query parameters> represent parameters for the query.
         *            Query name and query parameters are separated with a ':'
         *            character.
         */
        public void onQueryReceived(Socket socket, String query_str) throws IOException {
            String query, query_param, response;

            // Lets see if query has parameters.
            int sep = query_str.indexOf(':');
            if (sep == -1) {
                // Query has no parameters.
                query = query_str;
                query_param = "";
            } else {
                // Separate query name from its parameters.
                query = query_str.substring(0, sep);
                // Make sure that substring after the ':' does contain
                // something, otherwise the query is paramless.
                query_param = (sep < (query_str.length() - 1)) ? query_str.substring(sep + 1) : "";
            }

            // Handle the query, obtain response string, and reply it back to
            // the emulator. Note that there is one special query: $BLOB, that
            // requires reading of a byte array of data first. The size of the
            // array is defined by the query parameter.
            if (query.compareTo(BLOBL_QUERY) == 0) {
                // This is the BLOB query. It must have a parameter which
                // contains byte size of the blob.
                final int array_size = Integer.parseInt(query_param);
                if (array_size > 0) {
                    // Read data from the query's socket.
                    byte[] array = new byte[array_size];
                    final int transferred = readSocketArray(socket, array);
                    if (transferred == array_size) {
                        // Handle blob query.
                        response = onBlobQuery(array);
                    } else {
                        response = "ko:Transfer failure\0";
                    }
                } else {
                    response = "ko:Invalid parameter\0";
                }
            } else {
                response = onQuery(query, query_param);
                if (response.length() == 0 || response.charAt(0) == '\0') {
                    Logw("No response to the query " + query_str);
                }
            }

            if (response.length() != 0) {
                if (response.charAt(response.length() - 1) != '\0') {
                    Logw("Response '" + response + "' to query '" + query
                            + "' does not contain zero-terminator.");
                }
                sendMessage(response);
            }
        }
    } // EmulatorChannel

    /***************************************************************************
     * EmulatorSyncChannel - Implements a synchronous channel.
     **************************************************************************/

    /**
     * Encapsulates a synchronous communication channel with the emulator.
     */
    private class EmulatorSyncChannel extends EmulatorChannel {
        /** Communication socket. */
        private Socket mSocket;

        /**
         * Constructs EmulatorSyncChannel instance.
         *
         * @param socket Connected ('accept'ed) communication socket.
         */
        public EmulatorSyncChannel(Socket socket) {
            mSocket = socket;
            // Start the reader thread.
            new Thread(new Runnable() {
                @Override
                public void run() {
                    theReader();
                }
            }, "EmuSyncChannel").start();
        }

        /***********************************************************************
         * Abstract API implementation
         **********************************************************************/

        /**
         * Sends a message via this channel.
         *
         * @param msg Zero-terminated message string to send.
         */
        @Override
        public void sendMessage(String msg) throws IOException {
            if (msg.charAt(msg.length() - 1) != '\0') {
                Logw("Missing zero-terminator in message '" + msg + "'");
            }
            mSocket.getOutputStream().write(msg.getBytes());
        }

        /**
         * Closes this channel.
         */
        @Override
        public void closeChannel() throws IOException {
            mSocket.close();
        }

        /***********************************************************************
         * EmulatorSyncChannel implementation
         **********************************************************************/

        /**
         * The reader thread: loops reading and dispatching queries.
         */
        private void theReader() {
            try {
                for (;;) {
                    String query = readSocketString(mSocket);
                    onQueryReceived(mSocket, query);
                }
            } catch (IOException e) {
                onLostConnection();
            }
        }
    } // EmulatorSyncChannel

    /***************************************************************************
     * EmulatorAsyncChannel - Implements an asynchronous channel.
     **************************************************************************/

    /**
     * Encapsulates an asynchronous communication channel with the emulator.
     */
    private class EmulatorAsyncChannel extends EmulatorChannel {
        /** Communication socket channel. */
        private SocketChannel mChannel;
        /** I/O selection key for this channel. */
        private SelectionKey mSelectionKey;
        /** Accumulator for the query string received in this channel. */
        private String mQuery = "";
        /**
         * Preallocated character reader that is used when data is read from
         * this channel. See 'onRead' method for more details.
         */
        private ByteBuffer mIn = ByteBuffer.allocate(1);
        /**
         * Currently sent notification message(s). See 'sendMessage', and
         * 'onWrite' methods for more details.
         */
        private ByteBuffer mOut;
        /**
         * Array of pending notification messages. See 'sendMessage', and
         * 'onWrite' methods for more details.
         */
        private Vector<String> mNotifications = new Vector<String>();

        /**
         * Constructs EmulatorAsyncChannel instance.
         *
         * @param channel Accepted socket channel to use for communication.
         * @throws IOException
         */
        private EmulatorAsyncChannel(SocketChannel channel) throws IOException {
            // Mark character reader at the beginning, so we can reset it after
            // next read character has been pulled out from the buffer.
            mIn.mark();

            // Configure communication channel as non-blocking, and register
            // it with the I/O selector for reading.
            mChannel = channel;
            mChannel.configureBlocking(false);
            mSelectionKey = mChannel.register(mSelector, SelectionKey.OP_READ, this);
            // Start receiving read I/O.
            mSelectionKey.selector().wakeup();
        }

        /***********************************************************************
         * Abstract API implementation
         **********************************************************************/

        /**
         * Sends a message via this channel.
         *
         * @param msg Zero-terminated message string to send.
         */
        @Override
        public void sendMessage(String msg) throws IOException {
            if (msg.charAt(msg.length() - 1) != '\0') {
                Logw("Missing zero-terminator in message '" + msg + "'");
            }
            synchronized (this) {
                if (mOut != null) {
                    // Channel is busy with writing another message.
                    // Queue this one. It will be picked up later when current
                    // write operation is completed.
                    mNotifications.add(msg);
                    return;
                }

                // No other messages are in progress. Send this one outside of
                // the lock.
                mOut = ByteBuffer.wrap(msg.getBytes());
            }
            mChannel.write(mOut);

            // Lets see if we were able to send the entire message.
            if (mOut.hasRemaining()) {
                // Write didn't complete. Schedule write I/O callback to
                // pick up from where this write has left.
                enableWrite();
                return;
            }

            // Entire message has been sent. Lets see if other messages were
            // queued while we were busy sending this one.
            for (;;) {
                synchronized (this) {
                    // Dequeue message that was yielding to this write.
                    if (!dequeueMessage()) {
                        // Writing is over...
                        disableWrite();
                        mOut = null;
                        return;
                    }
                }

                // Send queued message.
                mChannel.write(mOut);

                // Lets see if we were able to send the entire message.
                if (mOut.hasRemaining()) {
                    // Write didn't complete. Schedule write I/O callback to
                    // pick up from where this write has left.
                    enableWrite();
                    return;
                }
            }
        }

        /**
         * Closes this channel.
         */
        @Override
        public void closeChannel() throws IOException {
            mSelectionKey.cancel();
            synchronized (this) {
                mNotifications.clear();
            }
            mChannel.close();
        }

        /***********************************************************************
         * EmulatorAsyncChannel implementation
         **********************************************************************/

        /**
         * Reads data from the channel. This method is invoked from the I/O loop
         * when data is available for reading on this channel. When reading from
         * a channel we read character-by-character, building the query string
         * until zero-terminator is read. When zero-terminator is read, we
         * handle the query, and start building the new query string.
         *
         * @throws IOException
         */
        private void onRead() throws IOException, ClosedChannelException {
            int count = mChannel.read(mIn);
            Logv("onRead: " + count);
            while (count == 1) {
                final char c = (char) mIn.array()[0];
                mIn.reset();
                if (c == '\0') {
                    // Zero-terminator is read. Process the query, and reset
                    // the query string.
                    onQueryReceived(mChannel.socket(), mQuery);
                    mQuery = "";
                } else {
                    // Continue building the query string.
                    mQuery += c;
                }
                count = mChannel.read(mIn);
            }

            if (count == -1) {
                // Channel got disconnected.
                throw new ClosedChannelException();
            } else {
                // "Don't block" in effect. Will get back to reading as soon as
                // read I/O is available.
                assert (count == 0);
            }
        }

        /**
         * Writes data to the channel. This method is ivnoked from the I/O loop
         * when data is available for writing on this channel.
         *
         * @throws IOException
         */
        private void onWrite() throws IOException {
            if (mOut != null && mOut.hasRemaining()) {
                // Continue writing to the channel.
                mChannel.write(mOut);
                if (mOut.hasRemaining()) {
                    // Write is still incomplete. Come back to it when write I/O
                    // becomes available.
                    return;
                }
            }

            // We're done with the current message. Lets see if we've
            // accumulated some more while this write was in progress.
            synchronized (this) {
                // Dequeue next message into mOut.
                if (!dequeueMessage()) {
                    // Nothing left to write.
                    disableWrite();
                    mOut = null;
                    return;
                }
                // We don't really want to run a big loop here, flushing the
                // message queue. The reason is that we're inside the I/O loop,
                // so we don't want to block others for long. So, we will
                // continue with queue flushing next time we're picked up by
                // write I/O event.
            }
        }

        /**
         * Dequeues messages that were yielding to the write in progress.
         * Messages will be dequeued directly to the mOut, so it's ready to be
         * sent when this method returns. NOTE: This method must be called from
         * within synchronized(this).
         *
         * @return true if messages were dequeued, or false if message queue was
         *         empty.
         */
        private boolean dequeueMessage() {
            // It's tempting to dequeue all messages here, but in practice it's
            // less performant than dequeuing just one.
            if (!mNotifications.isEmpty()) {
                mOut = ByteBuffer.wrap(mNotifications.remove(0).getBytes());
                return true;
            } else {
                return false;
            }
        }

        /**
         * Enables write I/O callbacks.
         */
        private void enableWrite() {
            mSelectionKey.interestOps(SelectionKey.OP_READ | SelectionKey.OP_WRITE);
            // Looks like we must wake up the selector. Otherwise it's not going
            // to immediately pick up on the change that we just made.
            mSelectionKey.selector().wakeup();
        }

        /**
         * Disables write I/O callbacks.
         */
        private void disableWrite() {
            mSelectionKey.interestOps(SelectionKey.OP_READ);
        }
    } // EmulatorChannel

    /***************************************************************************
     * EmulatorConnection public API
     **************************************************************************/

    /**
     * Constructs EmulatorConnection instance.
     * Caller must call {@link #connect(int, EmulatorConnectionType)} afterwards.
     *
     * @param listener EmulatorConnection event listener. Must not be null.
     */
    public EmulatorConnection(EmulatorListener listener) {
        mListener = listener;
    }

    /**
     * Connects the EmulatorConnection instance.
     * <p/>
     * Important: Apps targeting Honeycomb+ SDK are not allowed to do networking on their main
     * thread. The caller is responsible to make sure this is NOT called from a main UI thread.
     *
     * @param port TCP port where emulator connects.
     * @param ctype Defines connection type to use (sync / async). See comments
     *            to EmulatorConnection class for more info.
     * @return This object for chaining calls.
     */
    public EmulatorConnection connect(int port, EmulatorConnectionType ctype) {
        constructEmulator(port, ctype);
        return this;
    }


    /**
     * Disconnects the emulator.
     */
    public void disconnect() {
        mDisconnect = true;
        mSelector.wakeup();
    }

    /**
     * Constructs EmulatorConnection instance.
     * <p/>
     * Important: Apps targeting Honeycomb+ SDK are not allowed to do networking on their main
     * thread. The caller is responsible to make sure this is NOT called from a main UI thread.
     * <p/>
     * On error or success, this calls
     * {@link EmulatorListener#onEmulatorBindResult(boolean, Exception)} to indicate whether
     * the socket was properly bound.
     * The IO loop will start after the method reported a successful bind.
     *
     * @param port TCP port where emulator connects.
     * @param ctype Defines connection type to use (sync / async). See comments
     *            to EmulatorConnection class for more info.
     */
    private void constructEmulator(final int port, EmulatorConnectionType ctype) {

        try {
            mConnectionType = ctype;
            // Create I/O looper.
            mSelector = SelectorProvider.provider().openSelector();

            // Create non-blocking server socket that would listen for connections,
            // and bind it to the given port on the local host.
            mServerSocket = ServerSocketChannel.open();
            mServerSocket.configureBlocking(false);
            InetAddress local = InetAddress.getLocalHost();
            final InetSocketAddress address = new InetSocketAddress(local, port);
            mServerSocket.socket().bind(address);

            // Register 'accept' I/O on the server socket.
            mServerSocket.register(mSelector, SelectionKey.OP_ACCEPT);
        } catch (IOException e) {
            mListener.onEmulatorBindResult(false, e);
            return;
        }

        mListener.onEmulatorBindResult(true, null);
        Logv("EmulatorConnection listener is created for port " + port);

        // Start I/O looper and dispatcher.
        new Thread(new Runnable() {
            @Override
            public void run() {
                runIOLooper();
            }
        }, "EmuCnxIoLoop").start();
    }

    /**
     * Sends a notification message to the emulator via 'event' channel.
     * <p/>
     * Important: Apps targeting Honeycomb+ SDK are not allowed to do networking on their main
     * thread. The caller is responsible to make sure this is NOT called from a main UI thread.
     *
     * @param msg
     */
    public void sendNotification(String msg) {
        if (mIsConnected) {
            try {
                mEventChannel.sendMessage(msg);
            } catch (IOException e) {
                onLostConnection();
            }
        } else {
            Logw("Attempt to send '" + msg + "' to a disconnected EmulatorConnection");
        }
    }

    /**
     * Sets or removes a listener to the events generated by this emulator
     * instance.
     *
     * @param listener Listener to set. Passing null with this parameter will
     *            remove the current listener (if there was one).
     */
    public void setEmulatorListener(EmulatorListener listener) {
        synchronized (this) {
            mListener = listener;
        }
        // Make sure that new listener knows the connection status.
        if (mListener != null) {
            if (mIsConnected) {
                mListener.onEmulatorConnected();
            } else if (mIsDisconnected) {
                mListener.onEmulatorDisconnected();
            }
        }
    }

    /***************************************************************************
     * EmulatorConnection events
     **************************************************************************/

    /**
     * Called when emulator is connected. NOTE: This method is called from the
     * I/O loop, so all communication with the emulator will be "on hold" until
     * this method returns.
     */
    private void onConnected() {
        EmulatorListener listener;
        synchronized (this) {
            listener = mListener;
        }
        if (listener != null) {
            listener.onEmulatorConnected();
        }
    }

    /**
     * Called when emulator is disconnected. NOTE: This method could be called
     * from the I/O loop, in which case all communication with the emulator will
     * be "on hold" until this method returns.
     */
    private void onDisconnected() {
        EmulatorListener listener;
        synchronized (this) {
            listener = mListener;
        }
        if (listener != null) {
            listener.onEmulatorDisconnected();
        }
    }

    /**
     * Called when a query is received from the emulator. NOTE: This method
     * could be called from the I/O loop, in which case all communication with
     * the emulator will be "on hold" until this method returns.
     *
     * @param query Name of the query received from the emulator.
     * @param param Query parameters.
     * @return Zero-terminated reply string. String must be formatted as such:
     *         "ok|ko[:reply data]"
     */
    private String onQuery(String query, String param) {
        EmulatorListener listener;
        synchronized (this) {
            listener = mListener;
        }
        if (listener != null) {
            return listener.onEmulatorQuery(query, param);
        } else {
            return "ko:Service is detached.\0";
        }
    }

    /**
     * Called when a BLOB query is received from the emulator. NOTE: This method
     * could be called from the I/O loop, in which case all communication with
     * the emulator will be "on hold" until this method returns.
     *
     * @param array Array containing blob data.
     * @return Zero-terminated reply string. String must be formatted as such:
     *         "ok|ko[:reply data]"
     */
    private String onBlobQuery(byte[] array) {
        EmulatorListener listener;
        synchronized (this) {
            listener = mListener;
        }
        if (listener != null) {
            return listener.onEmulatorBlobQuery(array);
        } else {
            return "ko:Service is detached.\0";
        }
    }

    /***************************************************************************
     * EmulatorConnection implementation
     **************************************************************************/

    /**
     * Loops on the selector, handling and dispatching I/O events.
     */
    private void runIOLooper() {
        try {
            Logv("Waiting on EmulatorConnection to connect...");
            // Check mExitIoLoop before calling 'select', and after in order to
            // detect condition when mSelector has been waken up to exit the
            // I/O loop.
            while (!mExitIoLoop && !mDisconnect &&
                    mSelector.select() >= 0 &&
                    !mExitIoLoop && !mDisconnect) {
                Set<SelectionKey> readyKeys = mSelector.selectedKeys();
                Iterator<SelectionKey> i = readyKeys.iterator();
                while (i.hasNext()) {
                    SelectionKey sk = i.next();
                    i.remove();
                    if (sk.isAcceptable()) {
                        final int ready = sk.readyOps();
                        if ((ready & SelectionKey.OP_ACCEPT) != 0) {
                            // Accept new connection.
                            onAccept(((ServerSocketChannel) sk.channel()).accept());
                        }
                    } else {
                        // Read / write events are expected only on a 'query',
                        // or 'event' asynchronous channels.
                        EmulatorAsyncChannel esc = (EmulatorAsyncChannel) sk.attachment();
                        if (esc != null) {
                            final int ready = sk.readyOps();
                            if ((ready & SelectionKey.OP_READ) != 0) {
                                // Read data.
                                esc.onRead();
                            }
                            if ((ready & SelectionKey.OP_WRITE) != 0) {
                                // Write data.
                                esc.onWrite();
                            }
                        } else {
                            Loge("No emulator channel found in selection key.");
                        }
                    }
                }
            }
        } catch (ClosedSelectorException e) {
        } catch (IOException e) {
        }

        // Destroy connection on any I/O failure.
        if (!mExitIoLoop) {
            onLostConnection();
        }
    }

    /**
     * Accepts new connection from the emulator.
     *
     * @param channel Connecting socket channel.
     * @throws IOException
     */
    private void onAccept(SocketChannel channel) throws IOException {
        // Make sure we're not connected yet.
        if (mEventChannel != null && mQueryChannel != null) {
            // We don't accept any more connections after both channels were
            // connected.
            Loge("EmulatorConnection is connecting to the already connected instance.");
            channel.close();
            return;
        }

        // According to the protocol, each channel identifies itself as a query
        // or event channel, sending a "cmd", or "event" message right after
        // the connection.
        Socket socket = channel.socket();
        String socket_type = readSocketString(socket);
        if (socket_type.contentEquals(EmulatorChannel.QUERY_CHANNEL)) {
            if (mQueryChannel == null) {
                // TODO: Find better way to do that!
                socket.getOutputStream().write("ok\0".getBytes());
                if (mConnectionType == EmulatorConnectionType.ASYNC_CONNECTION) {
                    mQueryChannel = new EmulatorAsyncChannel(channel);
                    Logv("Asynchronous query channel is registered.");
                } else {
                    mQueryChannel = new EmulatorSyncChannel(channel.socket());
                    Logv("Synchronous query channel is registered.");
                }
            } else {
                // TODO: Find better way to do that!
                Loge("Duplicate query channel.");
                socket.getOutputStream().write("ko:Duplicate\0".getBytes());
                channel.close();
                return;
            }
        } else if (socket_type.contentEquals(EmulatorChannel.EVENT_CHANNEL)) {
            if (mEventChannel == null) {
                // TODO: Find better way to do that!
                socket.getOutputStream().write("ok\0".getBytes());
                if (mConnectionType == EmulatorConnectionType.ASYNC_CONNECTION) {
                    mEventChannel = new EmulatorAsyncChannel(channel);
                    Logv("Asynchronous event channel is registered.");
                } else {
                    mEventChannel = new EmulatorSyncChannel(channel.socket());
                    Logv("Synchronous event channel is registered.");
                }
            } else {
                Loge("Duplicate event channel.");
                socket.getOutputStream().write("ko:Duplicate\0".getBytes());
                channel.close();
                return;
            }
        } else {
            Loge("Unknown channel is connecting: " + socket_type);
            socket.getOutputStream().write("ko:Unknown channel type\0".getBytes());
            channel.close();
            return;
        }

        // Lets see if connection is complete...
        if (mEventChannel != null && mQueryChannel != null) {
            // When both, query and event channels are connected, the emulator
            // is considered to be connected.
            Logv("... EmulatorConnection is connected.");
            mIsConnected = true;
            onConnected();
        }
    }

    /**
     * Called when connection to any of the channels has been lost.
     */
    private void onLostConnection() {
        // Since we're multithreaded, there can be multiple "bangs" from those
        // threads. We should only handle the first one.
        boolean first_time = false;
        synchronized (this) {
            first_time = mIsConnected;
            mIsConnected = false;
            mIsDisconnected = true;
        }
        if (first_time) {
            Logw("Connection with the emulator is lost!");
            // Close all channels, exit the I/O loop, and close the selector.
            try {
                if (mEventChannel != null) {
                    mEventChannel.closeChannel();
                }
                if (mQueryChannel != null) {
                    mQueryChannel.closeChannel();
                }
                if (mServerSocket != null) {
                    mServerSocket.close();
                }
                if (mSelector != null) {
                    mExitIoLoop = true;
                    mSelector.wakeup();
                    mSelector.close();
                }
            } catch (IOException e) {
                Loge("onLostConnection exception: " + e.getMessage());
            }

            // Notify the app about lost connection.
            onDisconnected();
        }
    }

    /**
     * Reads zero-terminated string from a synchronous socket.
     *
     * @param socket Socket to read string from. Must be a synchronous socket.
     * @return String read from the socket.
     * @throws IOException
     */
    private static String readSocketString(Socket socket) throws IOException {
        String str = "";

        // Current characted received from the input stream.
        int current_byte = 0;

        // With port forwarding there is no reliable way how to detect
        // socket disconnection, other than checking on the input stream
        // to die ("end of stream" condition). That condition is reported
        // when input stream's read() method returns -1.
        while (socket.isConnected() && current_byte != -1) {
            // Character by character read the input stream, and accumulate
            // read characters in the command string. The end of the command
            // is indicated with zero character.
            current_byte = socket.getInputStream().read();
            if (current_byte != -1) {
                if (current_byte == 0) {
                    // String is completed.
                    return str;
                } else {
                    // Append read character to the string.
                    str += (char) current_byte;
                }
            }
        }

        // Got disconnected!
        throw new ClosedChannelException();
    }

    /**
     * Reads a block of data from a socket.
     *
     * @param socket Socket to read data from. Must be a synchronous socket.
     * @param array Array where to read data.
     * @return Number of bytes read from the socket, or -1 on an error.
     * @throws IOException
     */
    private static int readSocketArray(Socket socket, byte[] array) throws IOException {
        int in = 0;
        while (in < array.length) {
            final int ret = socket.getInputStream().read(array, in, array.length - in);
            if (ret == -1) {
                // Got disconnected!
                throw new ClosedChannelException();
            }
            in += ret;
        }
        return in;
    }

    /***************************************************************************
     * Logging wrappers
     **************************************************************************/

    private void Loge(String log) {
        Log.e(TAG, log);
    }

    private void Logw(String log) {
        Log.w(TAG, log);
    }

    private void Logv(String log) {
        Log.v(TAG, log);
    }
}
