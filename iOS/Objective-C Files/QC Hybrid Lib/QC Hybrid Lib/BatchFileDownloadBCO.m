//
//  batchDownloadBCF.m
//  QCLib
//
//  Created by lee on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BatchFileDownloadBCO.h"
#import "BatchQCHTTPHandler.h"

@implementation BatchFileDownloadBCO
+ (BOOL) handleIt:(NSMutableDictionary*) theDictionary{
    NSMutableArray *parameters = [theDictionary objectForKey:@"parameters"];
    //NSLog(@"downloading with parameters: %@",parameters);
	NSArray *URLStrings = [parameters objectAtIndex:1];
    NSArray *fileNames = [parameters objectAtIndex:2];
	NSString *URLParameters = [parameters objectAtIndex:3];
	
	BatchQCHTTPHandler *batchHandler = [[BatchQCHTTPHandler alloc] init];
	
	batchHandler.passThroughParameters = parameters;
	[batchHandler doBatch:fileNames URLs:URLStrings URLParameters:URLParameters];
	//NSLog(@"passThroughParams: %@",batchHandler.passThroughParameters);
	//[getHandler startGet:fileName fromURL:URLString URLParameters:URLParameters];
	return QC_STACK_CONTINUE;
}
@end
