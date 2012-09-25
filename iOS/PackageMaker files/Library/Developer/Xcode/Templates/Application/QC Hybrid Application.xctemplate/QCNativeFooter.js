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


//maps holding all the buttons and footers created.  The key is the uniqueId.
var allNativeButtons = new Object();
var allNativeFooters = new Object();



function QCNativeFooter(uniqueId, color, translucentFlag){
	allNativeFooters[uniqueId] = this;
	makeCall("createFooter", JSON.stringify([uniqueId, color, translucentFlag]));
	
	this.show = function(){
		makeCall("showFooter", JSON.stringify([uniqueId]));
	}
	this.hide = function(){
		makeCall("hideFooter", JSON.stringify([uniqueId]));
	}
	this.setButtons = function(buttons){
		//debug('setting buttons');
		if(buttons){
			var params = new Array();
			params.push(uniqueId);
			var numButtons = buttons.length;
			for(var i = 0; i < numButtons; i++){
				params.push(buttons[i].uniqueId);
			}
			makeCall("setButtons", JSON.stringify(params));
		}
		else{
			//debug("Setting buttons for footer "+uniqueId+" but no buttons were passed.");
		}
	}
}

function QCNativeButton(uniqueId, descriptor, callBackFunction, isImageButton){
	this.uniqueId = uniqueId;
	allNativeButtons[uniqueId] = this;
	makeCall("buildButton", JSON.stringify([uniqueId, descriptor, callBackFunction, isImageButton]));
}