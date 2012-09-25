//
//  SaveContentsToFileBCO.m
//  QC Hybrid Lib
//
//  Created by Lee Barney on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SaveContentsToFileBCO.h"


@implementation SaveContentsToFileBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    //NSLog(@"saving file");
    
    NSString *fileNameString = dictionary[@"parameters"][1];
    //NSLog(@"file name string: %@",fileNameString);
    //fileNameString = [fileNameString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"file name string: %@",fileNameString);
    /*
     * The user or developer may have used the wrong directory seperator character.  Fix it if they have.
     */
    fileNameString = [fileNameString stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]; 
    //NSLog(@"file name string: %@",fileNameString);
    NSArray *fileNamePaths = [fileNameString componentsSeparatedByString:@"/"];
    //NSLog(@"path components: %@",fileNamePaths);
    fileNameString = [fileNamePaths lastObject];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = paths[0];
    NSError *err = nil;

    for (int i = 0; i < [fileNamePaths count] -1; i++) {
        dirPath = [NSString stringWithFormat:@"%@/%@",dirPath,fileNamePaths[i]];
    }
    //NSLog(@"dir string: %@",dirPath);
    if ([fileNamePaths count] > 1) {
        NSLog(@"creating dir");
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath 
                                      withIntermediateDirectories:YES attributes:nil error:&err];
        //NSLog(@"dir created");
    }
    NSString *fullPath = [dirPath stringByAppendingPathComponent:fileNameString];
    //NSString *text = [[[dictionary objectForKey:@"parameters"] objectAtIndex:2]
    //                 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *text = dictionary[@"parameters"][2];
    //NSLog(@"save file: %@",fullPath);
    [text writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err != nil) {
        //NSLog(@"file save error: %@",err);
        dictionary[@"fileManipulationResult"] = @[@"ERROR", [NSString stringWithFormat:@"Unable to save %@ to disk", fileNameString]];
    }
    else{
        //NSLog(@"file saved");
        dictionary[@"fileManipulationResult"] = @[@"fileSaved",fileNameString];
    }
    return QC_STACK_CONTINUE;
}

@end
