//
//  FileViewController.h
//  File Reader
//
//  Created by Lee Barney on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>


@interface FileDisplayDataSource : NSObject <QLPreviewControllerDataSource>{
    NSArray *documents;
}
@property (nonatomic, strong) NSArray *documents;
-(id)initWithFile:(NSString*)aFileName;
@end
