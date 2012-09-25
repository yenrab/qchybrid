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
 * the debug function posts any message you send to the Xcode
 * console.
 */

qc.debug = function(aMessage){
    if(aMessage){
        qc.makeCall("logMessage", '"'+aMessage+'"');
    }
}
window.debug = qc.debug;

/*
 * the logError function can be passed an error created by 
 * a try/catch statement pair or a standard string of your
 * creation.
 * any error or message sent is posted to the Xcode console.
 */
qc.logError = function(err){
    if(err){
        qc.makeCall("logMessage", errorMessage(err));
    }
}
window.logError = qc.error;

qc.findLocation = function(){
    qc.makeCall("loc");
}
window.findLocation = qc.findLocation;

qc.doHttpGet = function(urlString){
    var dataArray = new Array();
    dataArray.push(urlString);
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    qc.makeCall("httpGet", JSON.stringify(dataArray));
}
window.doHttpGet = qc.doHttpGet;


qc.doHttpPost = function(urlString, data){

}
window.doHttpPost = qc.doHttpPost;

qc.getDeviceDescription = function(){
	var dataArray = new Array();
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    qc.makeCall("sendDeviceDescription", JSON.stringify(dataArray));
}
window.getDeviceDescription = qc.getDeviceDescription;

/*
 *  possible map types are standard, satelite, hybrid
 */
qc.showMap = function(locationsArray, showCurrentLocation, mapType){
	debug('showing map');
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
		qc.makeCall("showMap", JSON.stringify(dataArray));
	}
}
window.showMap = qc.showMap;

qc.showEmail = function(){
	var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	qc.makeCall("showEmail", JSON.stringify(dataArray));
}
window.showEmail = qc.showEmail;

qc.playSystemSound = function(aSoundFileName){
    /*
     * the 0 indicator causes the phone to play a system sound using the file with the name aSoundFile.
     * all sound files used as system sounds must be less than five seconds in length.
     */
    if(aSoundFileName && aSoundFileName.split('.').length == 2){
        var params = new Array();
        params[0] = 0;
        params[1] = aSoundFileName;
        qc.makeCall("playSound", JSON.stringify(params));
    }
    else{
        logError("The sound file name '"+aSoundFileName+"' is incorrectly formatted.  It should be <file_name>.<file_type>");
    }
}
window.playSystemSound = qc.playSystemSound;

qc.vibrate = function(){
    //the -1 indicator causes the phone to vibrate
    qc.makeCall("vibrate");
}
window.vibrate = qc.vibrate;

qc.turnOnGPS = function(){
	var params = new Array();
	params[0] = 'on';
	qc.makeCall("loc", JSON.stringify(params));
}
window.turnOnGPS = qc.turnOnGPS;

qc.turnOffGPS = function(){
	var params = new Array();
	params[0] = 'off';
	qc.makeCall("loc", JSON.stringify(params));
}
window.turnOffGPS = qc.turnOffGPS;

qc.showPicker = function(aSelectorType)
{
    if(aSelectorType == "Date" || aSelectorType == "DateTime"){
        qc.makeCall("showDate", aSelectorType);
    }
    else{
        logError("Incorrect selector type: "+aSelectorType);
    }
}
window.showPicker = qc.showPicker;

qc.record = function(aFileName){
    if(aFileName){
        var params = new Array();
        params[0] = aFileName;
        params[1] = "start";
        qc.makeCall("rec", JSON.stringify(params));
    }
}
window.record = qc.record;

qc.stopRecording = function(aFileName){
    if(aFileName){
        var params = new Array();
        params[0] = aFileName;
        params[1] = "stop";
        qc.makeCall("rec", JSON.stringify(params));
    }
}
window.stopRecording = qc.record;

//set loop count to a number of loops or -1 for continuous looping
qc.play = function(aFileName, loopCount){
    if(aFileName){
        var params = new Array();
		if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		params[0] = aFileName;
        params[1] = "start";
		params[2] = 0;
		if(loopCount){
			params[2] = loopCount;
		}
        qc.makeCall("play", JSON.stringify(params));
    }
}
window.play = qc.record;
/*
 *	Pause is removed for now since the standard apple Objective-C
 *  class fails to play an audio file that is paused.
 *
 function pausePlaying(aFileName){
 
 if(aFileName){
 var params = new Array();
 if(aFileName.indexOf('.') == -1){
 aFileName = aFileName+".caf";
 }
 params[0] = aFileName;
 params[1] = "pause";
 qc.makeCall("play", JSON.stringify(params));
 }
 }
 */
qc.stopPlaying = function(aFileName){
    
    if(aFileName){
        var params = new Array();
        if(aFileName.indexOf('.') == -1){
			aFileName = aFileName+".caf";
		}
		params[0] = aFileName;
        params[1] = "stop";
        qc.makeCall("play", JSON.stringify(params));
    }
}
window.stopPlaying = qc.stopPlaying;

/*
 *
 * the determineReachability function is used to determine 
 * if the device is connected to a wireless network and what type
 * of network that it is connected to 3G or wifi.
 *
 */

qc.determineReachability = function(){
	qc.makeCall("networkStatus");
}
window.determineReachability = qc.determineReachability;

qc.getPreference = function(preferenceName){
    var dataArray = new Array();
    dataArray.push(preferenceName);
    var callBackParameters = generatePassThroughParameters();
    dataArray.push(callBackParameters);
    qc.makeCall("getPreference", JSON.stringify(dataArray));
}
window.getPreference = qc.getPreference;

/*
*  This is the new code not the old code.  It should not be documented for the API.  It is 'private'.
*/

qc.hasMadeCall = false;
qc.intervalId = null;

qc.messageQueueAsJSON = function(){
    //get the message queue from the Java side.
    var messagesToComplete = qcDevice.messageQueueAsJSON();
    //convert to objects and call request handler for each request to be completed.
    messagesToComplete = JSON.parse(messagesToComplete);
    var numMessages = messagesToComplete.length;
    for(var i = 0; i < numMessages; i++){
        var aMessage = messagesToComplete[i];
        try{
            var callBackData = JSON.parse(callBackString);
            var anExecutionKey = callBackData[1];
            if(anExecutionKey){
                var executionObject = executionMap[anExecutionKey];
                if(executionObject){
                    requestHandler(executionObject['cmd'], executionObject['params'], callBackData);
                }
            }
        }
        catch(err){
            logError(err);
        }
    }
}

/*
 *  makeCall is the functional method behind the facade methods
 *  that actually sends a message to the Java portion 
 *  of the application.
 */
 
qc.makeCall = function(command, dataString){
	if(command){
        qcDevice.makeCall(command, dataString);
        if(!qc.hasMadeCall){
            qc.intervalId = setInterval(qc.messageQueueAsJSON, 300);
            qc.hasMadeCall = true;
        }
    }
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
        
		var dataString = JSON.stringify(dataArray);
		qc.makeCall("closeData", dataString);
    }
}
window.closeDeviceData
qc.getDeviceData = function(dbName, SQL, preparedStatementParameters, callBackParams){
	if(dbName && SQL){
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
        var callBackParameters = generatePassThroughParameters();
        dataArray.push(callBackParameters);
        
		var dataString = JSON.stringify(dataArray);
		qc.makeCall("getData", dataString);
	}
    return null;
}
window.getDeviceData = qc.getDeviceData;

qc.setDeviceData = function(dbName, SQL, preparedStatementParameters, callBackParams){
	if(dbName && SQL){
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
        var callBackParameters = generatePassThroughParameters();
        dataArray.push(callBackParameters);
		var dataString = JSON.stringify(dataArray);
		return qc.makeCall("setData", dataString);
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
	
	var dataString = JSON.stringify(dataArray);
	return qc.makeCall("handleTransactionRequest", dataString);
}


/*
 *
 * displaying the contact picker view
 *
 */

qc.showAllContacts = function(){
	var dataArray = new Array();
	var callBackParameters = generatePassThroughParameters();
	dataArray.push(callBackParameters);
	
	var dataString = JSON.stringify(dataArray);
	qc.makeCall("allContacts", dataString);
}