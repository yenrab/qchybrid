//
//  DownloadFileBCO.m
//  QCLib
//
//  Created by lee on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileDownloadBCO.h"
#import "QCHTTPHandler.h"


@implementation FileDownloadBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    //NSLog(@"downloading file: %@",parameters);
	NSString *URLString = [parameters objectAtIndex:1];
    NSString *fileName = [parameters objectAtIndex:2];
	NSString *URLParameters = [parameters objectAtIndex:3];
	NSString *OverWriteFlag = [parameters objectAtIndex:4];
	
	QCHTTPHandler *getHandler = [[QCHTTPHandler alloc] init];
	
	getHandler.passThroughParameters = parameters;
	[getHandler startGet:fileName fromURL:URLString URLParameters:URLParameters shouldOverwrite:[OverWriteFlag isEqualToString:@"YES"]?YES : NO];
	return QC_STACK_EXIT;
}
@end
