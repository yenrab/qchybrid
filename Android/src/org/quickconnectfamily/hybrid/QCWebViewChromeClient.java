package org.quickconnectfamily.hybrid;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;

import org.json.JSONArray;

import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class QCWebViewChromeClient extends WebChromeClient {
	  private String consoleIdentifier;
	  
	  public QCWebViewChromeClient(String cIdentifier){
		  consoleIdentifier = cIdentifier;
	  }
	  
	  public QCWebViewChromeClient(){
		  consoleIdentifier = "QC Hybrid - console.log";
	  }
	  
	  
	  public void onConsoleMessage(String message, int lineNumber, String sourceID) {
		    Log.d( consoleIdentifier, message );
/*
 		    Log.d( consoleIdentifier, message + " -- From line "
		                         + lineNumber + " of "
		                         + sourceID);
*/
		  }
	  /*
	  // For 2.2 (API level 8) and later
	  public boolean onConsoleMessage(ConsoleMessage cm) {
		    Log.d("MyApplication", cm.message() + " -- From line "
		                         + cm.lineNumber() + " of "
		                         + cm.sourceId() );
		    return true;
		  }
	  */
}