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
import java.util.Iterator;
import java.util.Set;
import 	java.net.URLEncoder;

import org.quickconnect.ControlObject;
import org.quickconnect.dbaccess.DataAccessResult;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;

public class SendDBResultVCO implements ControlObject{
	@SuppressWarnings("unchecked")
	public Object handleIt(HashMap<String,Object> parametersMap) {
		DataAccessResult  results = (DataAccessResult)parametersMap.get("queryResult");
		ArrayList<Object> resultList = new ArrayList<Object>();
		resultList.add(results);
		String aJSCallString = "";
		
		ArrayList<Object> params = (ArrayList<Object>) parametersMap.get("parameters");
		
		System.out.println("parameter count in SendDBResultVCO: "+params.size());
		for(int i = 0; i < params.size(); i++){
			System.out.println("A param: "+params.get(i));
		}
		
		
		Set<String> keys = parametersMap.keySet();
		Iterator<String> anIt = keys.iterator();
		while(anIt.hasNext()){
			System.out.println("Key: "+anIt.next());
		}
		
		try {
			System.out.println("parameters: "+JSONUtilities.stringify(params));
		} catch (JSONException e1) {
			e1.printStackTrace();
		}

		ArrayList<String> stackIdentifier = (ArrayList<String>) params.get(3);
		
		ArrayList<Object> accumulator = new ArrayList<Object>();
		
		try {
			accumulator.add(resultList);
			accumulator.add(stackIdentifier.get(0));
			System.out.println("Identifier: "+stackIdentifier.get(0));
		
			String aJSONString = JSONUtilities.stringify(accumulator);
			System.out.println("JSON: "+aJSONString);
			aJSONString = aJSONString.replaceAll("\\\\\"","\"");
			aJSONString = aJSONString.replaceAll("\\+","__PlUs__");
			aJSONString = URLEncoder.encode(aJSONString, "UTF-8");
			aJSCallString = "javascript:handleRequestCompletionFromNative('"+aJSONString+"')";
			System.out.println("JSON2: "+aJSONString);
		}
		catch(Exception e){
			Log.e(QCAndroid.LOG_TAG, "Error: "+e.toString());
		}
		QCAndroid.getWebView().loadUrl(aJSCallString);
		return true;
	}
}
