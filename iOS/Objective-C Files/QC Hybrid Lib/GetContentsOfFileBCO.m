//
//  GetContentsOfFileBCO.m
//  QC Hybrid Lib
//
//  Created by Lee Barney on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GetContentsOfFileBCO.h"
#import "QCControlObject.h"

@implementation GetContentsOfFileBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileNameString = [[dictionary objectForKey:@"parameters"] objectAtIndex:1];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileNameString];
    BOOL foundFile = YES;
    BOOL isDir = NO;
    NSString *fileContents = @"";
    NSError *err;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]){
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        fullPath = [bundlePath stringByAppendingPathComponent:fileNameString];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]){
            foundFile = NO;
        }
    }
    if (foundFile && !isDir) {
        fileContents = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&err];
        /*
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\"" withString:@"&nquote;"];
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"[" withString:@"&nlbracket;"];
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"]" withString:@"&nrbracket;"];
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"{" withString:@"&nlbrace;"];
        fileContents = [fileContents stringByReplacingOccurrencesOfString:@"}" withString:@"&nrbrace;"];
        fileContents = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"&nln;"];
         */
        
        //fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\"" withString:@"&nquote;"];
        fileContents = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"&nln;"];
    }
    [dictionary setObject:[NSArray arrayWithObjects:foundFile?@"foundContents" : @"noSuchFile",fileContents, nil] forKey:@"fileManipulationResult"];
    return QC_STACK_CONTINUE;

}

@end
