/*
 Copyright (c) 2008, 2009 Lee Barney
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

#import "ListFilesBCO.h"


@implementation ListFilesBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileNameString = [[dictionary objectForKey:@"parameters"] objectAtIndex:1];
    fileNameString = [fileNameString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"file name: %@",fileNameString);
    if([fileNameString isEqualToString:@"undefined"]){
        fileNameString = @"";
    }
    //NSLog(@"file name2: %@",fileNameString);
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileNameString];
    //NSString *text = [[dictionary objectForKey:@"parameters"] objectAtIndex:2];
    NSError *err = nil;
    //[text writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    //NSLog(@"path: %@",fullPath);
    NSString *resultIndicator = @"noSuchFile";
    BOOL isDir = NO;
    id retVal = nil;
    //NSLog(@"full path: %@",fullPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]){
        resultIndicator = @"foundContents";
        //NSLog(@"isDir: %@", isDir?@"YES":@"NO");
        if (isDir) {
            NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:&err];
            retVal = [NSMutableArray arrayWithCapacity:[fileNameList count]];
            for (NSString *fileName in fileNameList) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",fullPath, fileName];
                NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err]];
                
                [attributes removeObjectForKey:@"NSFileExtendedAttributes"];
                //[attributes setValue:@"" forKey: NSFileExtendedAttributes]);
                filePath = [filePath stringByReplacingOccurrencesOfString:documentsDirectory withString:@""];
                filePath = [filePath substringFromIndex:1];
                [retVal addObject:[NSArray arrayWithObjects:attributes, filePath, nil]];
            }
            //NSLog(@"file list: %@",retVal);
            if (!retVal) {
                retVal = [NSArray array];
            }
            
        }
        else{
            retVal = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&err];
        }
    }
    if (err != nil) {
        //NSLog(@"error: %@",err);
        [dictionary setObject:[NSArray arrayWithObjects:@"ERROR", [NSString stringWithFormat:@"Unable to get contents of %@", fileNameString], nil] forKey:@"fileManipulationResult"];
    }
    else{
        [dictionary setObject:[NSArray arrayWithObjects:resultIndicator,retVal, nil] forKey:@"fileManipulationResult"];
    }
    return QC_STACK_CONTINUE;
}
@end









