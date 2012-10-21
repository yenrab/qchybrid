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
qc.writeToFile = function(fileName, fileContentString, resultKey){
    if(!aFileName || !fileContentString){
        return false;
    }
    var data = new Object();
    fileName = qc.replaceAll(fileName, "\n","&nln;");
    fileContentString = qc.replaceAll(fileContentString, "\n","&nln;");
    data['name'] = fileName;
    data['contents'] = fileContentString;
    data['resultKey'] = resultKey;
    qc.makeCall("saveFile",data);
    
}
window.writeToFile = qc.writeToFile;

qc.remove = function(fileOrDirectoryName, resultKey){
    if(!fileOrDirectoryName){
        return false;
    }
    var data = new Object();
    data['fileName'] = escape(fileOrDirectoryName);
    data['resultKey'] = resultKey;
    makeCall("deleteFile",data);
}
window.remove = qc.remove;

qc.createDirectory = function(directoryName, resultKey){
    if(!directoryName){
        return false;
    }
    var data = new Object();
    data['dirName'] = escape(directoryName);
    data['resultKey'] = resultKey;
    makeCall("makeDir",data);
}
window.createDirectory = qc.createDirectory;

qc.listDirContents = function(resultKey, optionalDirectoryName){
    if(!optionalDirectoryName){
        return false;
    }
    var data = new Object();
    data['resultKey'] = resultKey;
    if(optionalDirectoryName){
        data['dirName'] = escape(optionalDirectoryName);
    }
    makeCall("listFiles",data);
}
window.listDirContents = qc.listDirContents;

qc.getFileContents = function(aFileName, resultKey){
    
    if(!aFileName || !resultKey){
        return false;
    }
    var data = new Object();
    data['fileName'] = aFileName;
    data['resultKey'] = resultKey ;
    makeCall("fileContents",data);
}
window.getFileContents = qc.getFileContents;

qc.displayFile = function(aFileName, resultKey){
    if(!aFileName){
        return false;
    }
    var data = new Object();
    data['fileName'] = escape(aFileName);
    if(resultKey){
        data['resultKey'] = resultKey;
    }
    makeCall("showFile",data);
}
window.displayFile = qc.displayFile;


/*
 *  iAdd code
 */
qc.designiAd = function(TopBottomOther, optionalPortraitY, optionalLandscapeY){
	var data = new Object();
	data['command'] ='createBanner';
	data['location'] = 0;//default is at the top.
	if (TopBottomOther.toUpperCase() == "BOTTOM"){
		data['location'] = 1;
	}else if (TopBottomOther.toUpperCase() == "OTHER"){
		data['location'] = 2;
        data['portraitY'] = optionalPortraitY;
		data['landscapeY'] = optionalLandscapeY;
	}
    makeCall("iAd",data);
}
window.designiAd = qc.designiAd;

qc.showiAd = function(){
	var data = new Object();
    data['hidden'] = "NO";
    makeCall("iAd",data);
}
window.showiAd = qc.showiAd;

qc.hideiAd = function(){
	var data = new Object();
    data['hidden'] = "YES";
    makeCall("iAd",data);
}
window.hideiAd = qc.hideiAd;

/*
 * manipulate the Activity Indicator
 */
qc.turnOffActivityIndicator = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("switchActivityIndicator", data);
}
window.turnOffActivityIndicator = qc.turnOffActivityIndicator;

qc.turnOnActivityIndicator = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("switchActivityIndicator", data);
}
window.turnOffActivityIndicator = qc.turnOffActivityIndicator;

/*
 * manipulate the Network Indicator
 */
qc.turnOffNetworkIndicator = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("switchNetworkIndicator", data);
}
window.turnOffNetworkIndicator = qc.turnOffNetworkIndicator;

qc.turnOnNetworkIndicator = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("switchNetworkIndicator", data);
}
window.turnOnNetworkIndicator = qc.turnOnNetworkIndicator;


/*
 * manipulate the accelerometer
 */
qc.turnOffAccelerometer = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("switchAccelerometer", data);
}
window.turnOffAccelerometer = qc.turnOffAccelerometer;

qc.turnOnAccelerometer = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("switchAccelerometer", data);
}
window.turnOnAccelerometer = qc.turnOnAccelerometer;


/*
 * manipulate the built-in compass
 */
qc.turnOffCompass = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("switchHeading", data);
}
window.turnOffCompass = qc.turnOffCompass;

qc.turnOnCompass = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("switchHeading", data);
}
window.turnOnCompass = qc.turnOnCompass;

/*
 * manipulate auto rotation
 */
turnOffAutoRotation = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("switchAutoRotation", data);
}

qc.turnOnAutoRotation = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("switchAutoRotation", data);
}
window.turnOnAutoRotation = qc.turnOnAutoRotation;

/*
 * Tab Bar functions
 */
var itemArray = new Array();

qc.addTabItem = function(title, image){
	var dataArray = new Array();
	dataArray.push(title);
	dataArray.push(image);
	
	itemArray.push(dataArray);
}
window.addTabItem = window.addTabItem;

qc.makeTabBar = function(X,Y,Width,Height){
	var data = new Object();
    data['x'] = X;
    data['y'] = y;
    data['width'] = Width;
    data['height'] = Height;
    data['items'] = itemArray;
    makeCall("designTabBar",data);
}
window.makeTabBar = qc.makeTabBar;

qc.showTabBar = function(){
    var data = new Object();
    data['on'] = "NO";
	makeCall("setHidden", data);
}
window.showTabBar = qc.showTabBar;

qc.hideTabBar = function(){
    var data = new Object();
    data['on'] = "YES";
	makeCall("setHidden", data);
}
window.hideTabBar = qc.hideTabBar;

/*
 * Native Switch functions
 */

qc.makeSwitch = function(uniqueSwitchID,X,Y,Width,Height, defaultState, resultKey){
	
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var data = new Object();
    data['command'] = "CreateSwitch";
    data['id'] = uniqueSwitchID;
    data['x'] = X;
    data['y'] = Y;
    data['width'] = Width;
    data['height'] = Height;
    data['defaultState'] = defaultState;
    data['resultKey'] = resultKey;
    makeCall("designSwitch",data);
}
window.makeSwitch = qc.makeSwitch;

qc.hideSwitch = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	
	var data = new Object();
    data['hidden'] = 'YES';
    data['id'] = uniqueSwitchID;
	
    makeCall("designSwitch",data);
}
window.hideSwitch = qc.hideSwitch;

qc.showSwitch = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	var data = new Object();
    data['hidden'] = 'NO';
    data['id'] = uniqueSwitchID;
	
    makeCall("designSwitch",data);
}
window.showSwitch = qc.showSwitch;

qc.switchSetValue = function(uniqueSwitchID, valueYESNO, animatedYESNO){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	var data = new Object();
    data['command'] = 'setValue';
    data['id'] = uniqueSwitchID;
    data['value'] = valueYESNO;
    data['animated'] = animatedYESNO;
	
    makeCall("designSwitch",data);
}
window.switchSetValue = qc.switchSetValue;

qc.switchGetValue = function(uniqueSwitchID){
	if (uniqueSwitchID=="0"){
		debug('0 is not a valid uniqueSwitchID, use any int > 0');
		return false;
	}
	var data = new Object();
    data['getValue'] = 'YES';
    data['id'] = uniqueSwitchID;
	
    makeCall("designSwitch",data);
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
	
	var data = new Object();
    data['command'] = 'create';
    data['id'] = uniquePBID;
    data['x'] = X;
    data['y'] = Y;
    data['width'] = Width;
    data['height'] = Height;
    data['default'] = DefaultValue;
    makeCall("designProgressBar",data);
}
window.makeProgressBar = qc.makeProgressBar;

qc.hideProgressBar = function(uniquePBID){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	var data = new Object();
    data['hidden'] = 'YES';
    data['id'] = uniquePBID;
    
    makeCall("designProgressBar",data);
}
window.hideProgressBar = qc.hideProgressBar;

qc.showProgressBar = function(uniquePBID){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var data = new Object();
    data['hidden'] = 'NO';
    data['id'] = uniquePBID;
    
}
window.showProgressBar = qc.showProgressBar;

qc.progressBarSetValue = function(uniquePBID, value){
	if (uniquePBID=="0"){
		debug('0 is not a valid uniquePBID, use any int > 0');
		return false;
	}
	
	var data = new Object();
    data['value'] = value;
    data['id'] = uniquePBID;
    makeCall("designProgressBar",data);
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
qc.uploadFile = function(fileName, URL, resultKey, userName, password, asName, optionalMimeType, optionalURLArgumentsMap){
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
    if(!userName || !password || URL.indexOf('https:') != 0){
		debug('WARNING: Your upload to '+URL+' is insecure.  To be secure it should be done using https and a user name and password.');
	}
	var data = new Object();
	data['fileName'] = fileName;
	data['url'] = URL;
    data['resultKey'];
    if(userName){
        data['uname'] = userName;
    }
    if(password){
        data['pword'] = password;
    }
    if(optionalMimeType){
        data['mimeType'] = optionalMimeType;
    }
    if(optionalURLArgumentsMap){
        data['args'] = optionalURLArgumentsMap;
    }
    if(asName){
        data['name'] = asName;
    }
    makeCall("uploadFile",data);
	
}
window.uploadFile = qc.uploadFile;
/*
 *  Parameters:
 *  1 - the base URL to the remote file
 *	2 - the name that should be used to store the file on the device
 *	3 - URL paramter pairs.  These are found after the ? character in a URL
 *  4 - a boolean indicating if an existing file should be overwritten
 */
qc.downloadFile = function(URL, toFileName, resultKey, optionalURLParameters, overwriteFlag){
	var data = new Object();
	data['url'] = URL;
	data['fileName'] = toFileName;
    data['resultKey'] = resultKey;
    if(optionalULRParameters){
        data['parameters'] = optionalULRParameters;
    }
	
	data['overwrite'] = overwriteFlag ? "YES" : "NO";
    makeCall("downloadFile",data);
	
}
window.downloadFile = qc.downloadFile;

qc.downloadBatch = function(URLArray, toFileNameArray, resultKey, optionalULRParameters){
	if(URLArray.length != toFileNameArray.length){
		debug('ERROR: the number of URLS must match the number of file names in order to do a batch download');
		return;
	}
	var data = new Object();
	data['urls'] = URLArray;
    data['fileNames'] = toFileNameArray;
    data['resultKey'];
    if(optionalULRParameters){
        data['urlParamters'] = optionalULRParameters;
    }
    makeCall("downloadFileBatch",data);
}
window.downloadBatch = qc.downloadBatch;

/*
 * In app purchase functions
 */
qc.getStoreProductInfoForIdentifiers = function(identifiers, resultKey){
    var data = new object();
    data['identifiers'] = identifiers;
    data['resultKey'] = resultKey;
	makeCall("getProductInfo", data);
}
window.getStoreProductInfoForIdentifiers = qc.getStoreProductInfoForIdentifiers;

qc.checkCanPurchase = function(resultKey){
    var data = {'resultKey':resultKey};
    makeCall("canMakePaymentsCheck", data);
}
window.checkCanPurchase = qc.checkCanPurchase;

qc.makePurchase = function(itemIdentifier, quantity, resultKey){
	if(itemIdentifier && quantity > 0){
		var data = new Object();
        data['itemId'] = itemIdentifier;
        data['quantity'] = quantity;
        data['resultKey'] = resultKey;
        makeCall("startPurchase",data);
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
        var data = {'message':aMessage};
        qc.makeCall("logMessage", data);
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
        var errorMessage = qc.errorMessage(err);
        var data = {'message':errorMessage};
        qc.makeCall("logMessage", data);
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
		var data = new Object();
        data['locations'] = locationsArray;
		if(showCurrentLocation){
			data['showCurrent'] = 1;
		}
		if(mapType){
            data['type'] = mapType;
		}
        makeCall("showMap",data);
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
    var data = new Object();
    data['to'] = toArray;
    data['subject'] = subject;
    data['body'] = body;
    
    makeCall("showEmail",data);
    
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
    makeCall("showCamera");
}
window.takePictureInRoll = qc.takePictureInRoll;

qc.takePicuture = function(aPictureName){
    var data = new Object();
    data['name'] = aPictureName;
    makeCall("showCamera",data);
}
window.takePicuture = qc.takePicuture;

qc.movePictureToRoll = function(aPictureName){
    var data = new Object();
    data['name'] = aPictureName;
    makeCall("moveImage",data);
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
        var data = new object();
        data['asSound'] = 0;
        data['fileName'] = aSoundFileName;
        makeCall("playSound",data);
    }
    else{
        logError("The sound file name '"+aSoundFileName+"' is incorrectly formatted.  It should be <file_name>.<file_type>");
    }
}
window.playSystemSound = qc.playSystemSound;

qc.vibrate = function(){
    //the -1 indicator causes the phone to vibrate
    var data = new object();
    data['asSound'] = -1;
    makeCall("playSound", data);
}
window.vibrate;


qc.record = function(aFileName){
    if(aFileName){
        var data = new Object();
        data['fileName'] = aFileName+".caf";
        data['command'] = "start";
        
        makeCall("rec",data);
    }
}
window.record = qc.record;

qc.stopRecording = function(aFileName){
    if(aFileName){
        var data = new Object();
        data['fileName'] = aFileName+".caf";
        data['command'] = "stop";
        
        makeCall("rec",data);
    }
}
window.stopRecording = qc.stopRecording;

//set loop count to a number of loops or -1 for continuous looping
qc.play = function(aFileName, loopCount){
    if(aFileName){
        var data = new Object();
		if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		data['fileName'] = aFileName;
        data['command'] = "start";
		data['asSound'] = 0;
		if(loopCount){
			data['loop'] = loopCount;
		}
        makeCall("play",data);
    }
}
window.play = qc.play;

qc.stopPlaying = function(aFileName){
    
    if(aFileName){
        var data = new Object();
        if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		data['fileName'] = aFileName;
        data['command'] = "stop";
        
        makeCall("play",data);
    }
}
window.stopPlaying = qc.stopPlaying;

/*
 *  date and date/time picker functions
 */

qc.showPicker = function(aSelectorType, resultKey)
{
    if(!resultKey){
        logError("Missing resultKey parameter");
        return;
    }
    if(aSelectorType == "Date" || aSelectorType == "DateTime"){
        var data = new Object();
        data['type'] = aSelectorType;
        data['resultKey'] = resultKey;
        makeCall("showDate", data);
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

qc.determineReachability = function(resultKey, optionalURL){
    var data = new object();
    data['resultKey'] = resultKey;
	makeCall("networkStatus");
}
window.determineReachability = qc.determineReachability;

qc.getPreference = function(preferenceName, resultKey){
    var data = new Object();
    data['name'] = preferenceName;
    data['resultKey'] = resultKey;
    makeCall("getPreference",data);
}
window.getPreference = qc.getPreference;

/*
 *  makeCall is the functional method behind the facade methods
 *  that actually sends a message to the Objective-C portion 
 *  of the application.
 */
var messages = new Array();

qc.makeCall = function(command, parameters){
    
    if(command){
        var aMessage = {"cmd":command, "parameters":parameters};
        //don't push pass through parameters to the debug function since it will cause an infinite loop in some conditions.
        if(arguments.callee.caller != qc.debug && arguments.callee.caller != qc.logError
           && arguments.callee.caller != qc.logMessage){
            parameters['exKey'] = generateExecutionKey();
        }
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
        var data = new Object();
		data['dbName'] = dbName;
        
        makeCall("closeData",data);
    }
}
window.closeData = qc.closeDeviceData;

qc.getDeviceData = function(dbName, resultKey, SQL, preparedStatementParameters){
	if(dbName && SQL && resultKey){
		//SQL = escape(SQL);
		var data = new Object();
		data['dbName'] = dbName;
        data['sql'] = SQL;
        data['resultKey'] = resultKey;
		if(preparedStatementParameters){
			data['prepStmtParams'] = preparedStatementParameters;
		}
        makeCall("getData",data);
	}
    return null;
}
window.getDeviceData = qc.getDeviceData;

qc.setDeviceData = function(dbName,resultKey, SQL, preparedStatementParameters){
	if(dbName && SQL && resultKey){
		//SQL = escape(SQL);
        //SQL = replaceAll(SQL, "=","%3D");
        //SQL = replaceAll(SQL, "?","%3F");
		var data = new Object();
		data['dbName'] = dbName;
        data['sql'] = SQL;
        data['resultKey'] = resultKey;
		if(preparedStatementParameters){
			data['prepStmtParams'] = preparedStatementParameters;
		}
        makeCall("setData",data);
	}
	return null;
}
window.setDeviceData = qc.setDeviceData;

qc.startDeviceTransaction = function(dbName, resultKey){
	makeTransactionRequest(dbName, 'start', resultKey);
}
window.startDeviceTransaction = qc.startDeviceTransaction;

qc.commitDeviceTransaction = function(dbName, resultKey){
	makeTransactionRequest(dbName, 'commit', resultKey);
}
window.commitDeviceTransaction = qc.commitDeviceTransaction;

qc.rollbackDeviceTransaction = function(dbName, resultKey){
	makeTransactionRequest(dbName, 'rollback', resultKey);
}
window.rollbackDeviceTransaction = qc.rollbackDeviceTransaction;

qc.makeTransactionRequest = function(dbName, type, resultKey){
	//debug('transaction request of type: '+type);
	var data = new Object();
	data['dbName'] = dbName;
	//add in a placeholder for what is usually the sql passed
	data['type'] = type;
    data['resultKey'] = resultKey;
    makeCall("handleTransactionRequest", data);
}
window.makeTransactionRequest = qc.makeTransactionRequest;


/*
 *
 * displaying the contact picker view
 *
 */

qc.showAllContacts = function(resultKey){
    var data = new Object();
    data['resultKey'] = resultKey;
    makeCall("allContacts");
}
window.showAllContacts = qc.showAllContacts;
