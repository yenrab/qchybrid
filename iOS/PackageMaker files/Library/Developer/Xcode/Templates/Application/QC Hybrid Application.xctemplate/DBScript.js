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
 *  The purpose of the DBScript object is to allow multiple database
 *  updates to be executed with one call.  Build your script by using 
 *  the addStatement method and then run it using the executeSetDataScript 
 *  method.
 */

function DBScript(theDatabase){
	if(theDatabase){
		this.numGeneratedParams = 0;
		this.statements = new Object();
		this.linker = new Object();
		/*
		 * Use this method to add SQL statements and matching prepared statement parameters, if any,
		 * to your script.  The statements will be executed in the order you add them.
		 */
		this.addStatement = function(SQL, statementParameters){
			if(theDatabase.isNativeDatabase){
				SQL = escape(SQL);
            }
			var stmtArray = null;
			var statementsToStore = new Array();
			var storedSyncSQL = theDatabase.syncStore[SQL];
			//alert('stored: '+storedSyncSQL);
			/*
			 *  this may be a syncronized statement.  Check and handle if it is
			 */
			if(!storedSyncSQL){
				this.numGeneratedParams++;
				stmtArray = [this.numGeneratedParams, statementParameters];
				statementsToStore[0] = [stmtArray, SQL];
			}
			else{
				
				var storageParams = statementParameters != null ? JSON.stringify(statementParameters) : "";
				this.numGeneratedParams++;
				var syncStatementParameters = [new Date().toUTCString(), SQL, storageParams];
				stmtArray = [this.numGeneratedParams, syncStatementParameters];
				statementsToStore[0] = [stmtArray, "INSERT INTO sync_temp VALUES(?, ?, ?)"];
				
				this.numGeneratedParams++;
				stmtArray = [this.numGeneratedParams, statementParameters];
				statementsToStore[1] = [stmtArray, storedSyncSQL];
			}
			
			for(var i = 0; i < statementsToStore.length; i++){
				var storedStatement = statementsToStore[i];
				stmtArray = storedStatement[0];
				SQL = storedStatement[1];
				var stmt = this.statements[SQL];
				if(!stmt){
					this.statements[SQL] = SQL;
					stmt = this.statements[SQL];
				}
				key = this.numGeneratedParams
				if(statementParameters){
					key = JSON.stringify(stmtArray);
				}
				this.linker[key] = stmt;
			}
		}
		/*
		 *  This method allows only for data insertion and modification.
		 *  Not queries.
		 */
		this.executeSetDataScript = function(){
			if(theDatabase.isNativeDatabase){
				try{
					var dataArray = new Array();
					var data = new Array();
					//put the values into an array so that they retain the correct order on the OC side
					for(key in this.linker){
						var row = [key,this.linker[key]];
						data.push(row);
						//var data = JSON.stringify(this.linker);
					}
					dataArray.push(theDatabase.dbName);
					dataArray.push(data);
					
					//put in a placeholder
					dataArray.push(new Array());
					var callBackParameters = generatePassThroughParameters();
					dataArray.push(callBackParameters);
					makeCall("runDBScript", JSON.stringify(dataArray));
				}
				catch(err){
					logError(err);
				}
			}
			else{
				theDatabase.executeBatch(this.linker);
			}
		}
	}
	else{
		logError("DBScript requires a DataAccessObject as a parameter to it's constructor");
	}
	
}

