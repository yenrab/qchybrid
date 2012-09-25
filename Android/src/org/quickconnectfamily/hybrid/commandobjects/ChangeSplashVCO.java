package org.quickconnectfamily.hybrid.commandobjects;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

public class ChangeSplashVCO implements ControlObject{

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		ArrayList passedParams = (ArrayList)parameters.get("parameters");
		HashMap settings = (HashMap) passedParams.get(0);
		String color = (String) settings.get("backgroundColor");
		if(color != null){
			if(color.equals("clear") || color.equals("transparent")){
				QCAndroid.getInstance().layout.setBackgroundColor(Color.TRANSPARENT);
			}
			else if(color.equals("white")){
				QCAndroid.getInstance().layout.setBackgroundColor(Color.WHITE);
			}
			else if(color.equals("black")){
				QCAndroid.getInstance().layout.setBackgroundColor(Color.BLACK);
			}
		}
		//this.setBackgroundColor(0x80ff0000);

		String bg = (String) settings.get("background");
		if(bg != null && bg != ""){
			try{
				InputStream backgroundStream = null;
				if(bg.startsWith("file://")){
					URI bgURI = new URI(bg);
					File bgRef = new File(bgURI);
					backgroundStream = new FileInputStream(bgRef);
				}
				else{
					URL bgURL = new URL(bg);
					URLConnection c = bgURL.openConnection();
					backgroundStream = new BufferedInputStream(c.getInputStream());
				}
				Drawable background = null;
				try {
					Constructor<BitmapDrawable> thePreferredConstructor = BitmapDrawable.class.getDeclaredConstructor(Resources.class, InputStream.class);
					background = thePreferredConstructor.newInstance(QCAndroid.getInstance().getResources(),backgroundStream);
					//background = new BitmapDrawable(QCAndroid.getInstance().getResources(),bitMapInputStream);
				} catch (Exception e) {
					background = new BitmapDrawable(backgroundStream);
				}
				QCAndroid.getInstance().layout.setBackgroundDrawable(background);
			}
			catch(Exception e){
				System.out.println( "Problem with background: " + bg);
				//return null;
				
			}
		}
		return null;
	}

}
