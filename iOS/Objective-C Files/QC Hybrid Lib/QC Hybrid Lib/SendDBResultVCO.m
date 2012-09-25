/*
 Copyright (c) 2008, 2009, 2012 Lee Barney
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

#import "SendDBResultVCO.h"
#import "DataAccessResult.h"
#import "SBJSON.h"
#import "QuickConnectViewController.h"
#import "InterlayerMessageSystem.h"
#import "DeviceWebView.h"


@implementation SendDBResultVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
     NSMutableArray *dbResults = dictionary[@"dbInteractionResults"];

	
	NSLog(@"in SendDBResultsVCO params %@",parameters);
	NSArray *results = nil;
	NSMutableArray *dataToSend = [[NSMutableArray alloc] init];
    //NSLog(@"BCO results: %@",bcoResults);
	int numResults = [dbResults count];
    /*
	if(numParams >= 6){
		//NSLog(@"daresult: %@",[parameters objectAtIndex:firstQueryResultCount]);
		NSRange aRange = NSMakeRange(firstQueryResultCount, numParams - firstQueryResultCount);
		//NSLog(@"range: %i, %i", aRange.location, aRange.length);
		//collect the results out of the paramters array from position 5 to the end
		results = [bcoResults subarrayWithRange:aRange];
	}
	else{
		results = [NSArray array];
		[retVal addObject:@"no query results"];
	}
     */
    if (numResults == 0) {
        
		results = @[];
        DataAccessResult *emptyResult = [[DataAccessResult alloc] init];
        emptyResult.errorDescription = @"not an error";
        [dataToSend addObject:emptyResult];
       
		//[retVal addObject:@"no query results"];
    }
    else{
        NSMutableArray *convertedResults = [NSMutableArray arrayWithCapacity:numResults];
        for(int i = 0; i < numResults; i++){
            DataAccessResult * aResult = (DataAccessResult*)dbResults[i];
            [convertedResults addObject:[aResult asJSONObject]];
        }
        results = convertedResults;
    }
    NSLog(@"results: %@",results);
    /*
	//int numResults = [results count];
	for(int i = 0; i < numResults; i++){
		DataAccessResult * aResult = (DataAccessResult*)[bcoResults objectAtIndex:i];
        //NSString* resultString = [aResult JSONStringify];
		//NSLog(@"result: %@",resultString);
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aResult options:0 error:&error];
        if (error) {
            NSLog(@"JSON error: %@",error);
        }
        NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dataToSend addObject:resultString];
        //[aResult release]; Don't do this.
        //NSLog(@"Result string: %@", resultString);
		//NSLog(@"result added");
	}
     */
    [dataToSend addObject:results];
    //add the execution key in to send them back to the JavaScript
    [dataToSend addObject:parameters[4][0]];
    
    NSLog(@"data to send: %@",dataToSend);
    
    QuickConnectViewController *theController = parameters[0];
    [theController.messagingSystem sendCompletionRequest:dataToSend];
    /*
	//NSLog(@"returning results from SENDDBRESULTVCO: %@",retVal);
	SBJSON *generator = [SBJSON alloc];
	
	NSError *error;
	NSString *dataString = [generator stringWithObject:retVal error:&error];
    //NSLog(@"about to send JSON: %@", dataString);
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
    QuickConnectViewController *controller = [parameters objectAtIndex:0];
	[controller.webView stringByEvaluatingJavaScriptFromString:jsString];

	//[dataString release]; Don't do this.
     */
	return QC_STACK_EXIT;
}

@end
