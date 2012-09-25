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

import android.location.Location;
import android.location.LocationManager;
import android.util.Log;

public class LocationBCO  implements ControlObject{

	public Object handleIt(HashMap<String,Object> parametersMap){

		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
	
		try {
			String flag = (String) parameters.get(0);
			if(flag.equals("on")){
				Log.d(QCAndroid.LOG_TAG, "Getting GPS location data");
				QCAndroid.getLocationManager().requestLocationUpdates(
						LocationManager.GPS_PROVIDER, 60000, 10,
						QCAndroid.getInstance());
				QCAndroid.getLocationManager().requestLocationUpdates(
						LocationManager.NETWORK_PROVIDER, 60000, 10, 
						QCAndroid.getInstance());
				//Send back the current Location:
				Location lastGPSLocation = QCAndroid.getLocationManager().getLastKnownLocation(LocationManager.GPS_PROVIDER);
				Location lastNetLocation = QCAndroid.getLocationManager().getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
				Location lastLocation;
				if(LocationBCO.isBetterLocation(lastGPSLocation, lastNetLocation)){
					lastLocation = lastGPSLocation;
				}
				else{
					lastLocation = lastNetLocation;
				}
				double lat = lastLocation.getLatitude();
				double lon = lastLocation.getLongitude();
				double alt = lastLocation.getAltitude();
				String JSONParams = "[{\"latitude\":"
						+ lat + ",\"longitude\":" + lon + ",\"altitude\":" + alt + "}]";
				String aJSCallString = "javascript:setTimeout(\"handleJSONRequest('UpdateLocation','" + JSONParams + "')\", 1);";	
				QCAndroid.getWebView().loadUrl(aJSCallString);
			}
			else{
				Log.d(QCAndroid.LOG_TAG,
						"Done getting GPS location data");
				QCAndroid.getLocationManager().removeUpdates(QCAndroid.getInstance());
			}
		} catch (Exception e) {
			Log.d(QCAndroid.LOG_TAG,"Error getting parameters.");
		}
		return null;
	}
	private static final int TWO_MINUTES = 1000 * 60 * 2;

	/** Determines whether one Location reading is better than the current Location fix
	  * @param location  The new Location that you want to evaluate
	  * @param currentBestLocation  The current Location fix, to which you want to compare the new one
	  */
	public static boolean isBetterLocation(Location location, Location currentBestLocation) {
	    if (currentBestLocation == null) {
	        // A new location is always better than no location
	        return true;
	    }

	    // Check whether the new location fix is newer or older
	    long timeDelta = location.getTime() - currentBestLocation.getTime();
	    boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
	    boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
	    boolean isNewer = timeDelta > 0;

	    // If it's been more than two minutes since the current location, use the new location
	    // because the user has likely moved
	    if (isSignificantlyNewer) {
	        return true;
	    // If the new location is more than two minutes older, it must be worse
	    } else if (isSignificantlyOlder) {
	        return false;
	    }

	    // Check whether the new location fix is more or less accurate
	    int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation.getAccuracy());
	    boolean isLessAccurate = accuracyDelta > 0;
	    boolean isMoreAccurate = accuracyDelta < 0;
	    boolean isSignificantlyLessAccurate = accuracyDelta > 200;

	    // Check if the old and new location are from the same provider
	    boolean isFromSameProvider = isSameProvider(location.getProvider(),
	            currentBestLocation.getProvider());

	    // Determine location quality using a combination of timeliness and accuracy
	    if (isMoreAccurate) {
	        return true;
	    } else if (isNewer && !isLessAccurate) {
	        return true;
	    } else if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider) {
	        return true;
	    }
	    return false;
	}

	/** Checks whether two providers are the same */
	private static boolean isSameProvider(String provider1, String provider2) {
	    if (provider1 == null) {
	      return provider2 == null;
	    }
	    return provider1.equals(provider2);
	}
	
}
