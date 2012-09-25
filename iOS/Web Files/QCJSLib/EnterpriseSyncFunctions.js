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
 *  These functions, mappings, and constants
 *  support syncronization with remote databases via a web service providing 
 *  access to the remote database.
 */   
 
 /*
 *  get the last successful sync date
 */
 function QCgetLastSyncDateBCF(parameters){
	 /*
	  * if you do NOT want the syncing notification overlay to be shown when
	  * syncing comment out this call to showSyncView().  If you do this then
	  * you must also comment out the messaging notifications in QCdoneSyncingVCF.
	  */
    showSyncView();
	//debug('getting sync info');
    parameters[0].getData("SELECT * from sync_info");
	 
 }
/*
 *  get the records to be synced.
 */
function QCgetSyncDataFromTempTableBCF(parameters){
	//debug('getting sync temp');
    parameters[0].getData("SELECT * from sync_temp");
}
/*
 * override this function to get custom data added to
 * use when manipulating data prior to the sync call
 */
/*function QCgetManipDataBCF(parameters){
	return 'continue';
}
 */
/*
 * send off to the server the records to be synced
 */
function QCsyncBCF(parameters, currentResults){
	//debug('syncing');
	//see if there are any results to work with and don't continue if not
	//debug('results: '+currentResults);
	if(!currentResults || !currentResults[0]){
		return 'stop';
	}
	try{
		var result = currentResults[0][0];
		var errorMessage = null;
		if(!result){
			//this is a result from a native database call
			result = currentResults[0];
		}
		
		if(result.error){
			return 'Error: not a syncing database.';
		}
		else{
			var lastSyncDate = result.data;
			if(lastSyncDate == ''){
				//if no sync has yet happened set the last sync date to a default value
				lastSyncDate = new Date("01/01/1970 00:00:00 GMT").toUTCString();
			}
			var recordsToSync = null;
			if(currentResults[1][0]){
				//in-browser database call yielded these results
				recordsToSync = currentResults[1][0].data;
			}
			else{
				//this is a result from a native database call
				recordsToSync = currentResults[1].data;
				//alert('modifying: '+recordsToSync);
				//recordsToSync = replaceAll(recordsToSync, 'nquote;', '%5C%22');
				//alert(recordsToSync);
			}		
			//need to convert the string stored for the parameter array into an array
			//so that it can be JSONed correctly later
			parameters[0].sync(lastSyncDate, recordsToSync);
			document.getElementById('syncUpdateText').innerText = "Sending/Recieving Server Data.";
		}
	}
	catch(err){
		logError(err);
	}
}
function QCupdateLocalDbaseBCF(parameters, currentResults){
    //alert(JSON.stringify(currentResults[2]));
    //get the update timestamp from currentResults
    if(currentResults[2] == "Error: not a syncing database."){
        document.getElementById('syncUpdateText').innerText = "Error: not a syncing database.\nPlease contact your application provider.";
		
        setTimeout(function(){
				   var body = document.getElementsByTagName('body')[0];
				   var syncDisplay = document.getElementById('syncView');
				   body.removeChild(syncDisplay);
				   turnOnScrolling();
				   },3500);
    }
    else if(currentResults[2].errorMessage){
        var errorMessage = "Syncronization error.\nPlease contact your application provider.";
        if(currentResults[2].errorNumber >= 400 && currentResults[2].errorNumber < 500){
            document.getElementById('syncUpdateText').innerText = "Error: Unable to contact server.\nDo you have internet access?";
        }
        else if(currentResults[2].errorNumber == -100){
            document.getElementById('syncUpdateText').innerText = "Error: Server not responding.\nDo you have internet access?";
        }
		else if(currentResults[2].errorNumber >= 500){
			document.getElementById('syncUpdateText').innerText = errorMessage;
		}
        setTimeout(function(){
						var body = document.getElementsByTagName('body')[0];
						var syncDisplay = document.getElementById('syncView');
						body.removeChild(syncDisplay);
						turnOnScrolling();
				   },3500);
    }
    else{
        //if everything else is good, then do the sync update, remove the information from 
        //the temp table, and update the sync time.
		try{
            //alert(JSON.stringify(currentResults[2]));
			//remove any XML that may have been added by an XML Web Service
			var theData = currentResults[2].data;
			//alert('data: '+JSON.stringify(currentResults[0]));
			if(theData.indexOf('<?') == 0){
				theData = trim(theData.substring(theData.indexOf('?>')+2));
				if(theData.indexOf('<string') == 0){
					theData = theData.substring(theData.indexOf('">')+2,theData.length - 9);
				}
			}

			//alert('Here are results from the server.  data: '+theData);
			var recievedData = JSON.parse(theData);
			//alert('parsed: '+recievedData);
			var syncDate = new Date(recievedData[0]);
			var recordsToSync = recievedData[1];
			//alert('after: '+recordsToSync);
			//if syncDate is not null and is valid
			//debug('syncDate: '+syncDate);
			if(syncDate && syncDate != 'Invalid Date'){
				
				//debug('syncDate: '+syncDate);
				var bulkInsertScript = new DBScript(database);
				bulkInsertScript.addStatement("DELETE from sync_temp");
				bulkInsertScript.addStatement("DELETE from sync_info");
				var params = [syncDate.toUTCString()];
				//debug('adding statement: '+params);
				bulkInsertScript.addStatement("INSERT INTO sync_info VALUES(?)",params);
				//alert('records to sync: '+recordsToSync);
				if(recordsToSync){
					var numRecordsToSync = recordsToSync.length;
					for(var i = 0; i < numRecordsToSync; i++){
						var key = recordsToSync[i][0];
						var SQL = parameters[0].syncStore[key];
						params = null;
						//alert(JSON.stringify(recordsToSync[i]));
						if(recordsToSync[i].length == 2){
							params = recordsToSync[i][1];
							//debug(JSON.stringify(params));
						}
						//add all statements to the script object
						debug('sql: '+SQL+' params: '+params);
						if(SQL){
							bulkInsertScript.addStatement(SQL, params);
						}
					}
				}
				//debug('executing');
				//execute all statements within a transaction
				bulkInsertScript.executeSetDataScript();
			}
			else{
				return 'server data format error';
			}
		}
		catch(err){
			logError(err);
			return 'server data format error';
		}
    }
}

var syncDisplayDelay = 3500;

function QCdoneSyncingVCF(data, parameters){
	//debug('in QCdone');
	//do not comment out the setting of currentlySyncing.  It is needed
    parameters[0].currentlySyncing = false;
	/*
	 *  If you commented out the call to showSyncView() in QCgetLastSyncDateBCF
	 *  you must comment out or modify the messaging code below.
	 */
	try{
		var message = 'Data successfully synchronized';
		if(data[3][0] && typeof data[3][0] == 'object'
		   && data[3][0].errorMessage != null && data[3][0].errorMessage != false
		   && data[3][0].errorMessage != 'not an error'){
			//debug('first if: '+message[0].errorMessage);
			message = 'DATA INSERTION ERROR: '+data[3][0].errorMessage+'.  Please contact your application provider';
		}
		else if(data[3] != 'server data format error' && data[2].errorMessage != null){
			//debug('second if: '+data[3] != 'server data format error'+' '+data[2].errorMessage != null);
			message = 'DATA INSERTION ERROR: '+data[2].errorMessage+'.  Please contact your application provider';
		}
		else if(data[3] == 'server data format error'){
			//debug('third if');
			message = 'Error: The server is not responding with correctly formatted data.\nPlease contact your application provider.';
		}
		else if(data[3].errorMessage && data[3].errorMessage != 'not an error'){
			message = 'DATA INSERTION ERROR: '+data[3].errorMessage+'.  Please contact your application provider';
		}
	}
	catch(err){
		logError(err);
		message = 'Syncronization error.\nPlease contact your application provider.';
	}
	var syncView = document.getElementById('syncUpdateText');
	if(syncView){
		document.getElementById('syncUpdateText').innerText = message;
		setTimeout(function(){
				   var body = document.getElementsByTagName('body')[0];
				   var syncDisplay = document.getElementById('syncView');
				   body.removeChild(syncDisplay);
				   turnOnScrolling();
				   },syncDisplayDelay);
	}
	else{
		turnOnScrolling();
	}
}
