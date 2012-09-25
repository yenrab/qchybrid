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

public class SetDataBCO  implements ControlObject {
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public Object handleIt(HashMap<String,Object> parametersMap) {
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		
		DataAccessResult retVal = null;
		try {
			String dbName = (String) parameters.get(0);
			ArrayList<Object> paramList = (ArrayList<Object>)parameters.get(2);
			
			// For some odd reason, some params come through as a long, which was causing a crash.
			// So we need to convert the long to a string!
			for (int i = 0; i < paramList.size(); i++) {
				Class aClass = paramList.get(i).getClass();
				if (aClass.equals(Long.class)) {
					Long theNum = (Long)paramList.get(i);
					paramList.set(i, theNum.toString());
				}
			}
			
			Object[] params = null;
			if(paramList.size() > 0){
				params = paramList.toArray();
			}
			
			String sql = (String)parameters.get(1);
			retVal = DataAccessObject.transact(QCAndroid.getInstance(), dbName, sql, params);
		} catch (Exception e) {
			Log.d(QCAndroid.LOG_TAG, "ERROR: "+e.getLocalizedMessage());
		}
		
		
		parametersMap.put("queryResult", retVal);
		
		return retVal;
	}
}
