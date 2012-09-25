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
 
 
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Created by Michael Adkins
 */

#import "SwitchBCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"

@implementation SwitchBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	QuickConnectViewController *controller = [parameters objectAtIndex:0];
	NSString *cmd = [parameters objectAtIndex:1];
	
	if ([cmd isEqualToString:@"CreateSwitch"]){
		 // 0 - QCVC
		 // 1 - cmd
		 // 2 - Unique Switch ID - Integer.
		 // 3 - X
		 // 4 - Y
		 // 5 - Width
		 // 6 - Height
		 // 7 - Default Value YES | NO
		 
		 UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake([[parameters objectAtIndex:3] floatValue],
																		[[parameters objectAtIndex:4] floatValue],
																		[[parameters objectAtIndex:5] floatValue],
																		[[parameters objectAtIndex:6] floatValue])];
		 [switch1 setTag:[[parameters objectAtIndex:2] intValue]];
		 [switch1 setOn:[[parameters objectAtIndex:7] boolValue] animated:NO];
		 [switch1 addTarget:controller action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		 [controller.view addSubview:switch1];
	}
	else if ([cmd isEqualToString:@"setHidden"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique Switch ID - Integer.
		// 3 - Bool YES | NO
		
        UISwitch *switch1 = (UISwitch*)[controller.view viewWithTag:[[parameters objectAtIndex:2] intValue]];
 		[switch1 setHidden:[[parameters objectAtIndex:3] boolValue]];
	}
	else if ([cmd isEqualToString:@"setValue"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique Switch ID - Integer.
		// 3 - Value YES | NO
		// 4 - Animated Yes | NO
		
        UISwitch *switch1 = (UISwitch*)[controller.view viewWithTag:[[parameters objectAtIndex:2] intValue]];
		[switch1 setOn:[[parameters objectAtIndex:3] boolValue] animated:[[parameters objectAtIndex:4] boolValue]];
	}
	else if ([cmd isEqualToString:@"getValue"]){
		// 0 - QCVC
		// 1 - cmd
		// 2 - Unique Switch ID - Integer.
		
        UISwitch *switch1 = (UISwitch*)[controller.view viewWithTag:[[parameters objectAtIndex:2] intValue]];
		
		NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:2];
		[passingArray addObject:[NSNumber numberWithInt: [[parameters objectAtIndex:2] intValue]]];
		
		if (switch1.on == YES){
			[passingArray addObject:@"YES"];
		}
		else {
			[passingArray addObject:@"NO"];
		}
		
		SBJSON *generator = [SBJSON alloc];
		NSError *error;
		NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];

		NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('switchVal', '%@')", paramsToPass];
		[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
	}
	
	return QC_STACK_EXIT;
}
@end
