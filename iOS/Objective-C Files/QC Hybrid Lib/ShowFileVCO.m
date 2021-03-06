//
//  ShowFileVCO.m
//  QC Hybrid Lib
//
//  Created by Lee Barney on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowFileVCO.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"
#import "FileDisplayDataSource.h"
#import "SBJSON.h"


@implementation ShowFileVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{

    NSArray *parameters = dictionary[@"parameters"];
     QuickConnectViewController *controller = dictionary[@"parameters"][0];
	NSString *fileName = parameters[1];
    QLPreviewController *aPreviewer = [[QLPreviewController alloc] init];
    //NSLog(@"fileName: %@",fileName);
    FileDisplayDataSource *aDataSource = [[FileDisplayDataSource alloc] initWithFile:fileName];
	// Set data source
    //NSLog(@"dataSource: %@",controller.previewer.dataSource);
    [aPreviewer setDataSource:aDataSource];
   
    //NSLog(@"index set");
    
    
    [controller.webView addSubview:aPreviewer.view];
    
    [controller presentModalViewController:aPreviewer animated:YES];
    
    NSString *executionKey = [dictionary[@"parameters"] lastObject][0];
    //NSLog(@"executionKey %@",executionKey);
    if(!executionKey){
        return QC_STACK_EXIT;
    }
    
    NSArray *retVal = @[@"file displayed", 
                       executionKey];
    
    NSError *genError;
    SBJSON *generator = [SBJSON alloc];
    NSString *dataString = [generator stringWithObject:retVal error:&genError];
 
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
   
    [controller.webView stringByEvaluatingJavaScriptFromString:jsString];
   
    return QC_STACK_EXIT;
}
@end
