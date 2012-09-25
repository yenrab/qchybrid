package org.quickconnectfamily.hybrid;

import java.util.HashMap;

import org.quickconnect.ControlObject;

public class TestValCO implements ControlObject{

	@Override
	public Object handleIt(HashMap<String, Object> arg0) {
		System.out.println("We made it to the ValCO.");
		return null;
	}

}
