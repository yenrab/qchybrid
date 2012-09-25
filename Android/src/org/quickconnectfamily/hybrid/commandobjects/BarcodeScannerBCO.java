package org.quickconnectfamily.hybrid.commandobjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.app.AlertDialog;

//import com.google.zxing.integration.android.IntentIntegrator;

public class BarcodeScannerBCO implements ControlObject{

	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		/*
		 * This code is commented out since zebra crossing is not integrated yet.
		 *
		ArrayList passedParameters = (ArrayList)parameters.get("parameters");
		ArrayList<String> stackIdentifier = (ArrayList<String>) passedParameters.get(0);
		if(QCAndroid.getInstance().barcodeStackId == null){
		QCAndroid.getInstance().barcodeStackId = stackIdentifier;
		AlertDialog scanIt = IntentIntegrator.initiateScan(QCAndroid.getInstance());
		}
		else{
			try {
				throw new Exception();
			} catch (Exception e) {
				System.out.println("Only one BarcodeScanner is allowed at once.");
				e.printStackTrace();
			}
		}
	*/
	return null;
	}
}
