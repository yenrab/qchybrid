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
 
 Created by Daniel Barney
 
 */

#import <SystemConfiguration/SystemConfiguration.h>

#import "VerifyDeviceIsConnectedToInternetVCO.h"
#import "QuickConnectViewController.h"
#import "Reachability.h"
#import "SBJSON.h"
#import "DeviceWebView.h"


@implementation VerifyDeviceIsConnectedToInternetVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    QuickConnectViewController *controller = [parameters objectAtIndex:0];
	NSString *reachability  = @"";
	BOOL isConnectable = NO;
	[[Reachability sharedReachability] setHostName:@"www.google.com"];
	NetworkStatus status =[[Reachability sharedReachability] remoteHostStatus];
	if (status == NotReachable) {
        reachability = @"Cannot Connect To Remote Host.";
    } else if (status == ReachableViaCarrierDataNetwork) {
        reachability = @"Reachable Via Carrier Data Network.";
		isConnectable = YES;
    } else if (status == ReachableViaWiFiNetwork) {
        reachability = @"Reachable Via WiFi Network.";
		isConnectable = YES;
    }
	
	//NSLog(@"the host is %@",reachability);
	NSString *stringToUse =[NSString stringWithFormat:@"handleRequest('reachability',['%@','%d']);",reachability,isConnectable]; 
	//NSLog(@"the message sent is: %@",stringToUse);
	[controller.webView stringByEvaluatingJavaScriptFromString:stringToUse];
	//NSLog(@"the result is: %@",stringToUse);
    
    
    //NSLog(@"in vco %@", parameters);
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    [retVal addObject:reachability];
    NSString *executionKey = [[[dictionary objectForKey:@"parameters"] lastObject] objectAtIndex:0];
    [retVal addObject:executionKey];
    //NSLog(@"returning results from SENDDBRESULTVCO: %@",retVal);
	SBJSON *generator = [SBJSON alloc];
	
	NSError *error;
	NSString *dataString = [generator stringWithObject:retVal error:&error];
    //NSLog(@"about to send JSON: %@", dataString);
    
    NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
	[controller.webView stringByEvaluatingJavaScriptFromString:jsString];

    
	
	return QC_STACK_EXIT;
}
@end
