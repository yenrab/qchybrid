package org.quickconnectfamily.hybrid;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashMap;

import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.widget.FrameLayout;

public class QCViewGroup extends FrameLayout {

	int settingsHashCode = 0;
	HashMap<String, Object> currentSettings;
	
	public QCViewGroup(QCAndroid context, HashMap<Object, Object> settings) {
		super(context);
		
	}
	
	public Object configure(HashMap<String,Object> settings) {
		
		int newSettingsHashCode = settings.toString().hashCode();
		if (currentSettings != null) {
			int oldSettingsHashCode = settingsHashCode;
			HashMap<String, Object> oldSettings = currentSettings;
			if ((newSettingsHashCode == oldSettingsHashCode) || oldSettings.equals(settings)) {
				System.out.println("Tried to set settings, but they were the same as the previous settings. QCViewGroup");
				return true; // The settings are exactly the same, so we shouldn't change it
			}
		}
		
		this.setLayoutParams(LayoutParamsFactory.build(settings));
		
		String color = (String) settings.get("backgroundColor");
		if(color != null){
			if(color.equals("clear") || color.equals("transparent")){
				this.setBackgroundColor(Color.TRANSPARENT);
			}
			else if(color.equals("white")){
				this.setBackgroundColor(Color.WHITE);
			}
			else if(color.equals("black")){
				this.setBackgroundColor(Color.BLACK);
			}
		}
		
		//this.setBackgroundColor(0x8000ff00);
		
		String bg = (String) settings.get("background");
		if(bg != null && bg != ""){
			try{
				InputStream bitMapInputStream = null;
				if(bg.startsWith("file://")){
					URI bgURI = new URI(bg);
					File bgRef = new File(bgURI);
					bitMapInputStream = new FileInputStream(bgRef);
				}
				else{
					URL bgURL = new URL(bg);
					URLConnection aConnection = bgURL.openConnection();
					bitMapInputStream = new BufferedInputStream(aConnection.getInputStream());
				}
				Drawable background = null;
				try {
					Constructor<BitmapDrawable> thePreferredConstructor = BitmapDrawable.class.getDeclaredConstructor(Resources.class, InputStream.class);
					background = thePreferredConstructor.newInstance(QCAndroid.getInstance().getResources(),bitMapInputStream);
					//background = new BitmapDrawable(QCAndroid.getInstance().getResources(),bitMapInputStream);
				} catch (Exception e) {
					background = new BitmapDrawable(bitMapInputStream);
				}
				this.setBackgroundDrawable(background);
			}
			catch(Exception e){
				System.out.println( "Problem with background: " + bg);
				//return null;
			}
		}

		Integer newVisibility = determineVisibility((String)settings.get("visibility"));
		if (newVisibility != this.getVisibility()) {
			this.setVisibility(newVisibility);
		}
		
		settingsHashCode = newSettingsHashCode; // We finished successfully, so set our new hash code
		currentSettings = settings;
		
		// return something to indicate that it finished.
		return true;
	}

	private Integer determineVisibility(String aString) {
		// The following URL explains these integer constants
		// http://developer.android.com/reference/android/view/View.html#attr_android:visibility
		if (aString == null) {
			return 0;
		}
		
		if (aString.equals("invisible")) {
			return 1;
		}
		else if (aString.equals("gone")) {
			return 2;
		}
		
		return 0; 
	}
}
