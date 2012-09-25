package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.view.View;

public class ViewDoesNotExistValCO implements ControlObject {

	@SuppressWarnings("unchecked")
	public Object handleIt(HashMap<String, Object> parametersMap) {
		ArrayList<Object>passedParameters = (ArrayList<Object>)parametersMap.get("parameters");
		HashMap<Object, Object> configuration = (HashMap<Object, Object>) passedParameters.get(0);
		QCAndroid theQCActivity = (QCAndroid)parametersMap.get("activity");
		String jsId = (String) configuration.get("id");
		View theView = theQCActivity.getView( jsId);
		if(theView != null){
			/*
			 * a call to handleError would go here
			 */
			System.out.println("Unexpectedly found view with tag "+ jsId);
			return false;
		}
		System.out.println("Did not find view with tag "+ jsId +". Proceeding to add.");
		return true;
	}

}
