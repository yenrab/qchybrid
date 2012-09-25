package org.quickconnectfamily.hybrid.commandobjects;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;

public class UrlCheckValCO implements ControlObject {

	@SuppressWarnings("unchecked")
	public Object handleIt(HashMap<String,Object> parametersMap) {
		ArrayList<Object> parameters = (ArrayList<Object>)parametersMap.get("parameters");
		String urlString = ((String)parameters.get(0)).trim();
		if(urlString.length() == 0){
			return false;
		}
		try {
			URL checkedURL = new URL(urlString);
			parameters.add(parameters.size() - 1,checkedURL);
		} catch (MalformedURLException e) {
			return false;
		}
		return true;
	}

}
