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


DataAccessObject.SYNC_NONE = 0;
DataAccessObject.SYNC_ON_DEMAND = 1;
DataAccessObject.SYNC_PERIODIC = 2;
DataAccessObject.SYNC_CONTINUOUS = 3;

/*
 *  the sqlite database used in safari and UIWebView as well as the 
 *  JavaScript to native implementation handle all requests asynchronously.
 */

function DataAccessObject(dbName, dbVersion, dbDescription, dbSize, isNativeDatabase){
	//Android doesn't work with 'in webview' databases
	//if(dbName.match('.sqlite'+"$")=='.sqlite' || isNativeDatabase){
		this.isNativeDatabase = true;
	//}
    
	this.dbName = dbName;
    this.syncStore = new Object();
    /*
    *  this set of methods and attributes supports enterprise data synchronization
    */
    this.setupSyncing = function(aType, aURL, userName, password, timeoutSeconds, optionalPeriodSeconds){
        this.setData("CREATE TABLE IF NOT EXISTS sync_info(last_sync TIMESTAMP);");
		this.setData("CREATE TABLE IF NOT EXISTS sync_temp(timeStamp TIMESTAMP, sql_key TEXT, sql_params TEXT)");
        optionalPeriodSeconds *= 1000;
        this.syncType = aType;
        this.syncURL = aURL;
        this.login  = [userName, password];
        this.timeoutSeconds = timeoutSeconds;
        var self = this;
        if(DataAccessObject.SYNC_PERIODIC && optionalPeriodSeconds && !isNaN(optionalPeriodSeconds)){
            window.QCsyncRepeater = function(){
                var params = [self];
                handleRequest('QCsync',params);
                setTimeout("QCsyncRepeater()", optionalPeriodSeconds);
            }
            setTimeout("QCsyncRepeater()", optionalPeriodSeconds);
        }
    }//end of stupSyncing
    
    //store key value pairs for later execution
    this.storeSyncStatement = function(key, statement){
        //debug('storing: '+key+' '+statement+' in '+this.syncStore);
        this.syncStore[key] = statement;
        //debug('store: '+JSON.stringify(this.syncStore));
    }

    this.storeSyncStatements = function(statementMap){
        this.syncStore = satementMap;
    }

    this.sync = function(lastSyncDate, dataToSync){
		if(window.syncDataManipulationFunction && dataToSync){
			dataToSyc = syncDataManipulationFunction(dataToSyc);
		}
        if(!this.currentlySyncing){
            this.currentlySyncing = true;
            var aSyncCall = new ServerAccessObject(this.syncURL, this.timeoutSeconds);
            aSyncCall.setData(ServerAccessObject.TEXT,null,'cmd=sync&uname='+this.login[0]
							  +'&pword='+this.login[1]
							  +'&lastSync='+lastSyncDate
							  +'&data='+encodeURIComponent(JSON.stringify(dataToSync)));
        }
    }

    /*
    * end of sync methods
    */
	
	this.closeDatabase = function(){
		if(this.isNativeDatabase){
			this.closeNativeDatabase();
		}
	}
    this.closeNativeDatabase = function(){
        closeDeviceData(dbName);
    }
    this.getNativeData = function(SQL, preparedStatementParameters){
        getDeviceData(dbName, SQL, preparedStatementParameters);
    }
    this.setNativeData = function(SQL, preparedStatementParameters){
        setDeviceData(dbName, SQL, preparedStatementParameters);
    }
	this.startTransaction = function(){
		if(this.isNativeDatabase){
			this.nativeStartTransaction();
		}
	}
	this.nativeStartTransaction = function(){
		startDeviceTransaction(dbName);
	}
	this.commit = function(){
		if(this.isNativeDatabase){
			this.nativeCommit();
		}
	}
	this.nativeCommit = function(){
		commitDeviceTransaction(dbName);
	}
	this.rollback = function(){
		if(this.isNativeDatabase){
			this.nativeRollback();
		}
	}
	this.nativeRollback = function(){
		rollbackDeviceTransaction(dbName);
	}
	
    this.transact = function(SQL, preparedStatementParameters){
		var storedSyncSQL = this.syncStore[SQL];
    	var checkString = qc.trim(SQL.toLowerCase());
    	var isChangingData = true;
    	if(checkString.indexOf('select') == 0){
    		isChangingData = false;
    	}
    	if(storedSyncSQL){
			var script = new DBScript(this);
			script.addStatement(SQL, preparedStatementParameters);
			script.executeSetDataScript();
		}
    	else if(this.isNativeDatabase){
        	console.log('is changing data: '+isChangingData);
    		if(isChangingData){
    			this.setNativeData(SQL, preparedStatementParameters);
    		}
    		else{
    			this.getNativeData(SQL, preparedStatementParameters);
    		}
		}
		else{
			this.dbAccess(SQL, preparedStatementParameters, isChangingData);
		}
    }
    this.getData = this.transact;
    
    /*
    this.setData = function(SQL, preparedStatementParameters){
		var storedSyncSQL = this.syncStore[SQL];
		
		//this may be a syncronized statement.  Check and handle if it is
		 
		if(storedSyncSQL){
			var script = new DBScript(this);
			script.addStatement(SQL, preparedStatementParameters);
			script.executeSetDataScript();
		}
		else if(this.isNativeDatabase){
			this.setNativeData(SQL, preparedStatementParameters);
		}
		else{
			this.dbAccess(SQL, preparedStatementParameters, true);
		}
    }
    */
    var self = this;
    this.dbAccess = function(SQL, preparedStatementParameters, treatAsChangeData){
        var passThroughParameters = generatePassThroughParameters();
		var currentExecutionKey = executionKey;
        if(!this.db){
            this.db = openDatabase(dbName, dbVersion, dbDescription, dbSize);   
        }
        var queryResult = new QueryResult();
        this.db.transaction(function(tx) {
                            tx.executeSql(SQL, preparedStatementParameters, function(tx, resultSet) {
                                        //check to see if there was a sync key passed in instead of SQL
                                        
										  if(treatAsChangeData){
                                              try{
                                                queryResult.insertedID = resultSet.insertId;
                                                queryResult.rowsAffected = resultSet.rowsAffected;
                                              }
                                              catch(ex){
                                              //then must have been an update
                                                queryResult.rowsAffected = resultSet.rowsAffected;
                                              }
										  }
										  else{//not a change to the database.  must be a query
										  queryResult.numRowsFetched = resultSet.rows.length;
										  var dataArray = new Array();
										  queryResult.numResultFields = 0;
										  queryResult.fieldNames = new Array();
										  if(queryResult.numRowsFetched > 0){
											  //retreive the field ids in the result set
											  var firstRecord = resultSet.rows.item(0);
											  var numFields = 0;
											  for(key in firstRecord){
												  var stuff = key;
												  queryResult.fieldNames.push(key);
												  numFields++;
											  }
											  queryResult.numResultFields = numFields;
											  var numRecords = queryResult.numRowsFetched;
											  for(var i = 0; i < numRecords; i++){
												  var record = resultSet.rows.item(i);
												  var row = new Array();
												  dataArray.push(row);
												  for(var j = 0; j < numFields; j++){
													row.push(record[queryResult.fieldNames[j]]);
												  }
											  }	
										  }
										  queryResult.results = dataArray;
										  }
										  var theResults = new Array();
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  var executionObject = executionMap[currentExecutionKey];
										  if(executionObject){
										  requestHandler(executionObject['cmd'], executionObject['params'], [theResults, currentExecutionKey]);
										  }
                                          
                                          }//end of sql execute success callback function
                                          , function(tx, error) {
										  queryResult.errorMessage =  error.message;
										  
										  //callFunc(queryResult);
										  var theResults = new Array();
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  
										  var executionObject = executionMap[currentExecutionKey];
										  if(executionObject){
										  requestHandler(executionObject['cmd'], executionObject['params'], [theResults, currentExecutionKey]);
										  }
                                          }//end of main sql execute fail callback function
                                          );//end of main executeSql call
                            });//end of transaction callback function
    }
    this.executeBatch = function(linker){
        var passThroughParameters = generatePassThroughParameters();
		var currentExecutionKey = executionKey;
		if(!this.db){
            this.db = openDatabase(dbName, dbVersion, dbDescription, dbSize);   
        }
        var self = this;
        this.db.transaction(function(tx) {
							var keyCount = 0;
							for(key in linker){
								keyCount++;
							}
                            var params = null;
							var lastStatementIndex = keyCount;
							var numInserts = 0;
							for(var key in linker){
                                var keyArray = JSON.parse(key);
                                if(keyArray.length > 1){
                                    params = keyArray[1];
                                }
                                else{
                                    params = [];
                                }
							var anSQL = linker[key];
							var errorHandled = false;
							tx.executeSql(anSQL,
										  params, 
										  function(tx, resultSet) {
                                            
										  numInserts++;
										  
										  var theResults = new Array();
										  var queryResult = new QueryResult();
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  var executionObject = executionMap[currentExecutionKey];
										  if(executionObject && numInserts == keyCount){
										  requestHandler(executionObject['cmd'], executionObject['params'], [theResults, currentExecutionKey]);
										  }
										  
										  },//end of sql execute success callback function
										  function(tx, error) {
										  debug('function error: '+JSON.stringify(error));
										  var queryResult = new QueryResult();
										  queryResult.errorMessage =  error.message;
										  
										  var theResults = new Array();
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  
										  var executionObject = executionMap[currentExecutionKey];
										  if(executionObject && !errorHandled){
										  requestHandler(executionObject['cmd'], executionObject['params'], [theResults, currentExecutionKey]);
										  }
										  errorHandled = true;
										  return true;
										  }//end of main sql execute fail callback function
										  );//end of main executeSql call
							
							}//end of for key in linker
							}, function(error){
								debug('in transaction error: '+error.message);
								return true;
                            }//end of transaction error
							);//end of transaction callback function
	}
	
}

function QueryResult(){
    /*
	 * attributes
	 */
    this.results = null;
    this.errorMessage = false;
    this.numRowsFetched = 0;
    this.insertedID = null;
    this.numResultFields = null;
	this.fieldNames = null;
	this.rowsAffected = 0;
    /*
	 * methods
	 */
    this.getRecords = function(){
        return this.results;
    }
    this.setRecords = function(results){
        this.results = results;
    }
    this.getErrorMessage = function(){
        return this.errorMessage;
    }
    this.getNumRecordsFetched = function(){
        return this.numRowsFetched;
    }
    this.getInsertedId = function(){
        return this.insertedID;
    }
    this.getNumResultFields = function(){
        return this.numResultFields;
    }
    this.getFieldNames = function(){
        return this.fieldNames;
    }
}
