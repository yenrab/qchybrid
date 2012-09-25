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


/*! \file QuickConnect.js
 \brief The QC file contains the two stack trigger functions.
 
 qc.handleRequest and qc.handleError are used to trigger stack execution.  For more information regarding stacks see the main page of the documentation.
 
 <em><b>All functions are listed as variables in these files.</b></em>  However, they truely are JavaScript functions.
 
 */

/*! \mainpage QuickConnectFamily Hybrid
 
 <div style="padding-left:30px">
 * \section intro_sec QuickConnectFamily Hybrid Introduction
 *QCFamily Hybrid is a full framework not a library.  Like other full frameworks it has done most of the design and coding work for you.  You need only create the functionallity that you desire for your applications. 
 <br/>QCFamily Hybrid allows you to write your application in HTML, CSS, and JavaScript.  Use the HTML and CSS to create the user interface and JavaScript to implement the logic.  Use the web skills you already have to get your idea to market quickly.  
 <br/><br/>When you want to learn more about native Objective-C iOS or Android Java development take a look at the source code available from sourceForge to find a whole series of 'how to' code sets in the QCFamily Hybrid framework.  The source is open and liberally licensed (BSD license).
 *<hr/><br/><br/>
 * \section downloading_sec Downloading QuickConnectFamily Hybrid
 <div style="padding-left:30px">
 Download QCFamily Hybrid from <a href="https://sourceforge.net/projects/quickconnect/">the sourceForge site</a>.
 The QCFamily Hybrid download includes numerous examples for iOS and Android developers.  Look in the downloaded file for these.  Well over 30 examples are included on how to use specific QCFamily Hybrid functionalities.
 </div>
 *<hr/><br/><br/>
 
 * \section create_iOS_project_sec Creating an QCF Hybrid application for iOS using Xcode
 *Do the following steps <b>OR</b> copy and existing example project.
 * \subsection oc_step1 Step 1: Use Xcode to create a new iOS application from one of the standard templates.
 * \subsection oc_step2 Step 2: Drag the contents of the QC Hybrid directory into the project.  Copy them in.
 * \subsection oc_step3 Step 3: Add in the following standard frameworks:
 @li Accelerate
 @li AddressBook
 @li AddressBookUI
 @li AudioToolbox
 @li AVFoundation
 @li CoreLocation
 @li GameKit
 @li iAd
 @li libsqlite3.dylib
 @li MapKit
 @li MediaPlayer
 @li MessageUI
 @li StoreKit
 @li SystemConfiguration
 * \subsection oc_step4 Step 4: Add the following files to the 'Copy Bundle Resources' list if they aren't already there
 @li index.html
 @li main.css
 @li main.js
 @li mappings.js
 @li functions.js
 @li databaseDefinition.js
 * \subsection oc_step5 Step 5: In your application delegate header file (.h file) Change NSObject to QuickConnectViewController in the inheritance declaration
 * \subsection oc_step6 Step 6: Add this line of code to the application:didFinishLaunchingWithOptions method of your application delegate
 @li [self addWebViewToWindow:self.window];
 * \subsection oc_step7 Step 7: Modify the index.html, main.css, and the JavaScript files to create the logic for your app
 
 
 *<hr/><br/><br/>
 *
 * \section create_iOS_xcode_project_sec Creating an QCF Hybrid application for iOS and Android using Xcode
 *
 * \subsection oc_andr_step1 Step 1: Under development now
 *<hr/><br/><br/>
 
 *
 * \section create_android_project_sec Creating an QCF Hybrid application for Android using MotoDev
 Do the following steps <b>OR</b> copy an existing example project.
 *
 * \subsection andr_step1 Step 1: Use MotoDev or eclipse to create a new Android application using the Google APIs
 * \subsection andr_step2 Step 2: Add the contents of the libs directory to your application's Build Path
 * \subsection andr_step3 Step 3: Add maps.jar to the build path of your application for the API level of your application.  It can be found at <Android SDK Installation>/add=ons/addon_google_apis_google_inc_<API level>/libs
 * \subsection andr_step4 Step 4: In the build path editor select the Export tab and select all of the jar files from the libs directory
 * \subsection andr_step5 Step 5: Copy the contents of the Web Files directory into your application's assets directory
 * \subsection andr_step6 Step 6: Replace your application's res -> layout -> main.xml file with the main.xml file in the QC Hybrid XML directory
 * \subsection andr_step7 Step 7: Drag balloon_overlay.xml into your application's res -> layout directory
 * \subsection andr_step8 Step 8: Replace the contents of your application's AndroidManifest.xml file with the contents of the AndroidManifest.xml file in the XML Files directory
 * \subsection andr_step9 Step 9: Drag the raw directory into the res directory of your application
 * \subsection andr_step10 Step 10: Drag the drawable directory into your application's res directory
 * \subsection andr_step11 Step 11: Change the Activity of your Application to extends QCAndroid
 * \subsection andr_step12 Step 12: Import the R class in your application's Activity Class.
 * \subsection andr_step13 Step 13: Replace splash.png in the drawable directory with a background image of your choice.
 * \subsection andr_step14 Step 14: Clean the project
 * \subsection andr_step15 Step 15: Modify the index.html, main.css, and the JavaScript files to create the logic for your app
 
 
 
 
 *<hr/><br/><br/>
 
 
 
 * \section using_framework Using the Framework: First ideas
 
 If you want to take advantage of QCFamily Hybrid's built-in library of functionality there are two major components of QC applications that you need to understand to take full advantage of the framework, stacks and control functions.
 
 
 
 *
 * \section stacks Stacks: Laying out the application flow
 
 *Stacks consist of a series of control functions (discussed below) that map out a set of specific, sequential actions that you want your application to execute.  Each stack is created by mapping the individual control functions for the stack to a unique command string you can use later to refer to the stack as a whole.
 * \subsection stack_example Example: A stack design
 Imagine that you need to require your user to login using a user name and password.  You might choose 'login' for the unique command string to represent the sequence of steps.  Generally with a login attempt you would want to validate the user name and password, attempt to login using this information, store something regarding the user (often this is a unique identifier of some sort), and then display some new set of behaviors available for that user.  In the case of a failed login attempt your applications would usually indicate to the user that login failed.
 <p>
 The image below is a graphical description of this desired behavior.  The string 'login' has been selected as the command.  The success stack is seen on the left and the error handling is shown on the right.
 
 \image html /Users/lee/QC_Git_Repos/quickconnect/StackDesignExample.png
 </p>
 Choosing a descriptive command for the behavior scenario, deciding the discrete steps for this scenario, and deciding when and how to handle errors for the scenario are how QC Family applications are designed.
 * \section control_functions Control Functions: Discrete stack actions
 
 *Each of the discrete desired behaviors described in the design of a stack are known as control functions in QC applications. To cover the types of behavior found in all modern applications QC application control functions come in four distinct types each with a specific responsibility.
 
 * \subsection valcf_subsec Validation Control Function: ValCF
 
 ValCF's are used to validate information supplied to the application by the user.
 
 * \subsection bcf_subsec Business Control Function: BCF
 
 BCF's obtain, send, or manipulate data.  They may obtain data from a local database, a remote web application or service, send data to such and application or service, or perform a calculation on data it is passed.
 
 * \subsection vcf_subsec View Control Function: VCF
 
 VCF's update the display.  Usually after data is sent, received, or calculated the user needs to be notified.  View Control Functions update the screen for the user.  This may be as simple as turning on a hidden string or as complicated as animating the display of an entirely new view for the user.
 
 * \subsection ecf_subsec Error Control Function: ECF
 
 ECF's handle cleaning up when an error has happened.  This usually includes resetting variables, resetting view components, and displaying error messages.
 
 <p>
 The image below reworks the design created earlier replacing the desired steps with names for the control function for each step.
 
 \image html /Users/lee/QC_Git_Repos/quickconnect/StackDesignControlFunctionsExample.png
 </p>
 
 
 <p>
 As you can see from the image above each control function is intended to be a module.  This means that it does one thing, does it well, and is complete.  Being modular one control function should never call another control function directly since then un-needed dependencies would be created between them.  The framework will call all of the control functions for your application. 
 
 *
 * \section mapping Building Stacks: Mapping commands to control functions
 
 *Stacks, as seen above, consist of a series of control functions associated with a unique command.  The QCFamily Hybrid framework provides a series of functions to make this easy.  These are the qc.mapCommandTo***(aCommand, aControlFunction) functions found in the QCUtilities.js file.  Each type of controle function has a matching mapCommandTo***(aCommand, aControlFunction) function.
 @li ValCF -> qc.mapCommandToValCF(aCommand, aValidationControlFunction)
 @li BCF -> qc.mapCommandToBCF(aCommand, aBusinessControlFunction)
 @li VCF -> qc.mapCommandToVCF(aCommand, aViewControlFunction)
 @li ECF -> qc.mapCommandToECF(aCommand, anErrorControlFunction)
 
 Calls to these mappCommandTo***(aCommand, aValidationControlFunction) functions are always made in the mappings.js file to ensure they are executed after the control functions have been loaded.
 
 * \subsection mapping_example Example: The login mappings
 <p>The code in the mappings.js file for the login example designed above is shown here.
 \image html /Users/lee/QC_Git_Repos/quickconnect/mapping.png
 </p>
 <p>
 Mappings of stacks also give you as an application developer one place to go to see the flow of your application.  No more do you need to dig deeper and deeper into the code to find out what it does.  If the stack is designed well this information is obvious in the mapping of the stack.
 </p>
 <p>
 Another nice benefit is discovered when doing debugging.  If there is a defect in a control function it is in the control function not in any of the others in the stack.  Since the control functions are small and modular debugging becomes much easier.
 </p>
 
 
 * \section creating_CFs Creating Control Functions: The behavior code
 *
 * Each control function that is mapped in the mappings.js file is defined in the functions.js file to ensure proper handling of loading dependencies.  The image below shows an example of how the functions mapped in the example might be defined.  Each of these control functions returns one of four values.
 @li qc.STACK_CONTINUE - This instructs the framework to execute the next control function in the stack.
 @li qc.STACK_EXIT - This instructs the framework to terminate all further stack execution.
 @li qc.WAIT_FOR_DATA - This instructs the framework that a call to database or remote data has been made or a call to device specific behavior such as showing a map.
 @li any calculated data - If your BCF calculates data and that data is needed later in the stack return the value from the BCF function.  The returned data will be sent by the framework to the remaining control functions in the stack.
 \image html /Users/lee/QC_Git_Repos/quickconnect/controlFunctions.png
 
 * \section handleRequest Executing a Stack: The trigger for behavior
 *
 * QC includes two functions to allow you to easily execute any stack you have already mapped and defined.  qc.handleRequest(aCommand, requestParameters) is used to execute standard stacks.  qc.handleError(aCommand, errorParameters) is used to execute error stacks as you have seen in the code example above.    They can both be found in the QuickConnect.js file. 
 
 qc.handleRequest can be called directly from the HTML of you application if no parameters are needed but it is often called from within an onclick or other event listener.  The example code below assumes that there is an HTML input of type button with its onclick listener set to 'loginFunc()'.  The listener function accumulates everything the stack needs to do its work and then calls qc.handleRequest.  
 <p>
 The code here shows an example.  It collects the needed values and calls qc.handleRequest.
 \image html /Users/lee/QC_Git_Repos/quickconnect/trigger.png
 </p>
 Assign the loginFunc function as the onclick listener for a button and the example is complete.
 
 *<hr/><br/><br/>
 
 The QuickConnectFamily of tools has been a great deal of fun to create.  QCFamily Hybrid is only one of these.  I hope you will take time to look at some of the others at <a href="http://www.quickconnectfamily.org ">www.quickconnectfamily.org</a>
 
 <h6>&copy; 2011 Lee Barney</h6>
 
 </div>
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
        //paramsArray = paramsArray[0];
	}
    handleRequest(cmd, paramsArray);
	//return cmd +" "+parametersString;
}

/*! \fn qc.handleRequest(aCmd, requestParameters)
 @brief handleRequest(aCmd, requestParameters) <br/> The qc.handleRequest function is the trigger for the execution of mapped stacks.  Each call to handleRequest is runs as much of the stack as possible on a background worker thread.
 @param aCommand The <b>String</b> that uniquely identifies the stack of Control Functions you want executed.
 @param requestParameters An optional <b>Array</b> instance containing any and all values that you want passed to the indicated stack.
 */


qc.handleRequest = function(aCommand, requestParameters){
    try{
		if(!requestParameters){
			requestParameters = new Array();
		}
        requestHandler(aCommand, requestParameters, null);
    }
    catch(err){
        logError(err);
    }
}
window.handleRequest = qc.handleRequest;

/*! \fn qc.handleError(aCommand, errorParameters)
 @brief handleError(aCommand, errorParameters) <br/>The qc.handleError function is the trigger for the execution of mapped error handling stacks.  Each call to handleRequest is runs as much of the stack as possible on a background worker thread.
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Functions you want executed.
 @param errorParameters An optional <b>Array</b> instance containing any and all values that you want passed to the indicated stack.
 */
qc.handleError = function(aCommand, errorParameters){
	dispatchToECF(aCommand, errorParameters);
}
window.handleError = qc.handleError;

function requestHandler(aCmd, paramArray, callBackData){
	/* Save our global requestHandler function and redefine it to
	 * prevent it from being inappropriately called from within a
	 * running command stack.
	 */
	var globalRequestHandler = window.requestHandler;
	window.requestHandler = function(aCmd, paramArray, callBackData){
        debug("An attempt was made to start or continue a command stack from within"
              +" an a running command stack. This cannot work properly and"
              +" has been prevented. If you must trigger this command stack"
              +" from within a running command stack, use\n"
              +" setTimeout('handleRequest('"+aCmd+"', parametersArray);',1);\n\nBetter yet never call one stack from within another.  Engineer around it."
              +"Prevented Command: "+aCmd);
        return false;
	};
	
	if(aCmd != null){
        //do not re-execute the validation if it has already been done.  This is indicated by the existance of callBackData
		if(callBackData != null || (dispatchToValCF(aCmd, paramArray) == qc.STACK_CONTINUE)){
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
	}
	
	// Command stack completed. Restore our global requestHandler.
	window.requestHandler = globalRequestHandler;
}

function handleRequestCompletionFromNative(callBackString) {
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
	var cached_generatePassThroughParameters = window.generatePassThroughParameters;
    
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
            try{
                var thing = null;
                thing.dostuff();
            }
            catch(err){
                alert(qc.errorMessage(err));
            }
            debug("You have attempted to use more than one asynchronous function in the same BCF. This cannot"
                  +" work correctly and will result in the command stack being improperly resumed multiple times"
                  +" with incorrectly ordered results values. Therefore, resumption of this command stack has"
                  +" has been prevented for all but the first asynchronous function. "+aCmd);
			return "MORE_THAN_ONE_ASYNC_CALL_IN_A_BCF";
		};
		return [internalExecutionKey];
	}
    
	
    var executionObject = null;
    if(callBackData && callBackData.length > 0){
        var anExecutionKey = callBackData[1];
        internalExecutionKey = anExecutionKey;
        executionObject = executionMap[anExecutionKey];
        executionObject['accumulatedData'].push(callBackData[0]);
        
    }
    else{
        var curDate = new Date();
        internalExecutionKey = curDate.getTime()+'_'+executionCount;
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
	window.generatePassThroughParameters = cached_generatePassThroughParameters;
	
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
		//debug('num error funcs: '+numFuncs);
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