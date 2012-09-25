/*
 Copyright (c) 2008, 2009 Lee Barney
 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation the 
 rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the Software 
 is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be 
 included in all copies or substantial portions of the Software.
 
 The end-user documentation included with the redistribution, if any, must 
 include the following acknowledgment: 
 "This product was created using the QuickConnect framework.  http://quickconnect.sourceforge.net/", 
 in the same place and form as other third-party acknowledgments.   Alternately, this acknowledgment 
 may appear in the software itself, in the same form and location as other 
 such third-party acknowledgments.
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 
 */
package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.util.Log;

public class GetDeviceInfoVCO implements ControlObject {

	@SuppressWarnings({ "unused", "unchecked" })
	public Object  handleIt(HashMap<String,Object> parametersMap){
	
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		Log.d(QCAndroid.LOG_TAG, "getting device info");
		
		JSONArray accumulator = new JSONArray();
		
		TelephonyManager operator = (TelephonyManager) QCAndroid.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
		accumulator.put(operator.getDeviceId());
		accumulator.put(android.os.Build.MODEL);
		accumulator.put(android.os.Build.PRODUCT);
		accumulator.put(android.os.Build.DEVICE);
		accumulator.put(android.os.Build.VERSION.SDK);
		
		JSONArray returnValues = new JSONArray();
		returnValues.put(accumulator);
		//returnValues.put(stackIdentifier);
		String aJSONString = returnValues.toString();
		Log.d(QCAndroid.LOG_TAG, "info string: "+aJSONString);
		String aJSCallString = "javascript:handleJSONRequest('showDeviceInfo', '"+aJSONString+"')";
		//String aJSCallString = "javascript:handleRequestCompletionFromNative('"+aJSONString+"')";
		QCAndroid.getWebView().loadUrl(aJSCallString);
		return accumulator;
	}

}
