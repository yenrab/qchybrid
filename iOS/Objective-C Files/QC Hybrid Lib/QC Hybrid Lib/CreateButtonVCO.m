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

#import "CreateButtonVCO.h"
#import "QuickConnectViewController.h"
#import "QCBarButtonItem.h"
#import "DeviceWebView.h"


@implementation CreateButtonVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
    QuickConnectViewController *controller = parameters[0];
	NSString *uniqueId = parameters[1];
	NSString *descriptor = parameters[2];
	NSString *javaScriptCallBack = [NSString stringWithString:parameters[3]];
	BOOL isImageButton = [parameters[4] boolValue];
	//NSLog(@"params: %@",parameters);
	
	QCBarButtonItem *aButton = nil;
	if(isImageButton != 0){
		if([descriptor hasPrefix:@"../"]){
			NSArray *split = [descriptor componentsSeparatedByString:@"../"];
			descriptor = split[1];
			//NSLog(@"descriptor: %@",descriptor);
		}
		NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],descriptor];
		//NSLog(@"image file path: %@",imageFilePath);
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageFilePath];
		
		aButton = [[QCBarButtonItem alloc] initWithImage:image 
													style:UIBarButtonItemStyleBordered
												    target:nil
												    action:nil];
	}
	else{
		aButton = [[QCBarButtonItem alloc] initWithTitle:descriptor
													style:UIBarButtonItemStyleBordered
													target:nil
													action:nil];
	}
   
	[aButton setTarget:aButton];
	[aButton setAction:@selector(qcExecuteJavaScriptCallback)];
	[aButton setWebView:[controller webView]];
	[aButton setTheJavaScriptCallBack:javaScriptCallBack];
	[[controller nativeButtons] setValue:aButton forKey: uniqueId];
	//[controller.nativeButtons setValue:aButton forKey:uniqueId];
    
	return QC_STACK_EXIT;
}
@end
