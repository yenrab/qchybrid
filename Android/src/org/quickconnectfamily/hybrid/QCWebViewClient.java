package org.quickconnectfamily.hybrid;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;

import org.json.JSONArray;

import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class QCWebViewClient extends WebViewClient {
	// Assume that we assigned just the settings portion to the settings
	// contained in here.
	@Override
	public boolean shouldOverrideUrlLoading(WebView view, String url) {
		QCWebView temp = (QCWebView) view;
		try {
			System.out.println("URL of child QCWebView changed to: "
					+ URLDecoder.decode(url, "utf-8"));
		} catch (Exception e) {
			System.out.println("URL of child QCWebView changed.");
		}
		try {
			Boolean watchURL = false;
			if (temp.eventsRegister.containsKey("urlchange")
					&& !url.startsWith("javascript:")
					&& !url.startsWith("native:")) {
				String urlCommandStack = (String) temp.eventsRegister
						.get("urlchange");
				String aJSCallString = new String(
						"javascript:handleJSONRequest('" + urlCommandStack
								+ "', [" + view.getTag() + ", " + url + "]);");
				QCAndroid.getWebView().loadUrl(aJSCallString);
				watchURL = true;
			}

			if (temp.eventsRegister.containsKey("tap")) {
				try {
					System.out.println("Checking for tap.");

					HashMap<String, Object> tapHandler = new HashMap(
							(HashMap<String, Object>) temp.eventsRegister
									.get("tap"));

					String urlCommandStack = (String) tapHandler.get("command");
					// parse URL query string
					// check if it starts with "native:"
					// then has temp.uJsListenerId
					// then has "/tap?requestedValue="
					// and finally, the value that corresponds to
					// tapHandler.get("get")
					String tapPrefix = "native:" + temp.uJsListenerId
							+ "/tap?requestedValue=";
					if (url.startsWith(tapPrefix)) {
						System.out.println("Tap recognized.");

						String jsRVal = url.replace(tapPrefix, "");
						String viewTag = (String) view.getTag();
						JSONArray jsCmdParameters = new JSONArray();
						jsCmdParameters.put(viewTag);
						jsCmdParameters.put(jsRVal);
						String aJSONString = jsCmdParameters.toString();

						String aJSCallString = new String(
								"javascript:handleJSONRequest('"
										+ urlCommandStack + "', '["
										+ aJSONString + "]');");
						System.out.println("Sending to main webView: "
								+ aJSCallString);

						WebView primary = QCAndroid.getWebView();
						primary.loadUrl(aJSCallString);
						watchURL = true;
					}
				} catch (Exception badTypeCast) {

				}
			}
			/*
			 * if(temp.eventsRegister.containsKey("urlchange")){ String
			 * urlCommandStack = (String) temp.eventsRegister.get("urlchange");
			 * String aJSCallString = new
			 * String("javascript:handleJSONRequest('"+ urlCommandStack +"', ["+
			 * view.getTag() +", "+ url+"]);");
			 * QCAndroid.getWebView().loadUrl(aJSCallString); watchURL = true; }
			 */
			return watchURL;
		} catch (Exception e) {
			System.out.println(e.getMessage());
			return false;
		}

	}

	public void onPageStarted(WebView view, String url, Bitmap favicom) {
		QCWebView temp = (QCWebView) view;
		System.out.println("QCWebView started loading: " + url);
	}

	public void onPageFinished(WebView view, String url) {
		QCWebView temp = (QCWebView) view;
		System.out.println("QCWebView loaded: " + url);

		// insert body if needed
		if (temp.bodyText != null && !url.startsWith("javascript:")
				&& !url.startsWith("native:")) {
			Log.d(temp.currentSettings.get("id")+" Console","NATIVE LOG| Adding specified body text: " + temp.bodyText);
			System.out.println(temp.currentSettings.get("id")+": Adding specified body text. " + temp.bodyText);
			try {
				String jsURL = new String(
						"javascript:document.body.innerHTML=decodeURIComponent( \"" + temp.bodyText
								+ "\" ); console.log('New body content loaded: '+document.body.innerHTML);");
				temp.loadUrl(jsURL);
			} catch (Exception e) {
				System.out.println("Could not encode bodyText as utf-8.");
			}
		}

		if (temp.eventsRegister.containsKey("tap")
				&& !url.startsWith("javascript:") && !url.startsWith("native:")) {
			try {
				HashMap<String, Object> tapHandler = new HashMap(
						(HashMap<String, Object>) temp.eventsRegister
								.get("tap"));
				// set tap event listener

				// by inserting javascript in to new webView that generates a
				// special URL when watched items are tapped
				String domSelector = (String) tapHandler.get("watch");
				String requestVariable = (String) tapHandler.get("get");
				String tapJavascript = "javascript:"
						+
						// "window.location.href='native:test.html?'+document.body.innerHTML;"
						// +
						"var qcItems = document.querySelectorAll(\""
						+ domSelector
						+ "\");"
						+ "var qcNum = qcItems.length;"
						+ "for(var qcCnt=0; qcCnt < qcNum; qcCnt++){"
						+
						// " qcItems[qcCnt].addEventListener('touchend', function(event){"+
						" qcItems[qcCnt].addEventListener('click', function(event){"
						+ "console.log('Tap on "+domSelector+" with "+requestVariable+" '+"+requestVariable+");"
						+ "window.location.href = 'native:"
						+ temp.uJsListenerId + "/tap?requestedValue='+"
						+ requestVariable + ";" + "}, false);"
						+ "}" + "";

				System.out.println(tapJavascript);
				temp.loadUrl(tapJavascript);
			} catch (Exception badTypeCast) {

			}
		}

		return;
	}
}
