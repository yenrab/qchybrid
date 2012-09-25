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
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 
 */


/*
 * the following com functions are facade functions for makeCall 
 * created to simplify sending many common types of messages to 
 * the device.
 */

/*
 *  File management code
 */
qc.writeToFile = function(fileName, fileContentString){
    var dataArray = new Array();
    fileName = qc.replaceAll(fileName, "\n","&nln;");
    fileContentString = qc.replaceAll(fileContentString, "\n","&nln;");
    dataArray.push(fileName);
    dataArray.push(fileContentString);
    qc.makeCall("saveFile",dataArray);	
    
}
window.writeToFile = qc.writeToFile;

qc.remove = function(fileOrDirectoryName){
    if(!fileOrDirectoryName){
        return false;
    }
    var dataArray = new Array();
    dataArray.push(escape(fileOrDirectoryName));
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    //makeCall("deleteFile",JSON.stringify(dataArray));
    makeCall("deleteFile",dataArray);
}
window.remove = qc.remove;

qc.createDirectory = function(directoryName){
    if(!directoryName){
        return false;
    }
    var dataArray = new Array();
    dataArray.push(escape(directoryName));
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    //makeCall("makeDir",JSON.stringify(dataArray));
    makeCall("makeDir",dataArray);
}
window.createDirectory = qc.createDirectory;

qc.listDirContents = function(optionalDirectoryName){
    var dataArray = new Array();
    dataArray.push(escape(optionalDirectoryName));
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    //makeCall("listFiles",JSON.stringify(dataArray));
    makeCall("listFiles",dataArray);
}
window.listDirContents = qc.listDirContents;

qc.getFileContents = function(aFileName){
    
    if(!aFileName){
        return false;
    }
    var dataArray = new Array();
    dataArray.push(aFileName);
    //dataArray.push(escape(aFileName));
    //var callBackParameters = generatePassThroughParameters();
    //dataArray.push(callBackParameters);
    //makeCall("fileContents",JSON.stringify(dataArray));
    makeCall("fileContents",dataArray);
}
window.getFileContents = qc.getFileContents;

qc.displayFile = function(aFileName){
    if(!aFileName){
        return false;
    }
    var dataArray = new Array();
    dataArray.push(escape(aFileName));
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    //makeCall("showFile",JSON.stringify(dataArray));
    makeCall("showFile",dataArray);
}
window.displayFile = qc.displayFile;


/*
 *  iAdd code
 */
qc.designiAd = function(TopBottomOther, optionalPortraitY, optionalLandscapeY){
	var dataArray = new Array();
	dataArray.push("CreateBanner");
	
	if (TopBottomOther.toUpperCase() == "TOP"){
		dataArray.push("0");
	}else if (TopBottomOther.toUpperCase() == "BOTTOM"){
		dataArray.push("1");
	}else if (TopBottomOther.toUpperCase() == "OTHER"){
		dataArray.push("2");
		dataArray.push(optionalPortraitY);
		dataArray.push(optionalLandscapeY);
	}else{
		dataArray.push("0");  // if no param, just put it at the top.
	}
	
	//makeCall("iAd", JSON.stringify(dataArray));
    makeCall("iAd",dataArray);
}
window.designiAd = qc.designiAd;

qc.showiAd = function(){
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push("NO");
	
	//makeCall("iAd", JSON.stringify(dataArray));
    makeCall("iAd",dataArray);
}
window.showiAd = qc.showiAd;

qc.hideiAd = function(){
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push("YES");
	
	//makeCall("iAd", JSON.stringify(dataArray));
    makeCall("iAd",dataArray);
}
window.hideiAd = qc.hideiAd;

/*
 * manipulate the Activity Indicator
 */
qc.turnOffActivityIndicator = function(){
	makeCall("switchActivityIndicator", "NO");
}
window.turnOffActivityIndicator = qc.turnOffActivityIndicator;

qc.turnOnActivityIndicator = function(){
	makeCall("switchActivityIndicator", "YES");
}
window.turnOffActivityIndicator = qc.turnOffActivityIndicator;

/*
 * manipulate the Network Indicator
 */
qc.turnOffNetworkIndicator = function(){
	makeCall("switchNetworkIndicator", "NO");
}
window.turnOffNetworkIndicator = qc.turnOffNetworkIndicator;

qc.turnOnNetworkIndicator = function(){
	makeCall("switchNetworkIndicator", "YES");
}
window.turnOnNetworkIndicator = qc.turnOnNetworkIndicator;


/*
 * manipulate the accelerometer
 */
qc.turnOffAccelerometer = function(){
	makeCall("switchAccelerometer", "NO");
}
window.turnOffAccelerometer = qc.turnOffAccelerometer;

qc.turnOnAccelerometer = function(){
	makeCall("switchAccelerometer", "YES");
}
window.turnOnAccelerometer = qc.turnOnAccelerometer;


/*
 * manipulate the built-in compass
 */
qc.turnOffCompass = function(){
	makeCall("switchHeading", "NO");
}
window.turnOffCompass = qc.turnOffCompass;

qc.turnOnCompass = function(){
	makeCall("switchHeading", "YES");
}
window.turnOnCompass = qc.turnOnCompass;

/*
 * manipulate auto rotation
 */
turnOffAutoRotation = function(){
	makeCall("switchAutoRotation", "NO");
}

qc.turnOnAutoRotation = function(){
	makeCall("switchAutoRotation", "YES");
}
window.turnOnAutoRotation = qc.turnOnAutoRotation;

/*
 * Tab Bar functions
 */
var itemArray = new Array();

qc.addTabItem = function(Title, Image){
	var dataArray = new Array();
	dataArray.push(Title);
	dataArray.push(Image);
	
	itemArray.push(dataArray);
}
window.addTabItem = window.addTabItem;

qc.makeTabBar = function(X,Y,Width,Height){
	var dataArray = new Array();
	dataArray.push(X);
	dataArray.push(Y);
	dataArray.push(Width);
	dataArray.push(Height);
	dataArray.push(itemArray);
	
	//makeCall("designTabBar", JSON.stringify(dataArray));
    makeCall("designTabBar",dataArray);
}
window.makeTabBar = qc.makeTabBar;

qc.showTabBar = function(){
	makeTabBar("setHidden","NO");
}
window.showTabBar = qc.showTabBar;

qc.hideTabBar = function(){
	makeTabBar("setHidden","YES");
}
window.hideTabBar = qc.hideTabBar;

/*
 * Native Switch functions
 */

qc.makeSwitch = function(uniqueSwitchID,X,Y,Width,Height, defaultState){
	
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("CreateSwitch");
	dataArray.push(uniqueSwitchID);	
	dataArray.push(X);
	dataArray.push(Y);
	dataArray.push(Width);
	dataArray.push(Height);
	dataArray.push(defaultState);
	
	//makeCall("designSwitch", JSON.stringify(dataArray));
    makeCall("designSwitch",dataArray);
}
window.makeSwitch = qc.makeSwitch;

qc.hideSwitch = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push(uniqueSwitchID);
	dataArray.push("YES");
	
	//makeCall("designSwitch", JSON.stringify(dataArray));
    makeCall("designSwitch",dataArray);
}
window.hideSwitch = qc.hideSwitch;

qc.showSwitch = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push(uniqueSwitchID);
	dataArray.push("NO");
	
	//makeCall("designSwitch", JSON.stringify(dataArray));
    makeCall("designSwitch",dataArray);
}
window.showSwitch = qc.showSwitch;

qc.switchSetValue = function(uniqueSwitchID, valueYESNO, animatedYESNO){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setValue");
	dataArray.push(uniqueSwitchID);
	dataArray.push(valueYESNO);
	dataArray.push(animatedYESNO);
	
	//makeCall("designSwitch", JSON.stringify(dataArray));
    makeCall("designSwitch",dataArray);
}
window.switchSetValue = qc.switchSetValue;

qc.switchGetValue = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	var dataArray = new Array();
	dataArray.push("getValue");
	dataArray.push(uniqueSwitchID);
	//makeCall("designSwitch", JSON.stringify(dataArray));
    makeCall("designSwitch",dataArray);
}
window.switchGetValue = qc.switchGetValue;


/*
 *  Native Progress Bar functions
 */

qc.makeProgressBar = function(uniquePBID,X,Y,Width,Height,DefaultValue){
	
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("CreateProgressBar");
	dataArray.push(uniquePBID);	
	dataArray.push(X);
	dataArray.push(Y);
	dataArray.push(Width);
	dataArray.push(Height);
	dataArray.push(DefaultValue);
	
	//makeCall("designProgressBar", JSON.stringify(dataArray));
    makeCall("designProgressBar",dataArray);
}
window.makeProgressBar = qc.makeProgressBar;

qc.hideProgressBar = function(uniquePBID){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push(uniquePBID);
	dataArray.push("YES");
	
	///makeCall("designProgressBar", JSON.stringify(dataArray));
    makeCall("designProgressBar",dataArray);
}
window.hideProgressBar = qc.hideProgressBar;

qc.showProgressBar = function(uniquePBID){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setHidden");
	dataArray.push(uniquePBID);
	dataArray.push("NO");
	
	//makeCall("designProgressBar", JSON.stringify(dataArray));
    makeCall("designProgressBar",dataArray);
}
window.showProgressBar = qc.showProgressBar;

qc.progressBarSetValue = function(uniquePBID, value){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var dataArray = new Array();
	dataArray.push("setValue");
	dataArray.push(uniquePBID);
	dataArray.push(value);
	
	//makeCall("designProgressBar", JSON.stringify(dataArray));
    makeCall("designProgressBar",dataArray);
}
window.ProgressBarSetValue = qc.progressBarSetValue;


/*
 * Since the userName and password will be passed this function
 * should only be used with https URLs.
 * 
 * If you are sending these types of files you do not need to include the mime type:
 * 1 - caf audio (as recorded by the device)
 * 2 - png
 * 3 - mp4
 
 */
qc.uploadFile = function(fileName, URL, userName, password, asName, optionalMimeType, optionalURLArgumentsMap){
	if(!fileName || !URL){
		throw "ERROR: A file name and URL are required to upload a File";
	}
	var knownMimeType = false;
	if(fileName.endsWith('.png') ||fileName.endsWith('.caf') || fileName.endsWith('mp4')) {
		knownMimeType = true;
	}
	if(!knownMimeType && !optionalMimeType){
		throw "ERROR: Unknow mime type for file "+fileName+".  Either set the optionalMimeType parameter or upload a file of a known type";
	}
	var dataArray = new Array();
	dataArray.push(fileName);
	dataArray.push(URL);
	dataArray.push(userName?userName : "No_Ne");
	dataArray.push(password?password : "No_Ne");
	dataArray.push(optionalMimeType?optionalMimeType : "No_Ne");
	dataArray.push(optionalURLArgumentsMap ? optionalURLArgumentsMap : new Object());//placeholder
	dataArray.push(asName ? asName : "No_Ne");
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	//makeCall("uploadFile",JSON.stringify(dataArray));	
    makeCall("uploadFile",dataArray);
	if(!userName || !password || URL.indexOf('https:') != 0){
		debug('WARNING: Your upload to '+URL+' is insecure.  To be secure it should be done using https and a user name and password.');
	}
}
window.uploadFile = qc.uploadFile;
/*
 *  Parameters:
 *  1 - the base URL to the remote file
 *	2 - the name that should be used to store the file on the device
 *	3 - URL paramter pairs.  These are found after the ? character in a URL
 *  4 - a boolean indicating if an existing file should be overwritten
 */
qc.downloadFile = function(URL, toFileName, optionalULRParameters, overwriteFlag){
	var dataArray = new Array();
	dataArray.push(URL);
	dataArray.push(toFileName);
	optionalULRParameters = optionalULRParameters ? optionalULRParameters : "url_param_place_holder";
	dataArray.push(optionalULRParameters);
	
	shouldOverwrite = overwriteFlag ? "YES" : "NO";
	dataArray.push(shouldOverwrite);
	
	dataArray.push("Place_holder");
	dataArray.push("Place_holder");
	dataArray.push("Place_holder");
	
	
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	//makeCall("downloadFile",JSON.stringify(dataArray));
    makeCall("downloadFile",dataArray);
	
}
window.downloadFile = qc.downloadFile;

qc.downloadBatch = function(URLArray, toFileNameArray, optionalULRParameters){
	if(URLArray.length != toFileNameArray.length){
		debug('ERROR: the number of URLS must match the number of file names in order to do a batch download');
		return;
	}
	var dataArray = new Array();
	dataArray.push(URLArray);
	dataArray.push(toFileNameArray);
	optionalULRParameters = optionalULRParameters ? optionalULRParameters : "url_param_place_holder";
	dataArray.push(optionalULRParameters);
	
	dataArray.push("Place_holder");
	dataArray.push("Place_holder");
	dataArray.push("Place_holder");
	dataArray.push("Place_holder");
	
	
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	//makeCall("downloadFileBatch",JSON.stringify(dataArray));
    makeCall("downloadFileBatch",dataArray);
}
window.downloadBatch = qc.downloadBatch;

/*
 * In app purchase functions
 */
qc.getStoreProductInfoForIdentifiers = function(identifiers){
	makeCall("getProductInfo", identifiers);
}
window.getStoreProductInfoForIdentifiers = qc.getStoreProductInfoForIdentifiers;

qc.checkCanPurchase = function(){
	var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	//makeCall("canMakePaymentsCheck",JSON.stringify(dataArray));
    makeCall("canMakePaymentsCheck",dataArray);
}
window.checkCanPurchase = qc.checkCanPurchase;

qc.makePurchase = function(itemIdentifier, quantity){
	if(itemIdentifier && quantity > 0){
		var dataArray = new Array();
		dataArray.push(itemIdentifier);
		dataArray.push(quantity);
		//makeCall("startPurchase", JSON.stringify(dataArray));
        makeCall("startPurchase",dataArray);
	}
	else{
		return false;
	}
}
window.makePurchase = qc.makePurchase;

/*
 * the debug function posts any message you send to the Xcode
 * console.
 */

qc.debug = function(aMessage){
    if(aMessage){
        qc.makeCall("logMessage", qc.generateDataArray(aMessage));
    }
}
window.debug = qc.debug;
/*
 * the logError function can be passed an error created by 
 * a try/catch statement pair or a standard string of your
 * creation.
 * any error or message sent is posted to the Xcode console.
 */
/*! \fn qc.logError(error)
 @brief qc.logError(error) <br/> The qc.logError function is used to display an error caught by a try - catch JavaScript phrase.  This function prints out a full stack trace, the reason for the error, the name of the file in which the error occured, and the line number on which the error occured to the console.
 @param error the error caught by using try - catch in the code
 */
qc.logError = function(err){
    if(err){
        makeCall("logMessage", [qc.errorMessage(err)]);
    }
}
window.logError = qc.logError;

qc.findLocation = function(){
    makeCall("loc");
}
window.findLocation = qc.findLocation;


qc.getDeviceDescription = function(){
	makeCall("sendDeviceDescription");
}
window.getDeviceDescription = qc.getDeviceDescription;


/*
 *  possible map types are standard, satelite, hybrid
 */
qc.showMap = function(locationsArray, showCurrentLocation, mapType){
	//debug('showing map');
    var locationsString = JSON.stringify(locationsArray);
	if(locationsArray && locationsArray.length >= 1){
		var dataArray = new Array();
		dataArray.push(locationsArray);
		if(showCurrentLocation){
			dataArray.push(1);
		}
		else{
			dataArray.push(-1);
		}
		if(mapType){
			dataArray.push(mapType);
		}
		else{
			dataArray.push('standard');
		}
		var callBackParameters = generatePassThroughParameters();
		dataArray.push(callBackParameters);
		/*
		 var params = new Array();
		 params[0] = 0;
		 params[1] = locationsArray;
		 */
		//makeCall("showMap", JSON.stringify(dataArray));
        makeCall("showMap",dataArray);
	}
}
window.showMap = qc.showMap;

qc.showEmail = function(toArray, subject, body){
	
	if(!toArray){
		toArray = new Array();
	}
	if(!subject){
        subject = "";
	}
	if(!body){
        body = "";
	}
    var dataArray = generateDataArray(toArray, subject, body);
    /*
     var dataArray = new Array();
     dataArray.push(toArray);
     dataArray.push(subject);
     dataArray.push(body);
     var callBackParameters = generatePassThroughParameters();
     
     dataArray.push(callBackParameters);
     */
    
	//makeCall("showEmail", JSON.stringify(dataArray));
    makeCall("showEmail",dataArray);
    
}
window.showEmail = qc.showEmail;

/*
 *  Camera and images functions
 */

/*
 *  This function is depricated.  Use takePictureInRoll instead.
 */
qc.showCamera = function(){
	takePictureInRoll();
}
window.showCamera = window.showCamera;

qc.takePictureInRoll = function(){
    var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	//makeCall("showCamera", JSON.stringify(dataArray));
    makeCall("showCamera",dataArray);
}
window.takePictureInRoll = qc.takePictureInRoll;

qc.takePicuture = function(aPictureName){
    var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
    dataArray.push(aPictureName);
	dataArray.push(callBackParameters);
	//makeCall("showCamera", JSON.stringify(dataArray));
    makeCall("showCamera",dataArray);
}
window.takePicuture = qc.takePicuture;

qc.movePictureToRoll = function(aPictureName){
    var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
    dataArray.push(aPictureName);
	dataArray.push(callBackParameters);
	//makeCall("moveImage", JSON.stringify(dataArray));
    makeCall("moveImage",dataArray);
}
window.movePictureToRoll = qc.movePictureToRoll;

/*
 *  sound functions
 */

qc.playSystemSound = function(aSoundFileName){
    /*
     * the 0 indicator causes the phone to play a system sound using the file with the name aSoundFile.
     * all sound files used as system sounds must be less than five seconds in length.
     */
    if(aSoundFileName && aSoundFileName.split('.').length == 2){
        var dataArray = new Array();
        dataArray[0] = 0;
        dataArray[1] = aSoundFileName;
        //makeCall("playSound", JSON.stringify(params));
        makeCall("playSound",dataArray);
    }
    else{
        logError("The sound file name '"+aSoundFileName+"' is incorrectly formatted.  It should be <file_name>.<file_type>");
    }
}
window.playSystemSound = qc.playSystemSound;

qc.vibrate = function(){
    //the -1 indicator causes the phone to vibrate
    makeCall("playSound", -1); 
}
window.vibrate;


qc.record = function(aFileName){
    if(aFileName){
        var dataArray = new Array();
        dataArray[0] = aFileName+".caf";
        dataArray[1] = "start";
        //makeCall("rec", JSON.stringify(params));
        makeCall("rec",dataArray);
    }
}
window.record = qc.record;

qc.stopRecording = function(aFileName){
    if(aFileName){
        var dataArray = new Array();
        dataArray[0] = aFileName+".caf";
        dataArray[1] = "stop";
        //makeCall("rec", JSON.stringify(params));
        makeCall("rec",dataArray);
    }
}
window.stopRecording = qc.stopRecording;

//set loop count to a number of loops or -1 for continuous looping
qc.play = function(aFileName, loopCount){
    if(aFileName){
        var dataArray = new Array();
		if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		dataArray[0] = aFileName;
        dataArray[1] = "start";
		dataArray[2] = 0;
		if(loopCount){
			params[2] = loopCount;
		}
        ///makeCall("play", JSON.stringify(params));
        makeCall("play",dataArray);
    }
}
window.play = qc.play;
/*
 *	Pause is removed for now since the standard apple Objective-C
 *  class fails to play an audio file that is paused.
 *
 pausePlaying(aFileName){
 
 if(aFileName){
 var params = new Array();
 if(aFileName.indexOf('.') == -1){
 aFileName = aFileName+".caf";
 }
 params[0] = aFileName;
 params[1] = "pause";
 makeCall("play", JSON.stringify(params));
 }
 }
 */
qc.stopPlaying = function(aFileName){
    
    if(aFileName){
        var dataArray = new Array();
        if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		dataArray[0] = aFileName;
        dataArray[1] = "stop";
        //makeCall("play", JSON.stringify(params));
        makeCall("play",dataArray);
    }
}
window.stopPlaying = qc.stopPlaying;

/*
 *  date and date/time picker functions
 */

qc.showPicker = function(aSelectorType)
{
    if(aSelectorType == "Date" || aSelectorType == "DateTime"){
        makeCall("showDate", aSelectorType);
    }
    else{
        logError("Incorrect selector type: "+aSelectorType);
    }
}
window.showPicker = qc.showPicker;

/*
 *
 * the determineReachability function is used to determine 
 * if the device is connected to a wireless network and what type
 * of network that it is connected to 3G or wifi.
 *
 */

qc.determineReachability = function(){
	makeCall("networkStatus");
}
window.determineReachability = qc.determineReachability;

qc.getPreference = function(preferenceName){
    var dataArray = new Array();
    dataArray.push(preferenceName);
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    //makeCall("getPreference", JSON.stringify(dataArray));
    makeCall("getPreference",dataArray);
}
window.getPreference = qc.getPreference;

/*
 *  makeCall is the functional method behind the facade methods
 *  that actually sends a message to the Objective-C portion 
 *  of the application.
 */
var messages = new Array();

qc.makeCall = function(command, dataArray){
    
    if(command){
        if(dataArray.constructor != Array){
            dataArray = [dataArray];
        }
        //don't push pass through parameters to the debug function since it will cause an infinite loop in some conditions.
        if(arguments.callee.caller != qc.debug){
            dataArray.push(generatePassThroughParameters());
        }
        var aMessage = {"cmd":command, "parameters":dataArray};
        messages.push(aMessage);
    }
}
window.makeCall = qc.makeCall;

qc.messageQueueAsJSON = function(){
    /*
     *  Pull off each of the messages so that if somehow another message is being added to the messages array data 
     *  corruption won't happen when the array is stringified.
     */
    var messagesToSend = new Array();
    while(messages.length){
        var aMessage = messages.shift();
        messagesToSend.push(aMessage);
    }
    return JSON.stringify(messagesToSend);
}

/*
 * These functions make calls to 
 * a native database on the device.
 */

qc.closeDeviceData = function(dbName){
    if(dbName){
        var dataArray = new Array();
		dataArray.push(dbName);
        var callBackParameters = generatePassThroughParameters();
        dataArray.push(callBackParameters);
        
		//var dataString = JSON.stringify(dataArray);
		//makeCall("closeData", dataString);
        makeCall("closeData",dataArray);
    }
}
window.closeData = qc.closeDeviceData;

qc.getDeviceData = function(dbName, SQL, preparedStatementParameters, callBackParams){
	if(dbName && SQL){
		//SQL = escape(SQL);
		var dataArray = new Array();
		dataArray.push(dbName);
		dataArray.push(SQL);
		if(preparedStatementParameters){
			dataArray.push(preparedStatementParameters);
		}
        else{
            //put in a placeholder
            dataArray.push(new Array());
        }
        //var callBackParameters = generatePassThroughParameters();
        //dataArray.push(callBackParameters);
        
		//var dataString = JSON.stringify(dataArray);
		//makeCall("getData", dataString);
        makeCall("getData",dataArray);
	}
    return null;
}
window.getDeviceData = qc.getDeviceData;

qc.setDeviceData = function(dbName, SQL, preparedStatementParameters, callBackParams){
	if(dbName && SQL){
		//SQL = escape(SQL);
        //SQL = replaceAll(SQL, "=","%3D");
        //SQL = replaceAll(SQL, "?","%3F");
		var dataArray = new Array();
		dataArray.push(dbName);
		dataArray.push(SQL);
		if(preparedStatementParameters){
			dataArray.push(preparedStatementParameters);
		}
        else{
            //put in a placeholder
            dataArray.push(new Array());
        }
        //var callBackParameters = generatePassThroughParameters();
        //dataArray.push(callBackParameters);
        
		//var dataString = JSON.stringify(dataArray);
		//return makeCall("setData", dataString);
        makeCall("setData",dataArray);
	}
	return null;
}
window.setDeviceData = qc.setDeviceData;

qc.startDeviceTransaction = function(dbName){
	makeTransactionRequest(dbName, 'start');
}
window.startDeviceTransaction = qc.startDeviceTransaction;

qc.commitDeviceTransaction = function(dbName){
	makeTransactionRequest(dbName, 'commit');
}
window.commitDeviceTransaction = qc.commitDeviceTransaction;

qc.rollbackDeviceTransaction = function(dbName){
	makeTransactionRequest(dbName, 'rollback');
}
window.rollbackDeviceTransaction = qc.rollbackDeviceTransaction;

qc.makeTransactionRequest = function(dbName, type){
	//debug('transaction request of type: '+type);
	var dataArray = new Array();
	dataArray.push(dbName);
	//add in a placeholder for what is usually the sql passed
	dataArray.push(type);
	//add a placeholder array for what is usually the prepared statement paramters
	dataArray.push(new Array());
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	
	//var dataString = JSON.stringify(dataArray);
	//return makeCall("handleTransactionRequest", dataString);
    makeCall("handleTransactionRequest", dataArray);
}
window.makeTransactionRequest = qc.makeTransactionRequest;


/*
 *
 * displaying the contact picker view
 *
 */

qc.showAllContacts = function(){
	var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	
	//var dataString = JSON.stringify(dataArray);
	//makeCall("allContacts", dataString);
    makeCall("allContacts", dataArray);
}
window.showAllContacts = qc.showAllContacts;


qc.generateDataArray = function(){
    var numParameters = arguments.length;
    var dataArray = new Array();
    for(var i = 0; i < numParameters; i++){
        dataArray.push(arguments[i]);
    }
    return dataArray;
}