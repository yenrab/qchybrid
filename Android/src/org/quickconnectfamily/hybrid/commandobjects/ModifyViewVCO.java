
package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnect.json.JSONException;
import org.quickconnect.json.JSONUtilities;
import org.quickconnectfamily.hybrid.LayoutParamsFactory;
import org.quickconnectfamily.hybrid.QCAndroid;
import org.quickconnectfamily.hybrid.QCMapView;
import org.quickconnectfamily.hybrid.QCViewGroup;
import org.quickconnectfamily.hybrid.QCWebView;

import android.view.View;

public class ModifyViewVCO implements ControlObject{
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public Object handleIt(HashMap<String, Object> parametersMap) {
        String aJSCallString = null;
		ArrayList passedParameters = (ArrayList)parametersMap.get("parameters");
		HashMap configuration = (HashMap) passedParameters.get(0);
		View viewToModify = (View)parametersMap.get("foundView");
		
		Object cfgReturn = null;
		
		//For now, we're adding config methods to our extended classes, then calling them here.
		if(viewToModify.getClass() == QCWebView.class){
			 cfgReturn = ((QCWebView) viewToModify).configure(configuration);
		}
		else if(viewToModify.getClass() == QCMapView.class){
			((QCMapView) viewToModify).configure(configuration);
			cfgReturn = "true";
		}
		else if(viewToModify.getClass() == QCViewGroup.class){
			cfgReturn = ((QCViewGroup) viewToModify).configure(configuration);
		}
		
		// This code is REALLY slow!
		// Call viewToModify's configure method via reflection
		/*
		Class viewClass = viewToModify.getClass();
		Class parameterTypes[] = new Class[1];
		parameterTypes[0] = configuration.getClass();
		Object cfgReturn = null;
		try{
			Method cfg = viewClass.getMethod("configure", parameterTypes);
			//viewToModify.configure(configuration);
			Object args[] = new Object[1];
			args[0] = configuration;
			cfgReturn = cfg.invoke(viewToModify, args);
		} catch(Exception e){
			// couldn't find configure() or related issue
			System.out.println("No configure method found for requested view.");
		}
		*/
		/* if we got callback parameters, we need to add in callback to js to tell it the view has been modified */
		try{
			ArrayList<String> stackIdentifier = (ArrayList<String>) passedParameters.get(1);
			String status = "true";  // just assume we did really remove the view for now
			if(cfgReturn == null){
				status = "false";
			}
			ArrayList<String> accumulator = new ArrayList<String>(); // for handleRequestCompletionFromNative
			accumulator.add(status);                                 // [0] is my return value
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

		System.out.println("Returning: "+aJSCallString);
		
		return aJSCallString;
	}
}

