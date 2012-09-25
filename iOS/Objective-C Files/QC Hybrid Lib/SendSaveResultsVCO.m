//
//  SendSaveResultsVCO.m
//  QC Hybrid Lib
//
//  Created by Lee Barney on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendSaveResultsVCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"


@implementation SendSaveResultsVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    //NSLog(@"sending save results %@", [dictionary objectForKey:@"parameters"]);
    //add the execution the list and the key in to send them back to the JavaScript
    /*
     NSArray *list = [[dictionary objectForKey:@"BCOresults"] objectAtIndex:0];
    NSString *executionKey = [[[dictionary objectForKey:@"parameters"] lastObject] objectAtIndex:0];
    
    NSArray *retVal = [NSArray arrayWithObjects:
                       list, 
                       executionKey, nil];
    
    NSError *genError;
    SBJSON *generator = [SBJSON alloc];
    NSString *dataString = [generator stringWithObject:retVal error:&genError];
    
    //dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    //dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    //NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
    //NSLog(@"js: %@",jsString);
    //QuickConnectViewController *controller = [[dictionary objectForKey:@"parameters"] objectAtIndex:0];
    //[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
    */
    return QC_STACK_EXIT;
}
@end
