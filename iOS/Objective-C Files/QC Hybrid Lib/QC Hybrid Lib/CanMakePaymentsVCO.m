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

#import "CanMakePaymentsVCO.h"
#import "SBJSON.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"

#import <StoreKit/StoreKit.h>


@implementation CanMakePaymentsVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary {
    
    NSArray* parameters = dictionary[@"parameters"];
    //NSLog(@"params %@",parameters);
	
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	NSString *makePaymentsString = @"false";
	if ([SKPaymentQueue canMakePayments]){
		makePaymentsString = @"true";
	}
	[retVal addObject:makePaymentsString];
	
	//NSLog(@"makePaymentsString: :%@",parameters);
    //add the execution key in to send them back to the JavaScript
    [retVal addObject:parameters[1][0]];
	//NSLog(@"returning results from SENDDBRESULTVCO: %@",retVal);
	
	NSError *error;
	SBJSON *generator = [SBJSON alloc];
	NSString *dataString = [generator stringWithObject:retVal error:&error];
	//NSLog(@"error: %@",error);
    //NSLog(@"about to send JSON: %@", dataString);

	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"",jsString);
    QuickConnectViewController *controller = parameters[0];
	[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
   
	return QC_STACK_CONTINUE;
	
}
@end
