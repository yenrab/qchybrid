package org.quickconnectfamily.hybrid.commandobjects;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;

public class SendHTTPResultVCO implements ControlObject {

	public Object handleIt(HashMap<String,Object> parametersMap) {

		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		//Log.d(QCAndroid.LOG_TAG, (String)parameters.get(3));
		String aJSCallString = "";
		ArrayList<Object> accumulator = new ArrayList<Object>();
		try{
			accumulator.add(parameters.get(3));
			ArrayList<Object> passThroughParams = (ArrayList<Object>)parameters.get(2);
			if(passThroughParams.size() > 0 && passThroughParams.get(0) != null){
				accumulator.add(parameters.get(2));
			}
			String aJSONString = JSONUtilities.stringify(accumulator);
			aJSONString = aJSONString.replaceAll("\\r\\n", "");
			aJSONString = aJSONString.replaceAll("\\n", "");
			aJSONString = aJSONString.replaceAll("\\\\\"","\"");
			aJSONString = aJSONString.replaceAll("\\+","__PlUs__");
			aJSONString = URLEncoder.encode(aJSONString, "UTF-8");
			aJSCallString = "javascript:handleRequestCompletionFromNative('"+aJSONString+"')";
	
		}
		catch(Exception e){
			Log.e(QCAndroid.LOG_TAG, "Error: "+e.toString());
		}
		////Log.d(AndroidJunkActivity.LOG_TAG, "Sending JSON string: "+aJSCallString);
		QCAndroid.getWebView().loadUrl(aJSCallString);
		
		return null;
	}

}
