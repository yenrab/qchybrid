/*
 Copyright (c) 2008, 2009, 2011 Lee Barney
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

/*! \file QCUtilities.js
 \brief The QCUtilities.js file contains a series of helper functions for you to use in creating your QCFamily Hybrid application.
 
 <em><b>All functions are listed as variables in these files.</b></em>  However, they truely are JavaScript functions.
 
 */

qc.WAIT_FOR_DATA = 'wait';
qc.STACK_EXIT = null;
qc.STACK_CONTINUE = true;

/* //this is commented out since it was causing itermittent errors on iOS.
 String.prototype.trim = function(){return 
 (this.replace(/^[\s\xA0]+/, "").replace(/[\s\xA0]+$/, ""))}
 */
String.prototype.startsWith = function(str) 
{return (this.match("^"+str)==str)}

String.prototype.endsWith = function(str) 
{return (this.match(str+"$")==str)}

qc.showSyncView = function(){
    var syncView = document.createElement('div');
    syncView.id = 'syncView';
    document.getElementsByTagName('body')[0].appendChild(syncView);
    syncView.className = 'syncDisplay';
    var syncingText = document.createElement('div');
    syncView.appendChild(syncingText);
    syncingText.className = 'syncText';
    syncingText.appendChild(document.createTextNode('Synchronizing..'));
    var syncUpdateText = document.createElement('div');
    syncUpdateText.id = 'syncUpdateText';
    syncView.appendChild(syncUpdateText);
    syncUpdateText.className = 'progressText';
    
    syncUpdateText.appendChild(document.createTextNode('Gathering Local Data'));
	turnOffScrolling();
}
window.showSyncView = qc.showSyncView;

//the acceleration function call that is made from the underlying Objective-C framework when the device experiences acceleration
qc.accelerate = function(x, y, z){
    
	var accelObject = new AccelerationObject();
	accelObject.x = x;
	accelObject.y = y;
	accelObject.z = z;
	handleRequest('accel', accelObject);
	return true;
}
window.accelerate = qc.accelerate;

//an object to hold acceleration values in all three dimensions.
function AccelerationObject(){
	this.x = 0;
	this.y = 0;
	this.z = 0;
}
/*! \fn qc.stopBounce()
 @brief qc.stopBounce() <br/> The qc.stopBounce function causes the view of the entire html page to not have any elastic behavior when the user tries to scroll past the end of the page.
 */
qc.stopBounce = function(){
    var height = document.body.scrollHeight;
    if(height > 480){
        document.ontouchmove = function(event){
            event.preventDefault();
        }
    }
}
window.stopBounce = qc.stopBounce;
/*! \fn qc.turnOffScrolling()
 @brief qc.turnOffScrolling() <br/> The qc.turnOffScrolling function stops the entire html page from scrolling after it is called.
 */
qc.turnOffScrolling = function(){
	document.ontouchmove = function(event){
		event.preventDefault();
	}
}
window.turnOffScrolling = qc.turnOffScrolling;
/*! \fn qc.turnOnScrolling()
 @brief qc.turnOnScrolling() <br/> The qc.turnOnScrolling function activates scrolling of the html page if qc.turnOffScrolling has previously been called.
 */
qc.turnOnScrolling = function(){
	document.ontouchmove = function(event){
		//do nothing
	}
}
window.turnOnScrolling = qc.turnOnScrolling;

//this function will scroll the current view by the x and y amount.  This function is ususally called by the Objective-C portion of an application.
qc.customScroll = function(xAmount, yAmount){
	window.scrollBy(xAmount,yAmount);
	return 'done';
}
window.customScroll = qc.customScroll;
/*! \fn qc.trim(aString)
 @brief qc.trim(aString) <br/> The qc.trim function removes white space characters from the beginning and end of any string it is passed.
 @return the original string without any leading or trailing white space characters
 */
//remove white space from the beginning and end of a string
qc.trim = function(aString){
    return aString.replace(/^\s+|\s+$/g, '');
}
window.trim = qc.trim;

//replace all occurances of a string with another
qc.replaceAll = function(aString, replacedString, newSubString){
    while(aString.indexOf(replacedString) > -1){
        aString = aString.replace(replacedString, newSubString);
    }
    return aString;
} 
window.replaceAll = qc.replaceAll;


//replace all occurances of all special characters recieved from the native side of the application
qc.replaceSpecial = function(anObject){
    if(typeof anObject == 'string'){
        anObject = replaceAll(anObject, "&napos;", "'");
        anObject = replaceAll(anObject, "&nlbracket;", "[");
        anObject = replaceAll(anObject, "&nrbracket;", "]");
        anObject = replaceAll(anObject, "&nlbrace;", "{");
        anObject = replaceAll(anObject, "&nrbrace;", "}");
        anObject = replaceAll(anObject, "&nquote;", "\"");
        anObject = unescape(anObject);
    }
    else if(anObject instanceof Array){
        var numRows = anObject.length;
        for(var i = 0; i < numRows; i++){
            if(anObject[i]){
                anObject[i] = qc.replaceSpecial(anObject[i]);
            }
        }
    } 
    //must be some other type of object
    else if(anObject instanceof Object){
        var myKey;
        for (myKey in anObject){
            if(anObject[myKey]){
                if(anObject[myKey] instanceof Function){
                    continue;
                }
                anObject[myKey] = qc.replaceSpecial(anObject[myKey]);
            }
        }
    }
    return anObject;
}
window.replaceSpecial = qc.replaceSpecial;


/*! \fn qc.generateUUID()
 @brief qc.generateUUID() <br/> The qc.generateUUID function creates a universally unique identifier.
 @return a string that is universally unique.
 */

qc.genrateUUID = function(){
	var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                                                              var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
                                                              return v.toString(16);
                                                              });
	return uuid;
}

//stop an event from doing its' default behavior

/*! \fn qc.stopDefault(anEvent)
 @brief qc.stopDefault(anEvent) <br/> The qc.stopDefault function stops any event from completing its standard behavior.
 If the event is the result of clicking a link calling qc.stopDefault will make the event NOT load the new page.
 */
qc.stopDefault = function(event){
    if(event){
        event.preventDefault();
    }
}
window.stopDefault = qc.stopDefault;

/*
 * These mapping functions require functions for the business rules,
 * view controls, error controls, and security controls NOT the names 
 * of these items as strings.
 */

/*! \fn qc.mapCommandToBCF(aCommand, aBCF)
 @brief qc.mapCommandToBCF(aCommand, aBCF) <br/> The qc.mapCommandToBCF function is used in the mappings.js file to map a Business Control Function (BCF) to the specified command.
 @param aCommand The <b>String</b> that uniquely identifies the stack of Control Functions to which this BCF is to be added.
 @param aBCF a function that has the behavior of a BCF as described on the main page of this documentation.
 */
qc.mapCommandToBCF = function(aCmd, aBCF){
    var funcArray = businessMap[aCmd];
	if(funcArray == null){
		funcArray = new Array();
		businessMap[aCmd] = funcArray;
	}
	funcArray.push(aBCF);
}
window.mapCommandToBCF = qc.mapCommandToBCF;

/*! \fn qc.mapCommandToVCF(aCommand, aVCF)
 @brief qc.mapCommandToVCF(aCommand, aVCF) <br/> The qc.mapCommandToVCF function is used in the mappings.js file to map a View Control Function (VCF) to the specified command.
 @param aCommand The <b>String</b> that uniquely identifies the stack of Control Functions to which this VCF is to be added.
 @param aVCF a function that has the behavior of a VCF as described on the main page of this documentation.
 */
qc.mapCommandToVCF = function(aCmd, aVCF){
    var funcArray = viewMap[aCmd];
	if(funcArray == null){
		funcArray = new Array();
		viewMap[aCmd] = funcArray;
	}
	funcArray.push(aVCF);
}
window.mapCommandToVCF = qc.mapCommandToVCF;

/*! \fn qc.mapCommandToECF(anErrorCommand, anECF)
 @brief qc.mapCommandToECF(anErrorCommand, anECF) <br/> The qc.mapCommandToECF function is used in the mappings.js file to map an Error Control Function (ECF) to the specified command.
 @param aCommand The <b>String</b> that uniquely identifies the stack of Error Control Functions to which this ECF is to be added.
 @param anECF a function that has the behavior of an ECF as described on the main page of this documentation.
 */
qc.mapCommandToECF = function(anErrorCmd, anECF){
	var funcArray = errorMap[anErrorCmd];
	if(funcArray == null){
		funcArray = new Array();
		errorMap[anErrorCmd] = funcArray;
	}
	funcArray.push(anECF);
}
window.mapCommandToECF = qc.mapCommandToECF;

/*! \fn qc.mapCommandToValCF(aCommand, aValCF)
 @brief qc.mapCommandToValCF(aCommand, aBCF) <br/> The qc.mapCommandToValCF function is used in the mappings.js file to map a Validation Control Function (ValCF) to the specified command.
 @param aCommand The <b>String</b> that uniquely identifies the stack of Control Functions to which this ValCF is to be added.
 @param aValCF a function that has the behavior of a ValCF as described on the main page of this documentation.
 */
qc.mapCommandToValCF = function(aCmd, aValCF){
	var funcArray = validationMap[aCmd];
	if(funcArray == null){
		funcArray = new Array();
		validationMap[aCmd] = funcArray;
	}
	funcArray.push(aValCF);
}
window.mapCommandToValCF = qc.mapCommandToValCF;

qc.copyPaste = function(enable){
    var bodyElement = document.getElementsByTagName('body')[0];
    if(enable){
        body.style.webkitUserSelect = 'auto';
    }
    else{
        body.style.webkitUserSelect = 'none';
    }
}
window.copyPaste = qc.copyPaste;


/*
 *  This function supports the passing of the paramters currently being used out of the current thread
 *  of execution and into another.  This can be because of a call to any of the asynchronous data access
 *  methods.  These can be AJAX calls, browser SQLite calls, or device based SQLite calls.
 */
qc.generatePassThroughParameters = function(){
    //debug("Fetching execution key: " + executionKey);
	debug("You have called an asynchronous function ouside of a Buisness Control Function. This"
          +" is likey to have unintended consequences. Specificaly, the asynchronous function"
          +" cannot properly return data.");
	return [executionKey];
}
window.generatePassThroughParameters = qc.generatePassThroughParameters;


/*! \fn qc.logError(error)
 @brief qc.logError(error) <br/> The qc.logError function is used to display an error caught by a try - catch JavaScript phrase.  This function prints out a full stack trace, the reason for the error, the name of the file in which the error occured, and the line number on which the error occured to the console.
 @param error the error caught by using try - catch in the code
 *
 qc.logError = function(error){
 
 console.log([qc.errorMessage(error)]);
 
 }
 window.logError = qc.logError;
 */
/*
 * errorMessage creates a single string message
 * from all of the data available from an error
 * created by a try/catch statement.  If it is 
 * passed something other than an error it 
 * treats it like a string.
 */
qc.errorMessage = function(err){
    var errMsg = 'ERROR: ';
    if(err.name && err.message && err.line && err.sourceURL){
        var fileName = err.sourceURL;
        var stringArr = fileName.split('/');
        fileName = stringArr[stringArr.length -1];
        errMsg += err.name+': '+err.message+' '+fileName+' line: '+err.line;
    }
    else{
        errMsg += err;
    }
    errMsg += '_@_call stack:_@_';
    var curr  = arguments.callee.caller,
    FUNC  = 'function', ANON = "{anonymous}",
    fnRE  = /function\s*([\w\-$]+)?\s*\(/i, stack = [],j=0, fn,args,i;
                                        
                                        while (curr) {
                                        fn    = fnRE.test(curr.toString()) ? RegExp.$1 || ANON : ANON;
                                        args  = stack.slice.call(curr.arguments);
                                        i     = args.length;
                                        
                                        while (i--) {
                                        switch (typeof args[i]) {
                                        case 'string'  : args[i] = '"'+args[i].replace(/"/g,'\\"')+'"';
                                                                                       break;
                                                                                       case 'function': args[i] = FUNC; 
                                                                                       break;
                                                                                       }
                                                                                       }
                                                                                       if(fn != 'logError'){
                                                                                       errMsg += fn + '(' + args.join() + ')_@_';
                                                                                       }
                                                                                       curr = curr.caller;
                                                                                       }
                                                                                       return errMsg;
                                                                                       }
                                                                                       window.errorMessage = qc.errorMessage;
