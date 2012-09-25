//
//  FileViewController.m
//  File Reader
//
//  Created by Lee Barney on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileDisplayDataSource.h"


@implementation FileDisplayDataSource
@synthesize documents;
-(id)initWithFile:(NSString*)aFileName
{
    if ((self = [super init]))
    {
        documents = [NSArray arrayWithObject:aFileName];
    }
    return self;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller 
{
    //NSLog(@"documents: %@",documents);
    return [documents count];
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index 
{
    NSURL *retVal = nil;
    //check the documents directory to see if the file is there
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [[documents objectAtIndex: index] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
	//build the URL and the request for the index.html file
    //NSLog(@"path: %@",fullPath);
    BOOL foundFile = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
 
    //check the Bundle to see if the file is there
    if (!foundFile) {
        fullPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],fileName];
        //NSLog(@"path: %@",fullPath);
        foundFile = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    }  
    //load the file if found.
    if (foundFile) {
        retVal = [NSURL fileURLWithPath:fullPath];
    }
    //NSLog(@"final URL: %@",retVal);
    return retVal;
}

@end
