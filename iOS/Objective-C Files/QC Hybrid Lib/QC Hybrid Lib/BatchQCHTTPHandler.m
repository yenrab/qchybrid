//
//  BatchHTTPHandler.m
//  QCLib
//
//  Created by lee on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BatchQCHTTPHandler.h"
#import "QCHTTPHandler.h"
#import "JSON.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"


@implementation BatchQCHTTPHandler

@synthesize saveFilePaths;
@synthesize passThroughParameters;
@synthesize numRequests;


- (void) doBatch:(NSArray*)saveFileNames URLs:(NSArray*)urls URLParameters:(NSString*)urlParamters{
	if ([saveFileNames count] != [urls count]) {
		NSLog(@"ERROR: The number of save file names (%i) does not match the number of URLs (%i)",[saveFileNames count], [urls count]);
		return;
	}
	self.numRequests = [saveFileNames count];
	self.saveFilePaths = [NSMutableArray arrayWithCapacity:0];

	for (int i = 0; i < [saveFileNames count]; i++) {
		QCHTTPHandler *getHandler = [[QCHTTPHandler alloc] init];
		getHandler.batchHandler = self;
		//NSLog(@"downloading: %@ %@",[saveFileNames objectAtIndex:i], [urls objectAtIndex:i]);
		[getHandler startGet:[saveFileNames objectAtIndex:i] fromURL:[urls objectAtIndex:i] URLParameters:urlParamters shouldOverwrite:NO];
	}
}
- (void) notifyRequestComplete:(NSString*)filePathString{
	//NSLog(@"%@ %@",self.saveFilePaths, filePathString);
	[self performSelectorOnMainThread:@selector(sendResultsToWebView:)
						   withObject:filePathString
						waitUntilDone:YES];
	
}
	
- (void) sendResultsToWebView:(NSString*)filePathString{
	//@synchronized(self){
	[self.saveFilePaths addObject:filePathString];
	if ([self.saveFilePaths count] == numRequests) {
		
		NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:2];
		[retVal addObject:self.saveFilePaths];
		[retVal addObject:[self.passThroughParameters objectAtIndex:8]];
		//NSLog(@"%@",retVal);
		
		NSError *genError;
		SBJSON *generator = [SBJSON alloc];
		NSString *dataString = [generator stringWithObject:retVal error:&genError];
		//self.saveFilePaths;
		dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
		dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
		NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
		QuickConnectViewController *controller = [passThroughParameters objectAtIndex:0];
		[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
	}
	//}
}



@end
