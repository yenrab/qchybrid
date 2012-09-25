/*
 Copyright (c) 2009 Lee Barney
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

function LocationObject(){
	this.trackingId = null;

	this.getLocation = function(maxAgeSeconds, searchTimeoutSeconds){
		if(maxAgeSeconds == null){
			maxAgeSeconds = .1	;
		}
		if(searchTimeoutSeconds == null){
			searchTimeoutSeconds = 5;
		}
		var options = new Object();
		options.maximumAge = maxAgeSeconds * 1000;
		options.timeout = searchTimeoutSeconds * 1000;
		
		var currentExecutionKey = executionKey;
		var passThroughParameters = generatePassThroughParameters();
		var theResults = new Array();
		var queryResults = new Object();
		var executionObject = executionMap[currentExecutionKey];
		navigator.geolocation.getCurrentPosition(function (position){
												 //debug(position);
												 queryResults.data = position;
												 theResults.push(queryResults);
												 theResults.push(passThroughParameters);
												 if(executionObject){
													requestHandler(executionObject['cmd'], executionObject['params'], [queryResults, currentExecutionKey]);
												 }
												 
												 
											},
											function(error){
												 queryResults.error = error;
												 theResults.push(queryResults);
												 theResults.push(passThroughParameters);
												 if(executionObject){
													requestHandler(executionObject['cmd'], executionObject['params'], [queryResults, currentExecutionKey]);
												 }
										    }, options);
		
	}
	
	this.trackLocation = function(updateCommand){
		
		this.trackingId = navigator.geolocation.watchPosition(function (position){
												var theResults = new Array();
												var queryResults = new Object();
												 queryResults.data = position;
												 theResults.push(queryResults)
												 handleRequest(updateCommand, [queryResults]);
												 
											},
											function(error){
												var theResults = new Array();
												var queryResults = new Object();
												 queryResults.error = error;
												 theResults.push(queryResults);
												 handleRequest(updateCommand, [queryResults]);
											}
												 
										);
		
	}
 
	this.stopTracking = function(){
		if(this.trackingId){
			navigator.geolocation.clearWatch(this.trackingId);
			this.trackingId = null;
		}
	}
 
}