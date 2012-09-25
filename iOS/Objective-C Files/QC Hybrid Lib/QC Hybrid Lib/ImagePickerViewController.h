//
//  ImagePickerViewController.h
//  QCLib
//
//  Created by lee on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickConnectViewController.h"

@class ImagePicerViewController;

@interface ImagePickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {

	
	NSArray *passThroughParams;
	QuickConnectViewController *theQCController;
    UIPopoverController *popoverController;
    UIImagePickerController *aPicker;
    CGRect hidden;
    CGRect base;

}

@property (nonatomic, strong) NSArray *passThroughParams;
@property (nonatomic, strong) QuickConnectViewController *theQCController;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIImagePickerController *aPicker;
@property (readwrite) CGRect hidden;
@property (readwrite) CGRect base;

-(void) showImagePickerModalView;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void) showCameraPickerModalView;
- (void) showImagePickerModalView;
- (void) showMediaPickerModalView:(int)type;

@end
