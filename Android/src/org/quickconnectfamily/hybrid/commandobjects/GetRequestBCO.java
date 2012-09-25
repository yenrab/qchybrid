package org.quickconnectfamily.hybrid.commandobjects;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.quickconnect.ControlObject;
import org.quickconnect.QuickConnect;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;

public class GetRequestBCO implements ControlObject {

	public Object handleIt(HashMap<String,Object> parametersMap) {
		
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		URL checkedURL = (URL)parameters.get(1);
		HttpClient httpclient = new DefaultHttpClient();
		String retVal = null;
		try {
			HttpGet httpget = new HttpGet(checkedURL.toURI());
			HttpResponse response = httpclient.execute(httpget);
			HttpEntity responseEntity = response.getEntity();
			if (responseEntity != null) {
				
				retVal = EntityUtils.toString(responseEntity, HTTP.UTF_8);
			}
		} catch (Exception e) {
			parameters.add(e);
			retVal = null;
		}
		finally {
			httpclient.getConnectionManager().shutdown();
		}
		if(retVal == null){
			QuickConnect.handleError("getRequestFailure", parametersMap);
		}

		retVal = retVal.replaceAll("\"","'");
		return retVal;
	}

}
