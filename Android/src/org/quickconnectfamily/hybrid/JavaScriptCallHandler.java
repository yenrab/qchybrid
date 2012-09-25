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
package org.quickconnectfamily.hybrid;



import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.Semaphore;

import org.quickconnect.QuickConnect;
import org.quickconnect.json.*;



/**
 * @author Lee Barney
 *
 */
public class JavaScriptCallHandler{
	
	private static JavaScriptCallHandler theInstance;
	private boolean beenLoaded = false;

	private QCAndroid theActivity = null;
	private ArrayList<ArrayList>theMessageQueue;
	private Semaphore readWriteSemaphore;
	
	public void setTheActivity(QCAndroid theActivity) {
		this.theActivity = theActivity;
	}
	static{
		theInstance = new JavaScriptCallHandler();
	}
	
	private JavaScriptCallHandler(){
		theMessageQueue = new ArrayList<ArrayList>();

		readWriteSemaphore = new Semaphore(Integer.MAX_VALUE, true);
	}
	public static JavaScriptCallHandler getInstance(){
		return theInstance;
	}

	public boolean getBeenLoaded(){
		return beenLoaded;
	}
	
	public void setBeenLoaded(){
		beenLoaded = true;
	}
	
	/**
	 * @param command - a command to be acted on
	 * @param parameters - this must be a JSON string in order to pass multiple parameters
	 * @return A JSON string to be objectified on the JavaScript side
	 */
	@SuppressWarnings("unchecked")
	public void makeCall(String command, String parameterString){
		
		//System.out.println("making call: "+command+ " "+parameterString);

		ArrayList<Object> params = null;
		try {

			if(parameterString.startsWith("[")){
				params = (ArrayList<Object>)JSONUtilities.parse(parameterString);
			}
			else{
				params = new ArrayList<Object>();
				params.add(JSONUtilities.parse(parameterString));
			}
			//System.out.println("command: "+command+" params: "+params);
		} catch (JSONException e) {
			//e.printStackTrace();
			if(params == null){
				params = new ArrayList<Object>();
				params.add(parameterString);
			}
		}
		//Log.d(AndroidJunkActivity.LOG_TAG, "calling handle request");
		HashMap<String,Object> paramMap = new HashMap<String,Object>();
		paramMap.put("activity", theActivity);
		paramMap.put("parameters",params);
		QuickConnect.handleRequest(command, paramMap);
	}
	
	public void addResponseToQueue(ArrayList<Object> aMessage) throws Exception{
		if(aMessage == null || aMessage.size() != 2){
			throw new Exception("Invalid response being added to response queue.  Ignored this message"+aMessage);
		}
		readWriteSemaphore.acquire(Integer.MAX_VALUE);
		theMessageQueue.add(aMessage);
		readWriteSemaphore.release(Integer.MAX_VALUE);
	}
	
	public String messageQueueAsJSON(){
		String response = "[]";
		try {
			try {
				readWriteSemaphore.acquire(Integer.MAX_VALUE);
				response = JSONUtilities.stringify(theMessageQueue);
				theMessageQueue.clear();
				readWriteSemaphore.release(Integer.MAX_VALUE);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		System.out.println("Response sent: "+response);
		return response;
	}
}
