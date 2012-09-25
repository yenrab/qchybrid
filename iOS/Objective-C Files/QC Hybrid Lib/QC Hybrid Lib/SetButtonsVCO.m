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

#import "SetButtonsVCO.h"
#import "QuickConnectViewController.h"


@implementation SetButtonsVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    QuickConnectViewController *controller = [parameters objectAtIndex:0];
	UIToolbar *footerForDisplay = [[controller nativeFooters] objectForKey:[parameters objectAtIndex:1]];
	//NSLog(@"params: %@",parameters);
	int numParams = [parameters count];
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:numParams - 2];
	UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:flexibleSpaceLeft];
	for(int i = 2; i < numParams; i++){
		//NSLog(@"parameter: %d has value: %@",i,[parameters objectAtIndex:i]);
		NSObject *aButton = [[controller nativeButtons] objectForKey:[parameters objectAtIndex:i]];
		if(aButton != nil){
			[buttons addObject:aButton];
		}
	}
	UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:flexibleSpaceRight];
	//NSLog(@"buttons to display: %@",buttons);
	[footerForDisplay setItems:buttons animated:YES];
    return QC_STACK_EXIT;
}
@end
