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
import org.quickconnect.dbaccess.DataAccessObject;
import org.quickconnect.dbaccess.DataAccessResult;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;

public class TransactionHandlerBCO implements ControlObject {

	public Object handleIt(HashMap<String,Object> parametersMap) {
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		 //JSONArray paramArray = (JSONArray)parameters; 
		 DataAccessResult aResult = new DataAccessResult();
			try {
				//Log.d(AndroidJunkActivity.LOG_TAG, "getting data with 0 "+paramArray.get(0)+" 1 "+paramArray.get(1)+" 2 "+paramArray.get(2).getClass().getName());
				String dbName = (String)parameters.get(0);
				String requestType = (String)parameters.get(1);
				//Log.d(AndroidJunkActivity.LOG_TAG, "transaction "+requestType.toString());
				if(requestType.equals("start")){
					DataAccessObject.startTransaction(QCAndroid.getInstance(), dbName);
				}
				else if(requestType.equals("commit")){
					DataAccessObject.endTransaction(QCAndroid.getInstance(), dbName, true);
				}
				else if(requestType.equals("rollback")){
					DataAccessObject.endTransaction(QCAndroid.getInstance(), dbName, false);
				}
				
			} catch (Exception e) {
				Log.e(QCAndroid.LOG_TAG, "ERROR using transactions: "+e.getCause());
				aResult.setErrorDescription("ERROR using transactions: "+e.getCause());
			}
			return aResult;
	}

}
