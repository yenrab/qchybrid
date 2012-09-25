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

/*! \file ServerAccessObject.js
 \brief The ServerAccessObject.js file contains an easy to use AJAX wrapper for accessing remote web applications and services.
 
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


/*! \brief Constructor for the AJAX wrapper object.  
 
 @param URL A <b>String</b> that is the URL for the remote server or service.
 @param timeoutSeconds An <b>int</b> that determines the number of seconds the transaction should be attempted before a timeout error is generated.
 
 *  @return a ServerAccessObject that is ready for data transactions with remote servers and services.
 */

function ServerAccessObject(URL, timeoutSeconds){
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
        var passThroughParameters = qc.generatePassThroughParameters();
		this.makeCall('GET', dataType, refresh, parameterSequence, null, HTTPHeaders, null, passThroughParameters);
	}
	this.setData = function(dataType, parameterSequence, data, HTTPHeaders, contentType){
		this.makeCall('POST', dataType, true, parameterSequence, data, HTTPHeaders, contentType, passThroughParameters);
        var passThroughParameters = qc.generatePassThroughParameters();
	}
    
    this.transact = function(transactionType, dataType, refresh, parameterSequence, HTTPHeaders){
        var passThroughParameters = generatePassThroughParameters();
        if(transactionType.toLowerCase() == 'post'){
            this.makeCall('POST', dataType, true, parameterSequence, data, HTTPHeaders, contentType, passThroughParameters);
        }
        else{
            this.makeCall('GET', dataType, refresh, parameterSequence, null, HTTPHeaders, null, passThroughParameters);
        }
    }
	
	
	var http = null;
	
	/*
	 * Executes the call to the server to post or get data. Creation and use of an xmlHttpRequestObject happens within this method.
	 * parameter 1: {String} callType - GET, POST, or other HTTP type
	 * parameter 2: {String} callBackCmd - the command to execute when the server returns a completed response.
	 * parameter 3: {String} dataType - the data type of the response data with acceptable values of either Text or XML
	 * parameter 4: {boolean} refresh - a flag indicating if refreshing should be enforced even if the data is currently cached on the server.
	 * parameter 5: {String} parameterSequence - the parameter list to be added to the URL
	 * parameter 6: {String or DOM element} data - any data to be sent with a POST type request
	 * parameter 7: {String} contentType - the value to be used for the Content-Type HTTP header sent with every POST.
	 * parameter 8: {Object} HTTPHeaders - a map of headers and header values to send to the server
	 * returns true if request object can be used otherwise it returns false.
	 */
	this.makeCall = function(callType, dataType, refresh, parameterSequence, data, HTTPHeaders, contentType, passThroughParameters){
        
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
		
		else if(parameterSequence && !(this.URL.indexOf('?') == this.URL.length -1)){
			this.URL += '?';
		}
        
		if(data == null){
			data = '';
		}
        /*
		 * Get the request object to use
		 */
		try {
			http = new XMLHttpRequest();
		} 
		catch(e) {
			return false;
		}
		var isAsynch = true;//enforce always asynchronous
		
		
		/*
		 *	open a connection to the server located at 'this.URL'.
		 */
		http.open(callType,this.URL+parameterSequence, isAsynch);
		if(refresh){
			/*
			 *  if we are to disable caching and force a call to the server, then the 'If-Modified-Since' header will 
			 *	need to be set to some time in the past.
			 */
			http.setRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" );
		}
		//if there are headers then add them to the request
		if(HTTPHeaders != null){
			for(var key in HTTPHeaders){
				http.setRequestHeader(key,HTTPHeaders[key]);
			}
		}
		
        //if a POST is being done and data is to be sent, set the content type header so that the data will be encoded correctly and sent on to the server for decoding
        if(callType =="POST" && data !=null){
			if(contentType == null){
				http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
			}
			else{
				http.setRequestHeader('Content-Type', contentType);
			}
        }
		/*
		 *	Set the function to be called when the server communicates with the client.
		 *	For the ServerAccessObject this is an inline function that is the callback function defined below.
		 *	The reason for the inline function is so that variables from within the makeCall method can be used.  If a non-inline 
		 *	function is used then only the name of the function to be called is set as the onreadystatechange 
		 *	method of the http class.
		 */
		http.onreadystatechange = function(){
            /*
			 *	Only handle completed, finished messages from the server
			 */
            if((http.readyState == ServerAccessObject.COMPLETE && http.status != 0) || http.aborted){
				clearTimeout(http.requestTimer);
                //the standard holder for all types of data queries
                var queryResult = new QueryResult();
                //default errorMessage
                queryResult.errorMessage = "not an error";
                //these are custom error headers that you can send from your server code
                //if you choose.  
                if(!http.aborted){
                    queryResult.errorNumber = http.getResponseHeader('QC-Error-Number');
                    queryResult.errorMessage = http.getResponseHeader('QC-Error-Message');
                }
                if(http.aborted){
                    queryResult.errorNumber = -100;
                    queryResult.errorMessage = "Request timed out.";
                }
                else if(http.status != ServerAccessObject.HTTP_OK 
                        && http.status != ServerAccessObject.HTTP_LOCAL
                        && http.status != ServerAccessObject.OSX_HTTP_File_Access){
                    queryResult.errorNumber = http.status;
                    queryResult.errorMessage = "Bad access type.";
                }
                
				
				/*
				 *  Retrieve the data if the server returns that the 
                 *  processing of the request was successful or if
				 *  the request was directly for a file on the server disk.
				 *  Get it as either Text or XML
				 */
                if(queryResult.errorNumber == null){
					var unmodifiedData = http['response'+dataType];
					if(dataType != ServerAccessObject.XML){
						queryResult.results = unescape(unmodifiedData);
                        queryResult.data = queryResult.results;
					}
					else{
						queryResult.data = unmodifiedData;
					}
                    if(!dispatchToSCF(passThroughParameters[0], queryResult.data)){
                        queryResult.errorNumber = ServerAccessObject.INSECURE_DATA_RECEIVED;
                        queryResult.errorMessage = "Insecure data recieved.";
                    }
                }
                /*
                 *  Call the next Control Function in the list passing the resultData
                 */
				/*
				 *  This may have been called from outside a dispatchToBCF function.
				 *  If so, then there has been no executionObject defined.
				 */ 
                var theExecutionKey = passThroughParameters[0];
				var executionObject = executionMap[theExecutionKey];
				if(executionObject){
					requestHandler(executionObject['cmd'], executionObject['params'], [queryResult, theExecutionKey]);
				}
            }
			
        };
		/*
		 *	Send off the completed request and include any data for a 'POST' request.
		 */
		//debug('sending data: '+data);
		http.send(data);
        http.requestTimer = setTimeout(function() {
									   try{
									   http.abort();
									   http.aborted = true;
									   http.onreadystatechange();
									   }
									   catch(err){
									   logError(err);
									   }
									   
									   },this.timeout
									   );
		
	}
}




/*! \fn LocationObject.transact(transactionType, dataType, refresh, parameterSequence, HTTPHeaders)
 @brief LocationObject.transact(transactionType, dataType, refresh, parameterSequence, HTTPHeaders) <br/> The transact function sends and receives data to and from the remote server.
 @param transactionType A <b>String</b> that indicates the type of transaction.  Valid values are 'GET' and 'POST'.
 @param dataType A <b>String</b> that indicates the expected type of the data received from the server.  Valid values are 'Text' and 'XML'.
 @param refresh An optional <b>boolean</b> indicating if a forced refresh of the data should occur.  true forces refresh false allows cached data if it is available.
 @param parameterSequence An optional <b>String</b> that contains the key/value pairs found after the ? character in a URL.
 @param HTTPHeaders An optional <b>Key/Value Object containing HTTP Header names as the keys and the header values as the values of the Object.
 @return nothing
 */
//function ServerAccessObject.transact(transactionType, dataType, refresh, parameterSequence, HTTPHeaders){}