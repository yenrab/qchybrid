package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

public class GetUUIDVCO implements ControlObject{

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		ArrayList passedParameters = (ArrayList)parameters.get("parameters");
		String aJSCallString = null;
		String retval = UUID.randomUUID().toString();
		/* if we got callback parameters, we need to add in callback to js to tell it the view has been modified */
		try{
			ArrayList<String> stackIdentifier = (ArrayList<String>) passedParameters.get(0);			
			ArrayList<String> accumulator = new ArrayList<String>(); // for handleRequestCompletionFromNative
			accumulator.add(retval);                                 // [0] is my return value
			accumulator.add(stackIdentifier.get(0));                 // [1] is the current js command stack identifier
					
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
