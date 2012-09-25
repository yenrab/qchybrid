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

#import "CreateFooterVCO.h"
#import "QuickConnectViewController.h"


@implementation CreateFooterVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
	//NSLog(@"in create footer");
    QuickConnectViewController *controller = parameters[0];
    NSString *toolbarId = parameters[1];
	//NSString *toolbarId = @"mainFooter";
    NSString *barColor = parameters[2];
    BOOL translucent = [parameters[3] boolValue];
	//NSLog(@"Tool bar id: %@",toolbarId);
	
	
	//create the buttonBar
	UIToolbar *toolbar = [[UIToolbar alloc] init];
    
	if([barColor compare:@"black"] == NSOrderedSame){
		//toolbar.barStyle = UIBarStyleBlack;//3.0 functionality
        toolbar.barStyle = UIBarStyleBlackOpaque;//2.2.1
	}
	if(translucent){
		//toolbar.translucent = YES;//3.0 functionality
        toolbar.barStyle = UIBarStyleBlackTranslucent;//2.2.1
	}
	
	// size up the toolbar and set its frame
	[toolbar sizeToFit];
	
	int toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = controller.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds),
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	//NSLog(@"footers %@", [controller nativeFooters]);
	NSMutableDictionary *theFooters = [controller nativeFooters];
	
	theFooters[toolbarId] = toolbar;
	//NSLog(@"footers %@", [controller nativeFooters]);
	
	[controller.view addSubview:toolbar];
	//[toolbar release];
	return QC_STACK_EXIT;
}
@end
