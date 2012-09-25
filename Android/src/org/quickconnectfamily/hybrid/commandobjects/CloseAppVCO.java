package org.quickconnectfamily.hybrid.commandobjects;

import java.util.HashMap;

import org.quickconnect.ControlObject;

import android.util.Log;



public class CloseAppVCO implements ControlObject {

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
        /*
         * Notify the system to finalize and collect all objects of the app
         * on exit so that the virtual machine running the app can be killed
         * by the system without causing issues. NOTE: If this is set to
         * true then the virtual machine will not be killed until all of its
         * threads have closed.
         */
		Log.d("", "CloseAppVCO: Closing App.");
        System.runFinalizersOnExit(true);

        /*
         * Force the system to close the app down completely instead of
         * retaining it in the background. The virtual machine that runs the
         * app will be killed. The app will be completely created as a new
         * app in a new virtual machine running in a new process if the user
         * starts the app again.
         */
        System.exit(0);
        
        return null;
	}

}
