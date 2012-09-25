/*
 Copyright (c) 2008, 2009, 2011 Lee Barney
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

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.quickconnectfamily.hybrid.commandobjects.LocationBCO;

import com.google.android.maps.MapActivity;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorListener;
import android.hardware.SensorManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.Toast;

public class QCAndroid extends MapActivity implements LocationListener,
		SensorListener {
	public static final String LOG_TAG = "QuickConnect Hybrid";
	private static WebView webView;
	public FrameLayout layout; 
	private static QCAndroid self;
	private static LocationManager gpsManager;
	private SensorManager sensorManager;
	private static HashMap<String, MediaPlayer> soundMap;
	private static MediaRecorder recorder;
	private static MediaPlayer player;
	private static HashMap<String, String> jsNativeEventsRegister;
	private static Dialog dialog;
	public static ArrayList<String> barcodeStackId;
	public static HashMap<String,HashMap> viewStorage;
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		
		Log.d(QCAndroid.LOG_TAG, "bundle: "+savedInstanceState);
		getWindow().requestFeature(Window.FEATURE_NO_TITLE);
		layout = new FrameLayout(this);
		LayoutParams p = new LayoutParams(android.view.ViewGroup.LayoutParams.FILL_PARENT, 
				android.view.ViewGroup.LayoutParams.FILL_PARENT);
		layout.setLayoutParams(p);
		setContentView(layout);
		layout.setBackgroundDrawable(getResources().getDrawable(R.drawable.splash));
		QCCommandMappings.mapCommands();
		if (self == null) {
			self = this;
		}
		viewStorage = new HashMap<String,HashMap>();
		/*
		 * Set up our supported native events in the jsNativeEventsRegister
		 */
		jsNativeEventsRegister = new HashMap<String, String>();
		try{
			System.out.println("Attempting to specify suported native events.");
			jsNativeEventsRegister.put("configChanged", "__available__"); 
			jsNativeEventsRegister.put("appPause", "__available__"); 
			jsNativeEventsRegister.put("appResume", "__available__"); 
			jsNativeEventsRegister.put("appStart", "__available__"); 
			jsNativeEventsRegister.put("backButton", "__available__"); 
			jsNativeEventsRegister.put("menuButton", "__available__"); 
		}catch(Exception e){
			String message = "Unable to specify suported native events. ";
			if (e.getMessage() != null) {
				message += e.getMessage();
			}
			System.out.println( message );
		}
		
		try {
			Class<?> RClass = Class.forName(this.getClass().getPackage().getName()+".R");
			Class<?>[] innerClasses = RClass.getDeclaredClasses();
			for(Class<?> aClass : innerClasses){
				if(aClass.getName().endsWith("raw")){
					soundMap = new HashMap<String, MediaPlayer>();
					Field[] allFields = aClass.getDeclaredFields();
					for (int i = 0; i < allFields.length; i++) {
						Field anAudioFile = allFields[i];
						int audioFileId = 0;
						audioFileId = anAudioFile.getInt(null);

						MediaPlayer mp = MediaPlayer.create(this, audioFileId);
						soundMap.put(anAudioFile.getName(), mp);
					}
					
				}
			}
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		QCViewsPlugin.init();
		webView = new WebView(this);
		webView.setLayoutParams(p);
		WebSettings theSettings = webView.getSettings();
		try {
			Method geoLocationEnabler = WebSettings.class.getDeclaredMethod("setGeolocationEnabled", boolean.class);
			if(geoLocationEnabler != null){
				geoLocationEnabler.invoke(theSettings, true);
			}
		} catch (Exception e1) {
			System.out.println("Geo Location is not available in this version of Android.  If you want Geo Location you must use at least version 2.1");
		}
        
        try{
        	Method databaseEnabler = WebSettings.class.getDeclaredMethod("setDatabaseEnabled", boolean.class);
        	if(databaseEnabler != null){
	            Method domStorageEnabler = WebSettings.class.getDeclaredMethod("setDomStorageEnabled", boolean.class);
	
	            if(domStorageEnabler != null){
	                databaseEnabler.invoke(theSettings, true);
	                String databasePath = this.getApplicationContext().getDir("database", QCAndroid.MODE_PRIVATE).getPath();
	                Method databasePathSetter = WebSettings.class.getDeclaredMethod("setDatabasePath", String.class);
	                databasePathSetter.invoke(theSettings, databasePath);
	                domStorageEnabler.invoke(theSettings, true);
	            }
        	}
        }
        catch (Exception e2){
        	Toast t2 = Toast.makeText(this, "DOM storage failed: "+e2.getMessage(), Toast.LENGTH_LONG);
         	t2.show();
			System.out.println("DOM storage is not available in this version of Android.  If you want DOM storage you must use at least version 4.0");
        }
		layout.addView(webView);

		System.out.println("webView: "+webView);
		webView.requestFocus(View.FOCUS_DOWN);
		webView.setOnTouchListener(new View.OnTouchListener() {
	        public boolean onTouch(View v, MotionEvent event) {
                System.out.println("webView: "+webView);
	            switch (event.getAction()) {
	                case MotionEvent.ACTION_DOWN:
	                case MotionEvent.ACTION_UP:
	                    if (!v.hasFocus()) {
	                        v.requestFocus();
	                    }
	                    break;
	            }
	            return false;
	        }
	    });
		Log.d(QCAndroid.LOG_TAG, "setting up call handler");
		JavaScriptCallHandler theJavaScriptCallHandler = JavaScriptCallHandler.getInstance();
		theJavaScriptCallHandler.setTheActivity(this);
		webView.addJavascriptInterface(theJavaScriptCallHandler,
				"qcDevice");
		Log.d(QCAndroid.LOG_TAG, "call handler set up");
		webView.setWebChromeClient(new QCWebViewChromeClient());
		WebSettings webSettings = webView.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setSupportZoom(true);
		webView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
		
		webView.setBackgroundColor(0);
		Intent myIntent = getIntent();
		String url = myIntent.getStringExtra("url");
		if(url != null){
			webView.loadUrl(url);
		}
		else{
		webView.loadUrl("file:///android_asset/index.html");
		}
		try {
			gpsManager = (LocationManager) getSystemService(QCAndroid.LOCATION_SERVICE);
			sensorManager = (SensorManager) getSystemService(QCAndroid.SENSOR_SERVICE);

			// the value SENSOR_DELAY_GAME is used so that if you want to create
			// games the accelerometer will be
			// sampled at a rate that is appropriate for games. You can change
			// this to lesser rates if it
			// is causing a problem by using to much CPU.
			sensorManager.registerListener(this, Sensor.TYPE_ACCELEROMETER,
					SensorManager.SENSOR_DELAY_GAME);
		} catch (Exception e) {
			String message = "Exception thrown in WebView setup.";
			if (e.getMessage() != null) {
				message = e.getMessage();
			}
			Log.e(QCAndroid.LOG_TAG, message);
		}

	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
	    super.onConfigurationChanged(newConfig);

	    // Checks the orientation of the screen
	    if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
	        //Toast.makeText(this, "landscape", Toast.LENGTH_SHORT).show();
	    } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT){
	        //Toast.makeText(this, "portrait", Toast.LENGTH_SHORT).show();
	    }
	    // Checks whether a hardware keyboard is available
	    if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_NO) {
	    	System.out.println("shown");
	        //Toast.makeText(this, "keyboard visible", Toast.LENGTH_SHORT).show();
	    } else if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_YES) {
	    	System.out.println("hidden");
	        //Toast.makeText(this, "keyboard hidden", Toast.LENGTH_SHORT).show();
	    }
	    
	    // check to see if we have registered a JavaScript native event handler for this event
	    String jsCommand = jsNativeEventsRegister.get("configChanged");
	    if( jsCommand != null && jsCommand != "__available__" ){
	    	// start the JavaScript command stack specified by jsCommand
	    	JSONArray eventParameters = new JSONArray();
			/*
			 *  We'll need to add any information that needs to be passed back to
			 *  JavaScript as a parameter of the command stack here.
			 */
			eventParameters.put("configChanged"); 
	    	String aJSONString = eventParameters.toString();
	    	String aJSCallString = "javascript:handleJSONRequest('"+jsCommand+"', '"+aJSONString+"')";
	    	System.out.println( aJSCallString );
	    	QCAndroid.getWebView().loadUrl(aJSCallString);
	    }
	}

	protected void onPause() {
		super.onPause();
		// Log.d(QCAndroid.LOG_TAG, "Pausing");
		if (gpsManager != null) {
			gpsManager.removeUpdates(this);
			sensorManager.unregisterListener(this);
			// DataAccessObject.closeAll();
		}
		
	    // check to see if we have registered a JavaScript native event handler for this event
	    String jsCommand = jsNativeEventsRegister.get("appPause");
	    if( jsCommand != null && jsCommand != "__available__" ){
	    	// start the JavaScript command stack specified by jsCommand
	    	JSONArray eventParameters = new JSONArray();
			/*
			 *  We'll need to add any information that needs to be passed back to
			 *  JavaScript as a parameter of the command stack here.
			 */
			eventParameters.put("appPause"); 
	    	String aJSONString = eventParameters.toString();
	    	String aJSCallString = "javascript:handleJSONRequest('"+jsCommand+"', '"+aJSONString+"')";
	    	System.out.println( aJSCallString );
	    	QCAndroid.getWebView().loadUrl(aJSCallString);
	    }
	}

	public void onResume() {
		super.onResume();
		// Log.d(QCAndroid.LOG_TAG, "resuming");
		if (sensorManager != null) {
			// the value SENSOR_DELAY_GAME is used so that if you want to create
			// games the accelerometer will be
			// sampled at a rate that is appropriate for games. You can change
			// this to lesser rates if it
			// is causing a problem by using to much CPU.
			sensorManager.registerListener(this,
					SensorManager.SENSOR_ACCELEROMETER,
					SensorManager.SENSOR_DELAY_GAME);
		}
		
	    // check to see if we have registered a JavaScript native event handler for this event
	    String jsCommand = jsNativeEventsRegister.get("appResume");
	    if( jsCommand != null && jsCommand != "__available__" ){
	    	// start the JavaScript command stack specified by jsCommand
	    	JSONArray eventParameters = new JSONArray();
			/*
			 *  We'll need to add any information that needs to be passed back to
			 *  JavaScript as a parameter of the command stack here.
			 */
			eventParameters.put("appResume"); 
	    	String aJSONString = eventParameters.toString();
	    	String aJSCallString = "javascript:handleJSONRequest('"+jsCommand+"', '"+aJSONString+"')";
	    	System.out.println( aJSCallString );
	    	QCAndroid.getWebView().loadUrl(aJSCallString);
	    }
	}
	/*
	 *  This code is here to support zebra crossing.  since it is not yet included I've commented it out.
	 *
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		
		 IntentResult scanResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, intent);
		 if(dialog != null){
			 dialog.dismiss();			 
		 }
		 if (scanResult != null) {
				String scanContents = scanResult.getContents();
				// if we got callback parameters, we need to add in callback to js to tell it the view has been modified 
				try{
					String aJSCallString = null;
					ArrayList<String> stackIdentifier = (ArrayList<String>) barcodeStackId;			
					ArrayList<String> accumulator = new ArrayList<String>(); // for handleRequestCompletionFromNative
					accumulator.add(scanContents);                                 // [0] is my return value
					accumulator.add(stackIdentifier.get(0));                 // [1] is the current js command stack identifier
							
					try {
						aJSCallString = "javascript:handleRequestCompletionFromNative('" +JSONUtilities.stringify(accumulator)+ "')";
					} catch (JSONException e) {
						aJSCallString = "javascript:handleRequestCompletionFromNative()";
					}
					
					QCAndroid.getWebView().loadUrl(aJSCallString); // Send it back!
				} catch( Exception e ){
					System.out.println("No stack identifier found.");
				}
		 }
		 barcodeStackId = null;
		    // else continue with any other code you need in the method
		  }
		  */
	public void onLocationChanged(Location location) {

		if (location == null) {
			location = gpsManager
					.getLastKnownLocation(LocationManager.GPS_PROVIDER);
			Location netLocation = gpsManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
			if(LocationBCO.isBetterLocation(location, netLocation)){
				
			}
			else{
				location = netLocation;
			}
		}
		
		
		double lat = location.getLatitude();
		double lon = location.getLongitude();
		double alt = location.getAltitude();
		String JSONParams = "[{\"latitude\":"
				+ lat + ",\"longitude\":" + lon + ",\"altitude\":" + alt + "}]";
		String aJSCallString = "javascript:handleJSONRequest('UpdateLocation','" + JSONParams + "')";	
		webView.loadUrl(aJSCallString);
		gpsManager.removeUpdates(this);
	}

	public void onProviderDisabled(String provider) {
		// TODO Auto-generated method stub

	}

	public void onProviderEnabled(String provider) {
		// TODO Auto-generated method stub

	}

	public void onStatusChanged(String provider, int status, Bundle extras) {
		// TODO Auto-generated method stub

	}

	public void onAccuracyChanged(int arg0, int arg1) {
		// TODO Auto-generated method stub

	}

	public void onSensorChanged(int sensorID, float[] sensorValues) {
		String aJSCallString = "javascript:";
		if (sensorID == Sensor.TYPE_ACCELEROMETER && sensorValues.length == 3) {
			float xAccel = sensorValues[0];
			float yAccel = sensorValues[1];
			float zAccel = sensorValues[2];
			aJSCallString += "accelerate(" + xAccel + ", " + yAccel + ", "
					+ zAccel + ")";
		}
		// else conditions for sensors other than accelerometer go here
		webView.loadUrl(aJSCallString);
	}

	public static QCAndroid getInstance() {
		return QCAndroid.self;
	}

	public static Boolean registerJsNativeEventHandler(String nativeEvent, String jsCommand) {		
		try{
			// attempt to add the JavaScript command to the Native Event Register for the requested event type
			String currentCommand = jsNativeEventsRegister.get(nativeEvent);
			if( currentCommand != null){
				/*
				 *  If we have a previously registered command, we can register the new one.
				 *  We signify that an event is available to register with the string "__available__".
				 */
				jsNativeEventsRegister.put(nativeEvent, jsCommand);
		    	System.out.println( "Registered event "+ nativeEvent +" to JS command stack "+ jsCommand);
				return true;
			}
			else{
				// we don't allow adding keys for event's we don't have handler code for
				return false;
			}
		}catch(Exception e){
			return false;
		}
	}

	public void addView(View v){
		layout.addView(v);
	}
	public void removeView(View v){
		layout.removeView(v);
	}
	public View getView(String id){	
		if(viewStorage.get(id) != null){
			HashMap viewInfo = viewStorage.get(id);
			View v;
			View p;
			if(((String) viewInfo.get("parent")).length() == 0){
				p = layout;
			}
			else{
				p = this.getView((String) viewInfo.get("parent"));
			}
			if(p == null){
				return null;
			}
			v = p.findViewById((Integer) viewInfo.get("id"));
			return v;
		}	
		 return null;			
	}
	public static WebView getWebView() {
		return QCAndroid.webView;
	}

	public static HashMap<String, MediaPlayer> getSoundMap() {
		return QCAndroid.soundMap;
	}

	public static void setRecorder(MediaRecorder recorder) {
		QCAndroid.recorder = recorder;
	}

	public static MediaRecorder getRecorder() {
		return QCAndroid.recorder;
	}

	public static void setPlayer(MediaPlayer player) {
		QCAndroid.player = player;
	}
	public static void LoadURLMainView(String url){
		webView.loadUrl(url);
	}
	public static MediaPlayer getPlayer() {
		return QCAndroid.player;
	}

	public static LocationManager getLocationManager() {
		return gpsManager;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if ( keyCode == KeyEvent.KEYCODE_BACK ) {
	        // back-button pressed
		    // check to see if we have registered a JavaScript native event handler for this event
		    String jsCommand = jsNativeEventsRegister.get("backButton");
		    if( jsCommand != null && jsCommand != "__available__" ){
		    	// start the JavaScript command stack specified by jsCommand
		    	JSONArray eventParameters = new JSONArray();
				/*
				 *  We'll need to add any information that needs to be passed back to
				 *  JavaScript as a parameter of the command stack here.
				 */
				eventParameters.put("backButton"); 
		    	String aJSONString = eventParameters.toString();
		    	String aJSCallString = "javascript:handleJSONRequest('"+jsCommand+"', '"+aJSONString+"')";
		    	QCAndroid.getWebView().loadUrl(aJSCallString);
		    }
	        return true;
	    }
		else if ( keyCode == KeyEvent.KEYCODE_MENU ) {
	        // menu-button pressed
		    // check to see if we have registered a JavaScript native event handler for this event
		    String jsCommand = jsNativeEventsRegister.get("menuButton");
		    if( jsCommand != null && jsCommand != "__available__" ){
		    	// start the JavaScript command stack specified by jsCommand
		    	JSONArray eventParameters = new JSONArray();
				/*
				 *  We'll need to add any information that needs to be passed back to
				 *  JavaScript as a parameter of the command stack here.
				 */
				eventParameters.put("menuButton"); 
		    	String aJSONString = eventParameters.toString();
		    	String aJSCallString = "javascript:handleJSONRequest('"+jsCommand+"', '"+aJSONString+"')";
		    	QCAndroid.getWebView().loadUrl(aJSCallString);
		    }
	        return true;
	    }
	    return super.onKeyDown(keyCode, event);
	}

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
}