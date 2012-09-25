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
package org.quickconnectfamily.hybrid;

import org.quickconnect.QuickConnect;
import org.quickconnectfamily.hybrid.commandobjects.AddViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.AnimateViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.BarcodeScannerBCO;
import org.quickconnectfamily.hybrid.commandobjects.CacheResourcesBCO;
import org.quickconnectfamily.hybrid.commandobjects.ChangeSplashVCO;
import org.quickconnectfamily.hybrid.commandobjects.CloseAppVCO;
import org.quickconnectfamily.hybrid.commandobjects.ExecuteDBScriptBCO;
import org.quickconnectfamily.hybrid.commandobjects.FindOrCreateViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.GetDataBCO;
import org.quickconnectfamily.hybrid.commandobjects.GetDeviceIDVCO;
import org.quickconnectfamily.hybrid.commandobjects.GetDeviceInfoVCO;
import org.quickconnectfamily.hybrid.commandobjects.GetRequestBCO;
import org.quickconnectfamily.hybrid.commandobjects.GetUUIDVCO;
import org.quickconnectfamily.hybrid.commandobjects.InvalidCmdECO;
import org.quickconnectfamily.hybrid.commandobjects.LocationBCO;
import org.quickconnectfamily.hybrid.commandobjects.LoggingVCO;
import org.quickconnectfamily.hybrid.commandobjects.ModifyViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.NetworkStatusBCO;
import org.quickconnectfamily.hybrid.commandobjects.PlayAudioVCO;
import org.quickconnectfamily.hybrid.commandobjects.PlaySoundVCO;
import org.quickconnectfamily.hybrid.commandobjects.PostRequestBCO;
import org.quickconnectfamily.hybrid.commandobjects.RecordAudioVCO;
import org.quickconnectfamily.hybrid.commandobjects.RegisterNativeEventBCO;
import org.quickconnectfamily.hybrid.commandobjects.RemoveViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.ReplaceViewVCO;
import org.quickconnectfamily.hybrid.commandobjects.SendCacheResourcesResultVCO;
import org.quickconnectfamily.hybrid.commandobjects.SendDBResultVCO;
import org.quickconnectfamily.hybrid.commandobjects.SendHTTPResultVCO;
import org.quickconnectfamily.hybrid.commandobjects.SetDataBCO;
import org.quickconnectfamily.hybrid.commandobjects.TransactionHandlerBCO;
import org.quickconnectfamily.hybrid.commandobjects.UrlCheckValCO;
import org.quickconnectfamily.hybrid.commandobjects.ValidationFailECO;
import org.quickconnectfamily.hybrid.commandobjects.VibrateVCO;
import org.quickconnectfamily.hybrid.commandobjects.ViewDoesNotExistValCO;
import org.quickconnectfamily.hybrid.commandobjects.ViewExistsValCO;

public class QCCommandMappings {

	private static boolean beenMapped = false;
	public static void mapCommands(){
		if(!beenMapped){
			beenMapped = true;
			QuickConnect.mapCommandToVCO("vibrate", VibrateVCO.class);

			QuickConnect.mapCommandToVCO("playSound", PlaySoundVCO.class);

			QuickConnect.mapCommandToVCO("play", PlayAudioVCO.class);
			QuickConnect.mapCommandToVCO("rec", RecordAudioVCO.class);

			// Why is LoggingVCO a VCO? Because it changes the system console, which can be thought of as a view?
			// But it isn't a View and writing to the console is not something that needs to happen on the
			// UI thread. This puts a huge performance penalty on logging. (Which might encourage us to disable 
			// logging in a release app, which is a good idea.)
			QuickConnect.mapCommandToVCO("logMessage", LoggingVCO.class);

			QuickConnect.mapCommandToBCO("handleTransactionRequest", TransactionHandlerBCO.class);
			QuickConnect.mapCommandToVCO("handleTransactionRequest", SendDBResultVCO.class);

			QuickConnect.mapCommandToBCO("getData", GetDataBCO.class);
			QuickConnect.mapCommandToVCO("getData", SendDBResultVCO.class);

			QuickConnect.mapCommandToBCO("setData", SetDataBCO.class);
			QuickConnect.mapCommandToVCO("setData", SendDBResultVCO.class);
	
			QuickConnect.mapCommandToVCO("loc", LocationBCO.class);

			QuickConnect.mapCommandToECO("valfail", ValidationFailECO.class);

			QuickConnect.mapCommandToECO("nocmdList", InvalidCmdECO.class);

			QuickConnect.mapCommandToVCO("sendDeviceDescription", GetDeviceInfoVCO.class);

			QuickConnect.mapCommandToBCO("runDBScript", ExecuteDBScriptBCO.class);
			QuickConnect.mapCommandToVCO("runDBScript", SendDBResultVCO.class);

			QuickConnect.mapCommandToValCO("httpGet", UrlCheckValCO.class);
			QuickConnect.mapCommandToBCO("httpGet", GetRequestBCO.class);
			QuickConnect.mapCommandToVCO("httpGet", SendHTTPResultVCO.class);

			QuickConnect.mapCommandToValCO("httpPost", UrlCheckValCO.class);
			QuickConnect.mapCommandToBCO("httpPost", PostRequestBCO.class);
			
			QuickConnect.mapCommandToValCO("add_view", ViewDoesNotExistValCO.class);
			QuickConnect.mapCommandToVCO("add_view", AddViewVCO.class);
			QuickConnect.mapCommandToVCO("add_view", ModifyViewVCO.class);
			
			QuickConnect.mapCommandToVCO("modify_view", FindOrCreateViewVCO.class);
			QuickConnect.mapCommandToVCO("modify_view", ModifyViewVCO.class);

			QuickConnect.mapCommandToVCO("replace_view", FindOrCreateViewVCO.class);
			QuickConnect.mapCommandToVCO("replace_view", ReplaceViewVCO.class);
			
			QuickConnect.mapCommandToValCO("modify_existing_view", ViewExistsValCO.class);
			QuickConnect.mapCommandToVCO("modify_existing_view", ModifyViewVCO.class);

			QuickConnect.mapCommandToValCO("remove_view", ViewExistsValCO.class);
			QuickConnect.mapCommandToVCO("remove_view", RemoveViewVCO.class);
			
			QuickConnect.mapCommandToValCO("animateView", ViewExistsValCO.class);
			QuickConnect.mapCommandToVCO("animateView", AnimateViewVCO.class);
			
			QuickConnect.mapCommandToVCO("networkStatus", NetworkStatusBCO.class);
			
			QuickConnect.mapCommandToVCO("handleEvent", RegisterNativeEventBCO.class);	
			
			QuickConnect.mapCommandToBCO("cacheResources", CacheResourcesBCO.class);
			QuickConnect.mapCommandToVCO("cacheResources", SendCacheResourcesResultVCO.class);
			
			QuickConnect.mapCommandToVCO("get_UUID", GetUUIDVCO.class);
			
			QuickConnect.mapCommandToVCO("get_DeviceId", GetDeviceIDVCO.class);
			
			QuickConnect.mapCommandToBCO("read_QRCode", BarcodeScannerBCO.class);
			
			QuickConnect.mapCommandToVCO("exit", CloseAppVCO.class);
			
			QuickConnect.mapCommandToValCO("change_app_background", ChangeSplashVCO.class);
		}
	}
}
