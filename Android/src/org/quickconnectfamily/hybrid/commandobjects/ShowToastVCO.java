package org.quickconnectfamily.hybrid.commandobjects;

import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.widget.Toast;

public class ShowToastVCO implements ControlObject {

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		
		Toast.makeText(QCAndroid.getInstance(), "This is a simple bit of text.", 1000);
		
		return true;
	}

}
