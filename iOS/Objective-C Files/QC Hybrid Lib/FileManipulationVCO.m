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

#import "FileManipulationVCO.h"
#import "SBJSON.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"
#import "InterlayerMessageSystem.h"


@implementation FileManipulationVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    //add the execution the list and the key in to send them back to the JavaScript
    NSLog(@"Dict: %@",dictionary);
    
    NSArray *manipulationResult = dictionary[@"fileManipulationResult"];
    NSArray *parametersPassed = dictionary[@"parameters"];
    NSString *executionKey = [parametersPassed lastObject][0];
    
    NSArray *dataToSend = @[manipulationResult, 
                                          executionKey];
    QuickConnectViewController *theController = parametersPassed[0];
    [theController.messagingSystem sendCompletionRequest:dataToSend];
    
    //NSArray *deleteResult = [[dictionary objectForKey:@"BCOresults"] objectAtIndex:0];
    //NSString *executionKey = [[[dictionary objectForKey:@"parameters"] lastObject] objectAtIndex:0];
    
    //NSArray *retVal = [NSArray arrayWithObjects:
    //                   deleteResult, 
    //                   executionKey, nil];
    
    //QuickConnectViewController *controller = [[dictionary objectForKey:@"parameters"] objectAtIndex:0];
    //[controller.messagingSystem sendCompletionRequest:retVal];
    /*
    NSError *genError;
    SBJSON *generator = [SBJSON alloc];
    NSString *dataString = [generator stringWithObject:retVal error:&genError];
    
    
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
    QuickConnectViewController *controller = [[dictionary objectForKey:@"parameters"] objectAtIndex:0];
    [controller.webView stringByEvaluatingJavaScriptFromString:jsString];
     */
    return QC_STACK_EXIT;
}
@end
