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

#import "DeleteFileBCO.h"


@implementation DeleteFileBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
    NSString *fileNameString = parameters[1];
    fileNameString = [fileNameString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *resultIndicator = @"deleteFailure";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    
    path = [NSString stringWithFormat:@"%@/%@",path,fileNameString];
    NSLog(@"deleting file %@",path);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){ //![fileName isEqualToString:@"undefined"]) {
        NSError *err;
        if([[NSFileManager defaultManager] removeItemAtPath:path error:&err]){
            resultIndicator = @"fileDeleted";
        }
    }
    NSLog(@"result: %@",resultIndicator);
    dictionary[@"fileManipulationResult"] = @[resultIndicator,fileNameString];
    return QC_STACK_CONTINUE;
}
@end
