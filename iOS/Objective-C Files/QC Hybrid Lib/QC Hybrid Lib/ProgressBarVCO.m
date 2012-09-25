/*
 Copyright (c) 2008, 2009, 2010 Lee Barney
 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation the 
 rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the Software 
 is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be 
 included in all copies or substantial portions of the Software.
 
 The end-user documentation included with the redistribution, if any, must 
 include the following acknowledgment: 
 "This product was created using the QuickConnect framework.  http://www.quickconnectfamily.org", 
 in the same place and form as other third-party acknowledgments.   Alternately, this acknowledgment 
 may appear in the software itself, in the same form and location as other 
 such third-party acknowledgments.
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Created by Michael Adkins
 */

#import "ProgressBarVCO.h"
#import "QuickConnectViewController.h"

@implementation ProgressBarVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
	QuickConnectViewController *controller = parameters[0];
	NSString *cmd = parameters[1];
	
	if ([cmd isEqualToString:@"CreateProgressBar"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique ProgressBar ID - Integer.
		// 3 - X
		// 4 - Y
		// 5 - Width
		// 6 - Height
		// 7 - Default Value - float value 1.0 is max value.  .01 is 1% - .10 is 10%
		
		UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake([parameters[3] floatValue],
																					[parameters[4] floatValue],
																					[parameters[5] floatValue],
																					[parameters[6] floatValue])];
		[progress setTag:[parameters[2] intValue]];
		
		[controller.view addSubview:progress];
		[progress setProgress:[parameters[7] floatValue]];
		
	}
	else if ([cmd isEqualToString:@"setHidden"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique Switch ID - Integer.
		// 3 - Bool YES | NO
		
        UIProgressView *progress = (UIProgressView*)[controller.view viewWithTag:[parameters[2] intValue]];
 		[progress setHidden:[parameters[3] boolValue]];
	}
	else if ([cmd isEqualToString:@"setValue"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique Switch ID - Integer.
		// 3 - Value - float value 1.0 is max value.  .01 is 1% - .10 is 10%
		
        UIProgressView *progress = (UIProgressView*)[controller.view viewWithTag:[parameters[2] intValue]];
		[progress setProgress:[parameters[3] floatValue]];	
	}
	
	return QC_STACK_EXIT;
}
@end
