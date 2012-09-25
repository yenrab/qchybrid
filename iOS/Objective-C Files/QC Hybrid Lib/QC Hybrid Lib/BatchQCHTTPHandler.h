//
//  BatchHTTPHandler.h
//  QCLib
//
//  Created by lee on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BatchQCHTTPHandler : NSObject {
	NSMutableArray *saveFilePaths;
	NSArray *passThroughParameters;
	int numRequests;
}


@property (nonatomic, strong) NSMutableArray *saveFilePaths;
@property (nonatomic, strong) NSArray *passThroughParameters;
@property (readwrite) int numRequests;


- (void) doBatch:(NSArray*)saveFileNames URLs:(NSArray*)urls URLParameters:(NSString*)urlParamters;
- (void) notifyRequestComplete:(NSString*)filePathString;

@end
