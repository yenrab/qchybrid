package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class NetworkStatusBCO implements ControlObject {

	static ConnectivityManager conMgr = null;
	
	@SuppressWarnings("unchecked")
	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		String aJSCallString = null;
		
		ArrayList<Object> params = (ArrayList<Object>)parameters.get("parameters");
		try {
			ArrayList<String> stackIdentifier = (ArrayList<String>) params.get(0);

			QCAndroid qc = QCAndroid.getInstance();
			if (conMgr == null) {
				conMgr =  (ConnectivityManager)qc.getSystemService(Context.CONNECTIVITY_SERVICE);	
			}
		
			String status = "";
			
			NetworkInfo currentNetInfo = conMgr.getActiveNetworkInfo();
			if((currentNetInfo != null) && (currentNetInfo.getState() == NetworkInfo.State.CONNECTED)) {
				String type = currentNetInfo.getTypeName();
				String subType = currentNetInfo.getSubtypeName();
				System.out.println("Network type: "+type+" "+subType);
				if(type.equals("WIFI")) { //find out if we have wifi
					status = "wifi";
				}
				else if(type.equals("MOBILE")){ // or 3G
					status = "3G";
					/* check subType in the future to determine if we really have 3G, or just some other data (EDGE, 
				     * Roaming, etc.)
				     * We'll also want to check for background data usage on Android 
				     */
				}
				else{
					// or something else
					status = "other";
				}	
			}
			else{
				status = "none";
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
