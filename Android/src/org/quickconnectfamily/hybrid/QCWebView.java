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
import java.util.UUID;

import org.quickconnectfamily.hybrid.QCAndroid;

import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebView;

public class QCWebView extends WebView {
	WebView mainView;
	HashMap<String,Object> eventsRegister;
	String uJsListenerId;
	String bodyText;
	int settingsHashCode;
	HashMap<String, Object> currentSettings;
	public QCWebView(QCAndroid context, HashMap<Object, Object> settings) {
		super(context);
		uJsListenerId = UUID.randomUUID().toString();  // generate a unique id to authenticate any URLs set by javascript for our event Listeners
		eventsRegister = new HashMap<String,Object>();
		bodyText = null;
		/*
		JavaScriptCallHandler myJavaScriptCallHandler = JavaScriptCallHandler.getInstance();
		//myJavaScriptCallHandler.setTheActivity(this);
		this.addJavascriptInterface(myJavaScriptCallHandler,
				"qcNative");
		*/
		this.getSettings().setJavaScriptEnabled(true);
		this.setWebViewClient(new QCWebViewClient());
		this.setWebChromeClient(new QCWebViewChromeClient(settings.get("id")+" Console")); // show console.log from child web views, tagged as "<View ID> Console"
	}

	@SuppressWarnings("unchecked")
	public Object configure(HashMap<String,Object> settings) {
		int newSettingsHashCode = settings.toString().hashCode();
		this.requestFocus(View.FOCUS_DOWN);
        this.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
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
		if (currentSettings != null) {
			int oldSettingsHashCode = settingsHashCode;
			HashMap<String, Object> oldSettings = currentSettings;
			if ((newSettingsHashCode == oldSettingsHashCode) || oldSettings.equals(settings)) {
				System.out.println("Tried to set settings, but they were the same as the previous settings. QCWebView");
				return true; // The settings are exactly the same, so we shouldn't change it
			}
		}
		
		System.out.println("Started configure.");
		
		this.setLayoutParams(LayoutParamsFactory.build(settings));
		
		if(settings.get("html") != null && settings.get("url") == null){
			String htmlData = (String) settings.get("html");
			Uri.encode(htmlData);
			this.loadData(htmlData, "text/html", "utf-8");
		}
		else if(settings.get("html") != null && settings.get("url") != null){
			String htmlData = (String) settings.get("html");
			String url = (String) settings.get("url");
			Uri.encode(htmlData);
			this.loadDataWithBaseURL(url, htmlData, "text/html", "utf-8", null);
		}
		else if( settings.get("url") != null ){
				this.loadUrl((String)settings.get("url"));
				System.out.println( "Loading url: "+(String)settings.get("url") );
				
				// insert body if needed
				if( settings.get("body") != null ){
					bodyText = (String) settings.get("body");
					System.out.println("Found this body text: " + bodyText);
				}
				else{
					System.out.println("No body text to set with URL.");				
				}
		}else{
				System.out.println( "Could not get url to load." );
		}
		
		String scrollbars = (String) settings.get("scrollbars");
		if(scrollbars != null){
			this.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
			if(scrollbars.contains("x")){
				this.setHorizontalScrollBarEnabled(true);
			}
			else{
				this.setHorizontalScrollBarEnabled(false);
			}
			if(scrollbars.contains("y")){
				this.setVerticalScrollBarEnabled(true);
			}
			else{
				this.setVerticalScrollBarEnabled(false);
			}
		}
		String zoomable = (String) settings.get("zoomable");
		if(zoomable != null){
				this.getSettings().setSupportZoom(Boolean.parseBoolean(zoomable));
		}
		String zoomcontrols = (String) settings.get("showZoomControls");
		if(zoomcontrols != null){
				this.getSettings().setBuiltInZoomControls(Boolean.parseBoolean(zoomcontrols));
		}
		String clickable = (String) settings.get("clickable");
		if(clickable != null){
			this.setClickable(Boolean.parseBoolean(clickable));
		}
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
					URLConnection theConnection = bgURL.openConnection();
					backgroundStream = new BufferedInputStream(theConnection.getInputStream());
				}
				Drawable background = null;
				try {
					Constructor<BitmapDrawable> thePreferredConstructor = BitmapDrawable.class.getDeclaredConstructor(Resources.class, InputStream.class);
					background = thePreferredConstructor.newInstance(QCAndroid.getInstance().getResources(),backgroundStream);
					//background = new BitmapDrawable(QCAndroid.getInstance().getResources(),bitMapInputStream);
				} catch (Exception e) {
					background = new BitmapDrawable(backgroundStream);
				}
				this.setBackgroundDrawable(background);
			}
			catch(Exception e){
				System.out.println( "Problem with background: " + bg);
				//return null;
				
			}
		}
		if(settings.get("eventHandlers") != null){
			eventsRegister = new HashMap<String, Object>((HashMap<String, Object>) settings.get("eventHandlers"));
		}
		
		Integer newVisibility = determineVisibility((String)settings.get("visibility"));
		if (newVisibility != this.getVisibility()) {
			this.setVisibility(newVisibility);
		}
		
		settingsHashCode = newSettingsHashCode; // We finished successfully, so set our new hash code
		currentSettings = settings;
		
		// return true, to indicate we hit the end without errors.
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
