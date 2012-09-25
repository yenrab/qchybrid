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

import org.quickconnect.dbaccess.DataAccessException;
import org.quickconnect.dbaccess.DataAccessObject;
import org.quickconnect.dbaccess.DataAccessResult;
import org.quickconnect.json.JSONUtilities;
import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

public class ExecuteDBScriptBCO implements ControlObject{
	
	@SuppressWarnings({ "unchecked", "rawtypes", "unused" })
	public Object handleIt(HashMap<String,Object> parametersMap){
		
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		DataAccessResult retVal = null;
		boolean transactionSuccess = true;
		String dbName = null;
		try {
			dbName = (String)parameters.get(0);
			ArrayList statementsToExecute = (ArrayList)parameters.get(1);
			
			DataAccessObject.startTransaction(QCAndroid.getInstance(),dbName);
			for (int rowCnt = 0; rowCnt < statementsToExecute.size(); rowCnt++) {
				
				ArrayList<Object> row = (ArrayList<Object>)statementsToExecute.get(rowCnt);
				
				boolean simpleKey = true;
				String key = row.get(0).toString();
				String sql = row.get(1).toString();
				ArrayList preparedStatementParams = null;
				try {
					int aInt = Integer.parseInt((String)row.get(0));
				}
				catch (Exception e) {
					simpleKey = false;
				}

				if(!simpleKey){
					preparedStatementParams = new ArrayList();
					String rowElement = (String)row.get(0);
					ArrayList aTempArray = (ArrayList)JSONUtilities.parse(rowElement);
					preparedStatementParams = (ArrayList)aTempArray.get(1);
				}
				
				// For some odd reason, some params come through as a long, which was causing a crash.
				// So we need to convert the long to a string!
				for (int i = 0; i < preparedStatementParams.size(); i++) {
					Class aClass = preparedStatementParams.get(i).getClass();
					if (aClass.equals(Long.class)) {
						Long theNum = (Long)preparedStatementParams.get(i);
						preparedStatementParams.set(i, theNum.toString());
					}
				}
				
				Object [] params = null;
				if(preparedStatementParams != null){
					params = preparedStatementParams.toArray();
				}

				retVal = DataAccessObject.transact(QCAndroid.getInstance(), dbName, sql, params);
				if (!retVal.getErrorDescription().equals("not an error")) {
					transactionSuccess = false;
					break;
				}
			}
			 
		} catch (Exception e) {
			transactionSuccess = false;
		}
		try {
			DataAccessObject.endTransaction(QCAndroid.getInstance(), dbName, transactionSuccess);
		} catch (DataAccessException e) {
			e.printStackTrace();
		}
		
		parametersMap.put("queryResult", retVal);
		
		return retVal;
	}
}
