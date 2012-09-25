package org.quickconnectfamily.hybrid.commandobjects;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;
import org.quickconnectfamily.hybrid.QCViewsPlugin;

import android.view.View;

public class AddViewVCO implements ControlObject{

	@SuppressWarnings("unchecked")
	public Object handleIt(HashMap<String, Object> parametersMap) {
		ArrayList<Object> passedParameters = (ArrayList<Object>)parametersMap.get("parameters");
		HashMap<Object, Object> configuration = (HashMap<Object, Object>) passedParameters.get(0);
		String aType = (String) configuration.get("viewType");
		String jsId = (String) configuration.get("id");
		System.out.println("Trying to add a "+aType+" view with tag: "+ jsId);
		try {
			View theView = QCViewsPlugin.addViewForType((QCAndroid)parametersMap.get("activity"), aType, configuration);
			String click = (String)configuration.get("clickable");
			theView.setClickable(Boolean.parseBoolean(click));
			
			// Get out the visibility and figure out which type it is
			theView.setVisibility(determineVisibility((String)configuration.get("visibility")));
			
			parametersMap.put("foundView", theView);
		} catch (Exception e) {
			e.printStackTrace();
			/*
			 * A call to handleError would go here.
			 */
			return false;
		}
		
		return true;
	}
	
	private Integer determineVisibility(String aString) {
		// The following URL explains these integer constants
		// http://developer.android.com/reference/android/view/View.html#attr_android:visibility
		if (aString == null) {
			return 0;
		}
		
		if (aString.equals("invisible")) {
			return 1;
		}
		else if (aString.equals("gone")) {
			return 2;
		}
		
		return 0; 
	}
}
