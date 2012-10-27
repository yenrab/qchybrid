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
window.vibrate = qc.vibrate;


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
window.stopRecording = qc.record;

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
