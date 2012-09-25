//
//  ImagePickerController.h
//  QCLib
//
//  Created by lee on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickConnectViewController.h"

@interface ImagePickerController : UIViewController {
	NSArray *passThroughParams;
	QuickConnectViewController *theQCController;
}

@property (nonatomic, retain) NSArray *passThroughParams;
@property (nonatomic, retain) QuickConnectViewController *theQCController;


@end
