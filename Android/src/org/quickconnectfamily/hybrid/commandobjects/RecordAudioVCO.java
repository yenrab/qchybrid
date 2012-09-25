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

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.media.MediaRecorder;
import android.util.Log;

public class RecordAudioVCO  implements ControlObject{

	public Object handleIt(HashMap<String,Object> parametersMap){
		//Log.d(QCAndroid.LOG_TAG, "recording audio");

		ArrayList<Object> results = (ArrayList<Object>)parametersMap.get("bcoResults");

		String fileName = "UnknownName";
		String startStopFlag = "Stop";
		try {
			fileName = ((String)((JSONArray)((ArrayList)results).get(0)).get(0)).trim();
			startStopFlag = ((String)((JSONArray)((ArrayList)results).get(0)).get(1)).trim();
		} catch (Exception e) {
			Log.d(QCAndroid.LOG_TAG, "bad JSON string");
		}
		if(startStopFlag.equals("start")){
			if(QCAndroid.getRecorder() != null){
				QCAndroid.getRecorder().stop(); 
				QCAndroid.getRecorder().release();
				QCAndroid.setRecorder(null);
			}

			File soundFile = new File("/sdcard/"+fileName+".3gp");
			Log.e(QCAndroid.LOG_TAG, " recording /sdcard/"+fileName+".3gp exists: "+soundFile.exists());
			if(soundFile.exists()){
				soundFile.delete();
			}
			MediaRecorder recorder = new MediaRecorder();
			QCAndroid.setRecorder(recorder);
		    
		    recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
		    recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
		    recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

			recorder.setOutputFile("/sdcard/"+fileName+".3gp");
		    
		    try {
				recorder.prepare();
			    recorder.start();
			} catch (Exception e) {
				Log.e(QCAndroid.LOG_TAG, "Unable to record: "+e.getCause()+" "+e.getLocalizedMessage());
			}
		}
		else if(QCAndroid.getRecorder() != null){
			Log.e(QCAndroid.LOG_TAG, "stopping recording");
			QCAndroid.getRecorder().stop(); 
			QCAndroid.getRecorder().release();
			QCAndroid.setRecorder(null);
		}
		return null;
	}
}
