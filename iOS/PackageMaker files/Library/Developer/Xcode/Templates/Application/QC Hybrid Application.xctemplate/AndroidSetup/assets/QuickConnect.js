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
 *  This section of the file contains a facade function that is a wrapper around the front 
 *  controller used to convert the parameters JSON string to a JavaScript Array before 
 *  calling the handleRequest front controller.  
 *  This method is used to call JavaScript from Objective-C.
 */

function handleJSONRequest(cmd, parametersString){
	var paramsArray = null;
	if(parametersString){
		var paramsArray = JSON.parse(parametersString);
        /*
        *  android only
        */
        paramsArray = paramsArray[0];
	}
    handleRequest(cmd, paramsArray);
	//return cmd +" "+parametersString;
}


/*
 *  This section of the file contains the front controller through which all requests for application activity are made.
 */

qc.handleRequest = function(aCmd, paramArray){
    try{
		if(!paramArray){
			paramArray = new Array();
		}
        requestHandler(aCmd, paramArray, null);
    }
    catch(err){
        logError(err);
    }
}
window.handleRequest = qc.handleRequest;

qc.handleError = function(aCmd, paramArray){
	dispatchToECF(aCmd, paramArray);
}
window.handleError = qc.handleError;

function requestHandler(aCmd, paramArray, callBackData){
	/* Save our global requestHandler function and redefine it to
	 * prevent it from being inappropriately called from within a
	 * running command stack.
	 */
	var globalRequestHandler = window.requestHandler;
	window.requestHandler = function(aCmd, paramArray, callBackData){
	 alert("An attempt was made to start or continue a command stack from within"
		  +" an a running command stack. This cannot work properly and"
		  +" has been prevented. If you must trigger this command stack"
		  +" from within a running command stack, use\n"
		  +" setTimeout('handleRequest('"+aCmd+"', parametersArray);',1);\n\nBetter yet never call one stack from within another.  Engineer around it."
		  +"Prevented Command: "+aCmd);
	 return false;
	};
	
	if(aCmd != null){
		if(dispatchToValCF(aCmd, paramArray) == qc.STACK_CONTINUE){
            try{
                var data = dispatchToBCF(aCmd, paramArray, callBackData);
                if(data != qc.STACK_EXIT){
                    dispatchToVCF(aCmd, data, paramArray);
                }
            }
            catch(err){
                logError(err);
            }
		}
		else{
			dispatchToECF(aCmd, 'validation failed');
		}
	}
	
	// Command stack completed. Restore our global requestHandler.
	window.requestHandler = globalRequestHandler;
}

function handleRequestCompletionFromNative(callBackString) {
    var unParsed = unescape(callBackString);
    unParsed = qc.replaceAll(unParsed, '"{', '{');
    unParsed = qc.replaceAll(unParsed, '}"', '}');
    unParsed = qc.replaceAll(unParsed, '+', ' ');
    unParsed = qc.replaceAll(unParsed, '__PlUs__', '+');
    try{
        var callBackData = JSON.parse(unParsed);
        callBackData = qc.replaceSpecial(callBackData);
        var anExecutionKey = callBackData[1];
        alert('ex key: '+anExecutionKey);
        if(anExecutionKey){
            var executionObject = executionMap[anExecutionKey];
            alert('ex obj: '+executionObject);
            if(executionObject){
                requestHandler(executionObject['cmd'], executionObject['params'], callBackData);
            }
        }
    }
    catch(err){
        logError(err);
    }
}

/*
 *   This section of the file contains the validation, security, business, view, and error controllers.
 *
 */
var validationMap = new Array();
var businessMap = new Array();
var viewMap = new Array();
var errorMap = new Array();
var securityMap = new Array();


/*
 * the dispatch functions are used to handle all events from the GUI, 
 * all events when the server sends data back as a response to a request, 
 * and all error events.
 */

//'global' values used if a call is made to Objective-C from within a BCF

var executionMap = new Object();
var executionCount = 0;
var executionKey = "NOT_IN_A_BCF_FOR_CMD_STACK";
/*
 *  the function serializes any asynchrounous calls made via AJAX or database access.
 *  It accumulates the results of all calls to the BCF's into a results array and then returns
 *  it after all BCF's have been called.
 */
function dispatchToBCF(aCmd, paramArray, callBackData) {
	// create our internal executionKey
    var internalExecutionKey = null;
	// save our global version of generatePassThroughParameters
	var global_generatePassThroughParameters = window.generatePassThroughParameters;

	// replace it with a version specific to this execution context
	window.generatePassThroughParameters = function(){
		/*
		 *  This function supports the passing of the parameters currently being used out of the current thread
		 *  of execution and into another.  This can be because of a call to any of the asynchronous data access
		 *  methods.  These can be AJAX calls, browser SQLite calls, or device based SQLite calls.
		 *
		 *  It is being uniquely (re)defined here so that it has access to the private internalExecutionKey for
		 *  this command stack (generated on the stack's first run, and obtained from callBackData subsequently.
		 *  It deliberately never touches the global window.executionKey so that an event triggered by a command stack
		 *	(setTimeout, setInterval, a DOM modification event, or some other asynchronous activity) that (inappropriately)
		 *  calls a function the uses generatePassThroughParameters, will not restart the previously running command stack.
		 */
		// disable the use of generatePassThroughParameters() after the first use in a BCF
		window.generatePassThroughParameters = function(){
		 alert("You have attempted to use more than one asynchronous function in the same BCF. This cannot"
			  +" work correctly and will result in the command stack being improperly resumed multiple times"
			  +" with incorrectly ordered results values. Therefore, resumption of this command stack has"
			  +" has been prevented for all but the first asynchronous function.");
			return "MORE_THAN_ONE_ASYNC_CALL_IN_A_BCF";
		};
		
		//alert("Global execution key: " + executionKey);
		alert("Returning internal execution key: " + internalExecutionKey);
		return [internalExecutionKey];
	}

	
    var executionObject = null;
    //alert(' callback data '+JSON.stringify(callBackData));
    if(callBackData && callBackData.length > 0){
        var anExecutionKey = callBackData[1];
        alert('ex key from callback: '+anExecutionKey);
        internalExecutionKey = anExecutionKey;
        executionObject = executionMap[anExecutionKey];
        alert('pushing: '+JSON.stringify(callBackData[0]));
        executionObject['accumulatedData'].push(callBackData[0]);
        
    }
    else{
        //alert('no callback data');
        var curDate = new Date();
        internalExecutionKey = curDate.getTime()+'_'+executionCount;
        //alert('new key: '+executionKey);
        executionCount++;
        executionObject = new Object();
        executionObject['cmd'] = aCmd;
        executionObject['params'] = paramArray;
        executionObject['accumulatedData'] = new Array();
        executionObject['numFuncsCalled'] = 0;
        executionMap[internalExecutionKey] = executionObject;
    }
	if(aCmd){
		var commandList = businessMap[aCmd];
        if(!commandList){
            commandList = new Array();
            businessMap[aCmd] = commandList;
        }
        var numCommands = commandList.length;
     
        for(var i = executionObject['numFuncsCalled']; i < numCommands; i++){
			// save our local version of generatePassthroughParameters
			// so we can reset it with each BCF called
			var local_generatePassThroughParameters = window.generatePassThroughParameters;
			
            executionObject['numFuncsCalled'] = executionObject['numFuncsCalled'] + 1;
            var funcToCall = commandList[i];
            var result = null;
            try{
                result = funcToCall(paramArray, executionObject['accumulatedData']);
                if(result == qc.STACK_EXIT){
                	executionMap[internalExecutionKey] = null;

        			// now restore our local version of generatePassThroughParameters
        			// for the next BCF
        			window.generatePassThroughParameters = local_generatePassThroughParameters;
                    return qc.STACK_EXIT;
                }
                else if(result == qc.WAIT_FOR_DATA){
                	alert("wait was returned");
                	return qc.STACK_EXIT;
                }
                else{
                    executionObject['accumulatedData'].push(result);
                }
            }
            catch(err){
                logError(err);
                dispatchToECF('runFailure', err.message);
            }
			// now restore our local version of generatePassThroughParameters
			// for the next BCF
			window.generatePassThroughParameters = local_generatePassThroughParameters;
        }
    }
	
	// set our global generatePassthroughParameters back to it's original value
	window.generatePassThroughParameters = global_generatePassThroughParameters;
	
    return executionObject['accumulatedData'];
}

function dispatchToVCF(aCmd, data, paramArray){
    /*
     * the command will be null if dispatch is 
     * being called due to a successful return 
     * from the server or the database.
     */
    if(aCmd){
		var vcfFuncList = viewMap[aCmd];
		if(vcfFuncList == null){
			vcfFuncList = new Array();
		}
        var numFuncs = vcfFuncList.length;
        for(var i = 0; i < numFuncs; i++){
            var retVal = null;
			try{
				retVal = vcfFuncList[i](data, paramArray);
			}
			catch(err){
				logError(err);
			}
            /*
             * a view control function can return 'stop' or nothing.
             * if 'stop' is returned then no more vcfs will be called
             * from the vcf stack
             */
            if(retVal && retVal == 'stop'){
                break;
            }
        }
    }
}

function dispatchToECF(errorCommand, errorMessage, paramArray){
    /*
     * the command will be null if dispatch is 
     * being called due to a successful return 
     * from the server or the database.
     */
    if(errorCommand){
		var ecfFuncList = errorMap[errorCommand];
		if(ecfFuncList == null){
			ecfFuncList = new Array();
		}
        var numFuncs = ecfFuncList.length;
		//alert('num error funcs: '+numFuncs);
        for(var i = 0; i < numFuncs; i++){
            var retVal = null;
			try{
				retVal = ecfFuncList[i](errorMessage, paramArray);
			}
			catch(err){
				logError(err);
			}
            /*
             * a view control function can return 'stop' or nothing.
             * if 'stop' is returned then no more ecfs will be called
             * from the ecf stack
             */
            if(retVal && retVal == 'stop'){
                break;
            }
        }
    }
}

//DEPRICATED
function dispatchToSCF(securityCommand, data){
	return check(securityCommand, 'security', data);
}

/*  
 * The checkSecurity is responsible for executing all of the default and 
 * any custom validation functions associated with a specific command.
 */
function dispatchToValCF(command, paramArray){
	var map = validationMap;
	var commandFuncs = map[command];
	if(commandFuncs){
		var numFuncs = commandFuncs.length;
		for(var i = 0; i < numFuncs; i++){
			retVal = commandFuncs[i](paramArray);
			if(retVal == qc.STACK_EXIT){
				return qc.STACK_EXIT;
			}
		}
	}
	return qc.STACK_CONTINUE;
}

/*
 * DEPRICATED.   This function is not intended to be called directly by the programmer.  Do not use it.  
 */
function check(command, type, data){
	var retVal = true;
	/*
	 * execute all of the default functions that apply to all commands if there are any default functions defined.
	 */
	var map = securityMap;
	if(type == 'validation'){
		map = validationMap;
	}
	if(retVal == true){
		commandFuncs = map[command];
        
		if(commandFuncs){
			var numFuncs = commandFuncs.length;
			for(var i = 0; i < numFuncs; i++){
				retVal = commandFuncs[i](data);
				if(retVal == false){
					break;
				}
			}
		}
	}
	return retVal;
}