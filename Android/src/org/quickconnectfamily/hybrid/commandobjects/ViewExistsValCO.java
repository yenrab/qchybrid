package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.view.View;

public class ViewExistsValCO implements ControlObject {

	@SuppressWarnings("unchecked")
	public Object handleIt(HashMap<String, Object> parametersMap) {
		ArrayList<Object>passedParameters = (ArrayList<Object>)parametersMap.get("parameters");
		HashMap<Object, Object> configuration = (HashMap<Object, Object>) passedParameters.get(0);
		QCAndroid theQCActivity = (QCAndroid)parametersMap.get("activity");
		View theView = theQCActivity.getView((String) configuration.get("id"));
		if(theView == null){
			/*
			 * a call to handleError would go here
			 */
			return false;
		}
        parametersMap.put("foundView", theView);
		return true;
		
	}

}
