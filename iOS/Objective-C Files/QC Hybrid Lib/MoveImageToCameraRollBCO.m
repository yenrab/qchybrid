//
//  MoveImageToCameraRollBCO.m
//  QC Hybrid Lib
//
//  Created by Lee Barney on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveImageToCameraRollBCO.h"


@implementation MoveImageToCameraRollBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [paths objectAtIndex:0];
    
    NSString *fileName = [parameters objectAtIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",dirPath,fileName];
    
    
    UIImage *theImage = [UIImage imageWithContentsOfFile:filePath];
    UIImageWriteToSavedPhotosAlbum(theImage,nil,nil,nil);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err = nil;
    [fileManager  removeItemAtPath:filePath error:&err];
    [dictionary setObject:[NSArray arrayWithObjects:@"movedToRoll", fileName, nil] forKey:@"fileMoved"];
    
    return QC_STACK_CONTINUE;
}
@end
