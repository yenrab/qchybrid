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

import org.quickconnect.ControlObject;
import org.quickconnect.dbaccess.DataAccessObject;
import org.quickconnect.dbaccess.DataAccessResult;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;

public class GetDataBCO implements ControlObject{
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public Object handleIt(HashMap<String,Object> parametersMap){
		System.out.println("getting data");
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		System.out.println("got parameters: "+parameters);
				 
		DataAccessResult retVal = null;
		try {
			String dbName = (String)parameters.get(0);
			System.out.println("using db: "+dbName);
			ArrayList aJSArray = (ArrayList)parameters.get(2);
			ArrayList paramList = new ArrayList();
			int numParams = aJSArray.size();
			for(int i = 0; i < numParams; i++){
				Object param = aJSArray.get(i);
				paramList.add((String)param);
			}
			Object[] params = null;
			if(paramList.size() > 0){
				params = paramList.toArray();
			}			
			String sql = (String)parameters.get(1);
			System.out.println("using sql: "+sql);
			retVal = DataAccessObject.transact(QCAndroid.getInstance(), dbName, sql, params);
			System.out.println("got a result: "+retVal);
		} catch (Exception e) {
			System.out.println("ERROR: "+e.getLocalizedMessage());
		}
		try {
			System.out.println("query result: "+JSONUtilities.stringify(retVal));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		parametersMap.put("queryResult", retVal);
		
		return true;
	}
}
