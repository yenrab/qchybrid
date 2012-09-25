package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

public class SendCacheResourcesResultVCO implements ControlObject {

	@SuppressWarnings("unchecked")
	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		
		ArrayList<Object>params           = (ArrayList<Object>)parameters.get("parameters");
		ArrayList<String> stackIdentifier = (ArrayList<String>)params.get(1);

		String aJSCallString = null;

		ArrayList<Object> accumulator = new ArrayList<Object>();
		accumulator.add(parameters.get("cacheResult"));
		accumulator.add(stackIdentifier.get(0));
				
		try {
			aJSCallString = "javascript:handleRequestCompletionFromNative('" +JSONUtilities.stringify(accumulator)+ "')";
		} catch (JSONException e) {
			aJSCallString = "javascript:handleRequestCompletionFromNative()";
		}
		
		QCAndroid.getWebView().loadUrl(aJSCallString); // Send it back!
		
		return null;
	}
	
}
