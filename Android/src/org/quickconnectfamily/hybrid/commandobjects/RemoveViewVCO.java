package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;
import org.quickconnectfamily.hybrid.QCViewsPlugin;

import android.view.View;

public class RemoveViewVCO implements ControlObject
{

	public Object handleIt(ArrayList<Object> arg0) {
		
		return null;
	}

	public Object handleIt(HashMap<String, Object> parametersMap) {
		
		QCAndroid theQCActivity = (QCAndroid)parametersMap.get("activity");
		
		View viewToModify = (View)parametersMap.get("foundView");
		String JSID = (String) parametersMap.get("id");
		ArrayList passedParameters = (ArrayList)parametersMap.get("parameters");
		HashMap configuration = (HashMap) passedParameters.get(0);
		QCViewsPlugin.removeView( theQCActivity, viewToModify, JSID, configuration);
		
		/*
		 * 
		 *  QCViewsPlugin.removeView( theQCActivity, viewToModify, JSID ); takes care of calling:
		 *
		 *	theQCActivity.viewStorage.remove(JSID);
		 *	theQCActivity.removeView(viewToModify); OR
		 *  (ViewGroup) parent.removeView()
		 */
		
		
		/* if we got callback parameters, we need to add in callback to js to tell it the view has been removed */
        String aJSCallString = null;
		ArrayList<Object> params = (ArrayList<Object>)parametersMap.get("parameters");
		try{
			ArrayList<String> stackIdentifier = (ArrayList<String>) params.get(1);	
			String status = "true";  // just assume we did really remove the view for now
            /*
			String status = "false";
			if( theQCActivity.getView( id ) == null ){
				status = "true";
			}
			*/
			ArrayList<String> accumulator = new ArrayList<String>();
			accumulator.add(status);
			accumulator.add(stackIdentifier.get(0));
					
			try {
				aJSCallString = "javascript:handleRequestCompletionFromNative('" +JSONUtilities.stringify(accumulator)+ "')";
			} catch (JSONException e) {
				aJSCallString = "javascript:handleRequestCompletionFromNative()";
			}
			
			QCAndroid.getWebView().loadUrl(aJSCallString); // Send it back!
		} catch( Exception e ){
			System.out.println("No stack identifier found.");
		}
		
		return aJSCallString;
	}

}
