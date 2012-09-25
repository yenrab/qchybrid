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


/*! \file DataAccessObject.js
 \brief The DataAccessObject.js file contains an easy to use wrapper for the SQLite functionality of the device.  The DataAccessObject constructor is used in the databaseDefinitions.js file.
 
 */
DataAccessObject.SYNC_NONE = 0;
DataAccessObject.SYNC_ON_DEMAND = 1;
DataAccessObject.SYNC_PERIODIC = 2;
DataAccessObject.SYNC_CONTINUOUS = 3;

/*
 *  the sqlite database used in safari and UIWebView as well as the 
 *  JavaScript to native implementation handle all requests asynchronously.
 */




/*! \brief Constructor for the SQLite wrapper
 *  @param dbName A <b>String</b> that is the name of the database file to use.  If the name ends in .sqlite then there must be a matching .sqlite file included in the application when it ships.
 @param dbVersion A <b>double</b> used for non .sqlite file based databases.
 @param dbDescription a <b>String</b> that is descriptive of the purpose of the database.  Used only for non .sqlite file based databases.
 @param dbSize the size of the database in bytes.  Used only for non .sqlite file based databases.
 *  @return a DataAccessObject that is ready for data queries and insertions.
 */
function DataAccessObject(dbName, dbVersion, dbDescription, dbSize, isNativeDatabase){
	//the default command sent as part of the URL
	this.syncType = 'sync';
	if(dbName.match('.sqlite'+"$")=='.sqlite' || isNativeDatabase){
		this.isNativeDatabase = true;
	}
    
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
			//debug('periodic syncing');
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
		/*if(window.syncDataManipulationFunction && dataToSync){
         dataToSyc = syncDataManipulationFunction(dataToSyc);
         }*/
        if(!this.currentlySyncing){
            this.currentlySyncing = true;
            var aSyncCall = new ServerAccessObject(this.syncURL, this.timeoutSeconds);
			//debug('syncing with: '+this.syncType+' '+this.login[0]+' '+this.login[1]+' '+lastSyncDate+' '+encodeURIComponent(JSON.stringify(dataToSync)));
            aSyncCall.setData(ServerAccessObject.TEXT,null,'cmd='+this.syncType+'&uname='+this.login[0]
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
        qc.getDeviceData(dbName, SQL, preparedStatementParameters);
    }
    this.setNativeData = function(SQL, preparedStatementParameters){
        qc.setDeviceData(dbName, SQL, preparedStatementParameters);
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
        var lowerCaseSQL = SQL.toLowerCase();
        if(lowerCaseSQL.indexOf('select') == 0){
            if(this.isNativeDatabase){
                this.getNativeData(SQL, preparedStatementParameters);
            }
            else{
                this.dbAccess(SQL, preparedStatementParameters, false);
            }
        }
        else{
            var storedSyncSQL = this.syncStore[SQL];
            /*
             *  this may be a syncronized statement.  Check and handle if it is
             */
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
        
    }
	
    this.getData = function(SQL, preparedStatementParameters){
		if(this.isNativeDatabase){
			this.getNativeData(SQL, preparedStatementParameters);
		}
		else{
			this.dbAccess(SQL, preparedStatementParameters, false);
		}
    }
    
    this.setData = function(SQL, preparedStatementParameters){
		var storedSyncSQL = this.syncStore[SQL];
		/*
		 *  this may be a syncronized statement.  Check and handle if it is
		 */
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
    var self = this;
    this.dbAccess = function(SQL, preparedStatementParameters, treatAsChangeData){
        var passThroughParameters = generatePassThroughParameters();
		var currentExecutionKey = passThroughParameters[0];
        if(!this.db){
            this.db = openDatabase(dbName, dbVersion, dbDescription, dbSize);   
        }
        var queryResult = new QueryResult();
        this.db.transaction(function(tx) {
                            tx.executeSql(SQL, preparedStatementParameters, function(tx, resultSet) {
                                          //check to see if there was a sync key passed in instead of SQL
										  //debug(SQL);
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
                                          queryResult.data = queryResult.results;//backward compatability
										  }
										  var theResults = new Array();
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  var executionObject = executionMap[currentExecutionKey];
										  //debug('end of success function: '+executionObject);
										  if(executionObject){
										  requestHandler(executionObject['cmd'], executionObject['params'], [theResults, currentExecutionKey]);
										  }
                                          
                                          }//end of sql execute success callback function
                                          , function(tx, error) {
										  debug(error.message);
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
		var currentExecutionKey = passThroughParameters[0];
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
							//debug('sql: '+anSQL);
							var errorHandled = false;
							tx.executeSql(anSQL,
										  params, 
										  function(tx, resultSet) {
                                          
										  numInserts++;
										  
										  var theResults = new Array();
										  var queryResult = new QueryResult();
                                          queryResult.errorMessage = 'not an error';
										  theResults.push(queryResult);
										  theResults.push(passThroughParameters);
										  var executionObject = executionMap[currentExecutionKey];
										  //debug('success');
										  if(executionObject && numInserts == keyCount){
										  //debug('next handler');
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

/*
 *   These are a series of false methods of the DataAccessObject inserted here to get Doxygen to generate the documentation.  They don't interfere with the instance methods 
 *   actually used by the object.  This is a funky way of doing things.  But what are you going to do?
 */

/*! \fn DataAccessObject.closeDatabase()
 @brief DataAccessObject.closeDatabase() <br/> The closeDatabase function closes the connection to the underlying database.
 
 @return nothing
 */
//function DataAccessObject.closeDatabase(){}

/*! \fn DataAccessObject.startTransaction()
 @brief DataAccessObject.startTransaction() <br/> The startTransaction function begins a transaction against the underlying database.
 
 @return nothing
 */
//function DataAccessObject.startTransaction(){}


/*! \fn DataAccessObject.commit()
 @brief DataAccessObject.commit() <br/> The commit function commits all trasact calls made as part of a transaction previously started against the underlying database.
 
 @return nothing
 */
//function DataAccessObject.commit(){}


/*! \fn DataAccessObject.rollback()
 @brief DataAccessObject.rollback() <br/> The rollback function unwinds any successful transact calls that happen between the beginTransaction and commit method calls of a transaction previously started against the underlying database.
 
 @return nothing
 */
//function DataAccessObject.rollback(){}



/*! \fn DataAccessObject.transact(SQL, preparedStatementParameters)
 @brief DataAccessObject.transact(SQL, preparedStatementParameters) <br/> The transact function executes a statement against the underlying database.  This transact call can be made independently or within a transaction.
 @param SQL A <b>String</b> that is a standard SQLite statement or has prepared statement form.
 @param preparedStatementParameters An optional <b>Array</b> of items to be matched with the '?' characters in the SQL string if the SQL has prepared statemetn form.  The number of elements of this array must be the same as the number of '?' characters in the SQL string.
 @return nothing
 */
//function DataAccessObject.transact(SQL, preparedStatementParameters){}



/*! \brief Constructor for an object that contains the outcome of a database or web server data request.  Depending on the type of database or web server request some of these values will or will not have values
 This object has the following attributes:
 @li <b>results</b>  An <b>Array of Arrays</b> that is a temporary 'table' of a query
 @li <b>errorMessage</b>  A <b>String</b> that contains an error message from the underlying database if there is one or 'not an error' if the SQL executed without error.
 @li <b>numRowsFetched</b> An <b>int</b> indicating the number of rows in the results Array
 @li <b>fieldNames</b> An <b>Array</b> of strings that are the field names that match the corresponding columns in the results temporary 'table'.
 @li <b>rowsAffected</b> A <b>int</b> representing the records changed as the result of a non-select type statement.
 *  @return A QueryResult that contains all the results of the request.
 */

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






