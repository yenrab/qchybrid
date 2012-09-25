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

#import "PickResultsVCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"


@implementation PickResultsVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    QuickConnectViewController *aController = (QuickConnectViewController*)[parameters objectAtIndex:0];
    NSObject *aPicker = [[aController webView] picker];
    [aController webView].picker = nil;
    
    if([aPicker isKindOfClass:[UIDatePicker class]]){
        NSDate *aDate = ((UIDatePicker*)aPicker).date;
    
        NSString *aDateString = [aDate description];
		//NSLog(@"%@",aDateString);
        NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:1];
        [passingArray addObject:aDateString];
        SBJSON *generator = [SBJSON alloc];
        
        NSError *error;
        NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];
        
        NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('showPickResults', '%@')", paramsToPass];
        //NSLog(@"%@",jsString);
        [[aController webView] stringByEvaluatingJavaScriptFromString:jsString];

    }
    [((UIDatePicker*)aPicker) removeFromSuperview];
    return QC_STACK_EXIT;
    }
@end
