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
 * A representaion of the unititialized request state '0'.
 */
ServerAccessObject.UNITITIALIZED = 0;

/*
 * A representaion of the setup but not sent request state '1'.
 */
ServerAccessObject.SETUP = 1;

/*
 * A representaion of the sent but not having recieved request state '2'.
 */
ServerAccessObject.SENT = 2;

/*
 * A representaion of the in process request state '3'.
 */
ServerAccessObject.IN_PROCESS = 3;

/*
 * A representaion of the complete request state '4'.
 */
ServerAccessObject.COMPLETE = 4;



/*
 * A representaion of the HTTP status code for file retrieval on OSX 'undefined'.  For other HTTP status codes go to www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
 */
ServerAccessObject.OSX_HTTP_File_Access = null;

/*
 * A representaion of the HTTP status code for OK '200'.  For other HTTP status codes go to www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
 */
ServerAccessObject.HTTP_OK = 200;

ServerAccessObject.HTTP_LOCAL = 0;

/*
 * A representaion of the HTTP status code for Bad Request '400'.  For other HTTP status codes go to www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
 */
ServerAccessObject.HTTP_BADREQUEST = 400;

/*
 * A representaion of the HTTP status code forVersion Not Supported '505'.  For other HTTP status codes go to www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
 */
ServerAccessObject.HTTP_VERSION_NOT_SUPPORTED = 505;


/*
 * A representation of a data security check failure.
 */

ServerAccessObject.INSECURE_DATA_RECEIVED = -100;

/*
 * The two legal values for the data retreival type
 */

ServerAccessObject.TEXT = 'Text';
ServerAccessObject.XML = 'XML';
/*
 * Indicators of if refresh is to be forced.
 */
ServerAccessObject.REFRESH = true;
ServerAccessObject.NO_REFRESH = false;

/*
 *Constructor for a new ServerAccessObject instance. The purpose the Server Access Object is to 
 *  create all requests for data from the server as well as requests for posting of data
 *  to the server and make all preparations required to successfully make 
 *  these calls.  All calls made are asynchronous.
 *  parameter 1: URL - the URL of the main access point for the application
 */
function ServerAccessObject(URL, timeoutSeconds){
    var currentExecutionKey = executionKey;
	//attribute
	this.URL = URL;
    //default timeout is set to 10 seconds
    this.timeout = 10000;
    if(timeoutSeconds){
        this.timeout = timeoutSeconds*1000;
    }
	
	
	//put the getData and setData methods in delay loop until the data is returned and then return the data to the user.
	//methods
	this.getData = function(dataType, refresh, parameterSequence, HTTPHeaders){
        
        var passThroughParameters = generatePassThroughParameters();
		this.makeCall('GET', dataType, refresh, parameterSequence, null, HTTPHeaders, passThroughParameters);
	}
	this.setData = function(dataType, parameterSequence, data, HTTPHeaders){
        var passThroughParameters = generatePassThroughParameters();
		this.makeCall('POST', dataType, true, parameterSequence, data, HTTPHeaders, passThroughParameters);
	}
	
	/*
	 * Executes the call to the server to post or get data. Creation and use of an xmlHttpRequestObject happens within this method.
	 * parameter 1: {String} callType - GET, POST, or other HTTP type
	 * parameter 2: {String} callBackCmd - the command to execute when the server returns a completed response.
	 * parameter 3: {String} dataType - the data type of the response data with acceptable values of either Text or XML
	 * parameter 4: {boolean} refresh - a flag indicating if refreshing should be enforced even if the data is currently cached on the server.
	 * parameter 5: {String} parameterSequence - the parameter list to be added to the URL
	 * parameter 6: {String or DOM element} data - any data to be sent with a POST type request
	 * parameter 7: {Object} HTTPHeaders - a map of headers and header values to send to the server
	 * returns true if request object can be used otherwise it returns false.
	 */
	this.makeCall = function(callType, dataType, refresh, parameterSequence, data, HTTPHeaders, passThroughParameters){
        
		var isJSONCall = false;
        if(callType != 'GET'){
            callType = 'POST';
        }
		if(dataType != ServerAccessObject.XML){
			dataType = 'Text';
		}
		if(refresh == null){
			refresh = false;
		}
		if(parameterSequence == null){
			parameterSequence = '';
		}
		if(data == null){
			data = '';
		}
        //debug('making web call: '+(qcDevice == null));
		//debug(qcDevice);
        var stuff = qcDevice.webCall(callType, this.URL, data, currentExecutionKey)
		/*
        this.requestTimer = setTimeout(function() {
										   AJAXonReadyStateChange('aborted');
                                       }, this.timeout
                                       );
                                       */
	}
}

function AJAXonReadyStateChange(results, currentExecutionKey){
        //clearTimeout(this.requestTimer);
        //debug('ready key: '+currentExecutionKey);
        //the standard holder for all types of data queries
        var queryResult = new QueryResult();
        
        if(results == 'aborted'){
            queryResult.errorNumber = -100;
            queryResult.errorMessage = "Request timed out.";
        }
        /*
         *  Retrieve the data if the server returns that the 
         *  processing of the request was successful or if
         *  the request was directly for a file on the server disk.
         *  Get it as either Text or XML
         */
        if(queryResult.errorNumber == null){
            //debug('results: '+results);
            queryResult.data = unescape(results);
            //debug('data: '+queryResult.data);
            //queryResult.data = JSON.parse(queryResult.data);
            //debug('json: '+JSON.stringify(queryResult.data));
        }
        /*
         *  Call the next Control Function in the list passing the resultData
         */
        /*
         *  This may have been called from outside a dispatchToBCF function.
         *  If so, then there has been no executionObject defined.
         */
        var executionObject = executionMap[currentExecutionKey];
        //debug('execObje: '+executionObject);
        if(executionObject){
            //debug('params: '+JSON.stringify(executionObject['params']));
            requestHandler(executionObject['cmd'], executionObject['params'], [queryResult, currentExecutionKey]);
        }
        //debug('done');
}