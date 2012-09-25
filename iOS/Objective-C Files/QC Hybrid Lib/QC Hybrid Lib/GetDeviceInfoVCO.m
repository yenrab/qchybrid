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

#import "GetDeviceInfoVCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"
#import "QCVersion.h"


@implementation GetDeviceInfoVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	QuickConnectViewController *controller = (QuickConnectViewController*)[parameters objectAtIndex:0];
	UIWebView *webView = [controller webView];
	UIDevice *aDevice = [UIDevice currentDevice];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	
	NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:5];
	[passingArray addObject: [aDevice name]];
	[passingArray addObject: [aDevice localizedModel]];
	[passingArray addObject: [aDevice systemName]];
	[passingArray addObject: [aDevice systemVersion]];
    [passingArray addObject: [defs objectForKey:@"AppleLocale"]];
	
    NSString *timeZoneString = [timeZone localizedName:NSTimeZoneNameStyleShortStandard locale:currentLocale];
    if([timeZone isDaylightSavingTimeForDate:[NSDate date]]){
        timeZoneString = [timeZone localizedName:NSTimeZoneNameStyleShortDaylightSaving locale:currentLocale];
    }
    [passingArray addObject: timeZoneString];
	
	[passingArray addObject:[NSNumber numberWithUnsignedInt:[[NSProcessInfo processInfo] processorCount]]];
    NSString *distributionType = @"Release";
    if(isBeta){
        distributionType = @"Beta";
    }
    //NSString *qcVersion = [NSString stringWithFormat:@"QC %@ %@",distributionType, qcVersion];
    [passingArray addObject:distributionType];
    [passingArray addObject:qcVersion];
    //NSLog(@"%@",[defs objectForKey:@"SBFormattedPhoneNumber"]);
	
	SBJSON *generator = [SBJSON alloc];
	
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];

	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('showDeviceInfo', '%@')", paramsToPass];
	//NSLog(@"%@",jsString);
	[webView stringByEvaluatingJavaScriptFromString:jsString];


	return QC_STACK_EXIT;
	
}
@end
