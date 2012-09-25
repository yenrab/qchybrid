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

#import "ShowImagePickerVCO.h"
#import "QuickConnectViewController.h"
#import "ImagePickerViewController.h"
#import "DeviceWebView.h"

@implementation ShowImagePickerVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    
       
    
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	ImagePickerViewController *anImagePickerDelegate = [[ImagePickerViewController alloc] init];
    
	QuickConnectViewController *theController = [parameters objectAtIndex:0];
	
	
    anImagePickerDelegate.theQCController = theController;
	anImagePickerDelegate.passThroughParams = parameters;
	[theController.view addSubview:anImagePickerDelegate.view];
    if (IS_IPAD())
    {
        
        UIPopoverController *popoverController;
        if(!anImagePickerDelegate.popoverController){
            UIImagePickerController* aPickerController = [[UIImagePickerController alloc] init];
            aPickerController.delegate = anImagePickerDelegate;
            aPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            popoverController = [[UIPopoverController alloc] initWithContentViewController:aPickerController];
            anImagePickerDelegate.popoverController = popoverController;
        }
        popoverController.delegate = anImagePickerDelegate;
        [popoverController presentPopoverFromRect:CGRectMake(0.0, 0.0, 0.0, 0.0) inView:theController.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        [anImagePickerDelegate showImagePickerModalView];
    }
	return QC_STACK_EXIT;
}
@end
/*
 - (void)photoPickerAdv {
 
 w = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
 vc = [[UIViewController alloc] init];
 [w addSubview: vc.view];
 [w makeKeyAndVisible];
 
 if(self.popoverController == nil)
 {   
 
 UIImagePickerController* picker = [[UIImagePickerController alloc] init];
 picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 picker.delegate = self;
 picker.allowsEditing = YES;
 picker.wantsFullScreenLayout = YES;
 
 self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];;     
 
 [picker release];
 [popover release];
 popoverController.delegate = self;
 }
 
 [self.popoverController setPopoverContentSize:CGSizeMake(160,160) animated:YES];
 CGRect selectedRect = CGRectMake(0,0,1,1);
 [self.popoverController presentPopoverFromRect:selectedRect inView:vc.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
 [vc release];
 
 
 
 - (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
 {
 [self sendUnityResultString:@"cancel"];
 [w resignKeyWindow];
 [w release];
 
 UnityPause(NO);
 }
 
 
 
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
 {
 [self.popoverController dismissPopoverAnimated:true];
 
 [[picker parentViewController] dismissModalViewControllerAnimated:YES];
 [w resignKeyWindow];
 [w release];
 
 [self sendUnityResultString:@"cancel"];
 UnityPause(NO);
 }
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
 {
 NSString *s = @"cancel";
 [self sendUnityResultString:s];
 
 [[picker parentViewController] dismissModalViewControllerAnimated:YES];
 [w resignKeyWindow];
 [w release];
 
 UnityPause(NO);
 }
*/