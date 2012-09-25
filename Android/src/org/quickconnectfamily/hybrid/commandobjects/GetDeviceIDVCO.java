package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.content.Context;
import android.telephony.TelephonyManager;

public class GetDeviceIDVCO implements ControlObject{

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		String id = null;
		try{
		Context ctext = QCAndroid.getInstance();
		TelephonyManager tele = (TelephonyManager) ctext.getSystemService(Context.TELEPHONY_SERVICE);
		id = tele.getDeviceId();
		}
		catch(Exception e){
		//We need to figure out how to handle those arcane, cell-less beasts.
		//id = UUID.randomUUID().toString();
			id = "null";
		}
		ArrayList passedParameters = (ArrayList)parameters.get("parameters");
		String aJSCallString = null;
		/* if we got callback parameters, we need to add in callback to js to tell it the view has been modified */
		try{
			ArrayList<String> stackIdentifier = (ArrayList<String>) passedParameters.get(0);			
			ArrayList<String> accumulator = new ArrayList<String>(); // for handleRequestCompletionFromNative
			accumulator.add(id);                                     // [0] is my return value
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
