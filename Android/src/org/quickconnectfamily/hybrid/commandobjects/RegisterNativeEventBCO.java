package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

public class RegisterNativeEventBCO implements ControlObject {

	@SuppressWarnings("unchecked")
	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		String aJSCallString = null;
		
		ArrayList<Object> params = (ArrayList<Object>)parameters.get("parameters");
		try {
			String nativeEvent = (String) params.get(0);
			String jsCommand = (String) params.get(1);
			System.out.println("Registering native event "+nativeEvent+" for command "+jsCommand+".");
			ArrayList<String> stackIdentifier = (ArrayList<String>) params.get(2);
			//QCAndroid qc = QCAndroid.getInstance();
			
			String status = "false";
			if( QCAndroid.registerJsNativeEventHandler(nativeEvent, jsCommand) ){
				status = "true";
			}
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
