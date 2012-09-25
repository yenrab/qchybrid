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

#import "LocationVCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"


@implementation LocationVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	QuickConnectViewController *controller = (QuickConnectViewController*)[parameters objectAtIndex:0];
	UIWebView *webView = [controller webView];
	CLLocation *location = (CLLocation*)[parameters objectAtIndex:1];
	
	//NSString * test = [NSString stringWithFormat:@"lat: %f lon: %f alt: %f",location.coordinate.latitude, location.coordinate.longitude, location.altitude];
	//NSLog(@"%@",test);
	
	NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:3];
	[passingArray addObject: [NSNumber numberWithDouble: location.coordinate.latitude]];
	[passingArray addObject: [NSNumber numberWithDouble: location.coordinate.longitude]];
	[passingArray addObject: [NSNumber numberWithFloat: location.altitude]];
    [passingArray addObject:[NSNumber numberWithFloat:location.horizontalAccuracy]];
	
	SBJSON *generator = [SBJSON alloc];
	
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];

	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('showLoc', '%@')", paramsToPass];
	//NSLog(@"%@",jsString);
	[webView stringByEvaluatingJavaScriptFromString:jsString];

	return QC_STACK_EXIT;
}

@end
