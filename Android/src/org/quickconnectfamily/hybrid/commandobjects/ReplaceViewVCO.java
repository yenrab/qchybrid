package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;
import org.quickconnectfamily.hybrid.QCMapView;
import org.quickconnectfamily.hybrid.QCViewGroup;
import org.quickconnectfamily.hybrid.QCViewsPlugin;
import org.quickconnectfamily.hybrid.QCWebView;

import android.view.View;

public class ReplaceViewVCO implements ControlObject {

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public Object handleIt(HashMap<String, Object> parametersMap) {
		
		// Get the view from the previous function in the stack, and remove it.
		QCAndroid theQCActivity = (QCAndroid)parametersMap.get("activity");
		ArrayList passedParameters = (ArrayList)parametersMap.get("parameters");
		HashMap configuration = (HashMap) passedParameters.get(0);
		String JSID = (String) configuration.get("id");
		View viewToRemove = (View)parametersMap.get("foundView");
		QCViewsPlugin.removeView( theQCActivity, viewToRemove, JSID, configuration);

		String aJSCallString = null;
		View newView = null;
		
		// The view has been removed, so let's create a new one. This is similar to AddViewVCO
		try {
			String aType = (String) configuration.get("viewType");
			newView = QCViewsPlugin.addViewForType(theQCActivity, aType, configuration);
			String click = (String)configuration.get("clickable");
			newView.setClickable(Boolean.parseBoolean(click));
		} catch (Exception e) {
			System.out.println("Failed to create view with tag "+ JSID +".");
			e.printStackTrace();
		}
		
		// Configure the new view with it's configuration
		Object cfgReturn = null;
		if(newView.getClass() == QCWebView.class){
			 cfgReturn = ((QCWebView) newView).configure(configuration);
		}
		else if(newView.getClass() == QCMapView.class){
			((QCMapView) newView).configure(configuration);
			cfgReturn = "true";
		}
		else if(newView.getClass() == QCViewGroup.class){
			cfgReturn = ((QCViewGroup) newView).configure(configuration);
		}

		// Finish by sending back to the javascript
		try{
			ArrayList<String> stackIdentifier = null;
			try {
				stackIdentifier = (ArrayList<String>) passedParameters.get(1);
			}
			catch (Exception e) {
				stackIdentifier = null; // There wasn't a stack identifier
			}
			
			String status = "true";
			if(cfgReturn == null) {
				status = "false";
			}
			
			ArrayList<String> accumulator = new ArrayList<String>(); // for handleRequestCompletionFromNative
			accumulator.add(status);                                 // [0] is my return value
			if (stackIdentifier != null) {
				accumulator.add(stackIdentifier.get(0));             // [1] is the current js command stack identifier
			}
					
			try {
				aJSCallString = "javascript:handleRequestCompletionFromNative('" +JSONUtilities.stringify(accumulator)+ "')";
			} catch (JSONException e) {
				aJSCallString = "javascript:handleRequestCompletionFromNative()";
			}
			
			QCAndroid.getWebView().loadUrl(aJSCallString); // Send it back!
		} catch( Exception e ){
			System.out.println("No stack identifier found.");
			// Have a call to the error handler here?
		}

		System.out.println("Returning: "+aJSCallString);
		
		return aJSCallString;
	}

}
