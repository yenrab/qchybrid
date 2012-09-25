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
    NSMutableArray *parameters = theDictionary[@"parameters"];
    //NSLog(@"downloading with parameters: %@",parameters);
	NSArray *URLStrings = parameters[1];
    NSArray *fileNames = parameters[2];
	NSString *URLParameters = parameters[3];
	
	BatchQCHTTPHandler *batchHandler = [[BatchQCHTTPHandler alloc] init];
	
	batchHandler.passThroughParameters = parameters;
	[batchHandler doBatch:fileNames URLs:URLStrings URLParameters:URLParameters];
	//NSLog(@"passThroughParams: %@",batchHandler.passThroughParameters);
	//[getHandler startGet:fileName fromURL:URLString URLParameters:URLParameters];
	return QC_STACK_CONTINUE;
}
@end
