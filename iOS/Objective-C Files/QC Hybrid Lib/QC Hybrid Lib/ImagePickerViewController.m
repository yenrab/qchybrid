    //
//  ImagePickerViewController.m
//  QCLib
//
//  Created by lee on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"
#import "QuickConnect.h"


@implementation ImagePickerViewController

@synthesize passThroughParams;
@synthesize theQCController;
@synthesize popoverController;
@synthesize aPicker;
@synthesize hidden;
@synthesize base;

-(void) showImagePickerModalView {
	
	[self showMediaPickerModalView:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void) showCameraPickerModalView {
	
	[self showMediaPickerModalView:UIImagePickerControllerSourceTypeCamera];
}

-(void) showMediaPickerModalView:(int)type {
    //NSLog(@"about to show");
    if([UIImagePickerController isSourceTypeAvailable:type])
    {
        [theQCController.webView removeFromSuperview];
        [theQCController.window addSubview:self.view];
        
        self.aPicker = [[UIImagePickerController alloc] init];
        self.aPicker.delegate = self;
        self.aPicker.sourceType = type;
        if (type == UIImagePickerControllerSourceTypeCamera) {
            self.aPicker.allowsEditing = YES;
            self.aPicker.showsCameraControls = YES;
        }
        aPicker.navigationBar.barStyle = UIBarStyleBlack;
        //NSLog(@"presenting");
        [self presentModalViewController:aPicker animated:NO];
        //NSLog(@"presented");
    }
}

- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //NSLog(@"picked");
	[self dismissModalViewControllerAnimated:NO];
	
	UIImage *imageToSend = info[@"UIImagePickerControllerOriginalImage"];

	if (info[@"UIImagePickerControllerOriginalImage"] != nil) {
		imageToSend = info[@"UIImagePickerControllerOriginalImage"];
	}
    //NSLog(@"about to add webView");
    [theQCController.window addSubview:theQCController.webView];
    //NSLog(@"webView added");
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	if(self.aPicker.sourceType == UIImagePickerControllerSourceTypeCamera){
        /*
         * Must have taken a picture
         */
        //NSLog(@"about to remove camera view");
        [self.view removeFromSuperview];
        //NSLog(@"removed camera view");
        //[self.theQCController.window bringSubviewToFront:self.theQCController.view];
        if([self.passThroughParams count] == 2){
            UIImageWriteToSavedPhotosAlbum(imageToSend,nil,nil,nil);
            [retVal addObject:@"savedToAlbum"];
        }
        else{//three items
            /*
             *  a picture name must have been supplied so save the bytes to the documents directory
             */
            NSString *fileName = (self.passThroughParams)[1];
            NSArray *arrayPaths = 
            NSSearchPathForDirectoriesInDomains(
                                                NSDocumentDirectory,
                                                NSUserDomainMask,
                                                YES);
            NSString *docDir = arrayPaths[0];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",docDir,fileName];
            
            [UIImagePNGRepresentation(imageToSend) writeToFile:filePath atomically:YES];
            [retVal addObject:@"savedToDocuments"];
        }
        
	}
	else {
        /*
         *  Must have selected a picture from the image picker
         */
		NSData *data = UIImagePNGRepresentation(imageToSend);
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
		NSString *documentsDirectory = paths[0];
        // create a UUID to use as the name of the moved file
        //create a UUID for the user
        CFUUIDRef	fileUUID = CFUUIDCreate(nil);//create a new UUID
        //get the string representation of the UUID
        NSString	*fileNameString = [NSString stringWithFormat:@"%@.png", (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, fileUUID))];
        CFRelease(fileUUID);
        
		NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileNameString];
		[fileManager createFileAtPath:fullPath contents:data attributes:nil];
		
		
		[retVal addObject:fileNameString];
        if(self.popoverController){
            UIPopoverController *popover = self.popoverController;
            [popover dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
	}
    self.aPicker = nil;

	//NSArray *list = [[dictionary objectForKey:@"BCOresults"] objectAtIndex:0];
    NSString *executionKey = [self.passThroughParams lastObject][0];//objectAtIndex:2] objectAtIndex:0];
    
    NSArray *resultsVal = @[retVal, 
                       executionKey];
	
	SBJSON *generator = [SBJSON alloc];
	//NSLog(@"passThroughParams %@",self.passThroughParams);
	[retVal addObject:(self.passThroughParams)[1]];
	NSError *JSONError;
	NSString *dataString = [generator stringWithObject:resultsVal error:&JSONError];
	//NSLog(@"Error: %@",JSONError);
    
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
	
	[self.theQCController.webView stringByEvaluatingJavaScriptFromString:jsString];
	
	
	
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController{
    
    [self.aPicker dismissModalViewControllerAnimated:NO];
    [self.view removeFromSuperview];
    /*
	 * return 'canceled' to the JavaScript side
	 */
	NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:2];
	[retVal addObject:@"canceled"];
	[retVal addObject:[self.passThroughParams lastObject]];
    
	SBJSON *generator = [SBJSON alloc];
	NSError *JSONError;
	NSString *dataString = [generator stringWithObject:retVal error:&JSONError];
    //NSLog(@"about to send JSON: %@", dataString);
    
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
	
	[self.theQCController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker{
    [self.aPicker dismissModalViewControllerAnimated:NO];
    [self.view removeFromSuperview];
    [self.theQCController.window bringSubviewToFront:self.theQCController.view];
    //[self.theQCController.view addSubview:self.theQCController.webView];
	
	SBJSON *generator = [SBJSON alloc];
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	/*
	 * return 'canceled' to the JavaScript side
	 */
	//NSLog(@"passThrough %@",self.passThroughParams);
	[retVal addObject:@"canceled"];
	[retVal addObject:[self.passThroughParams lastObject]];
	NSError *JSONError;
	NSString *dataString = [generator stringWithObject:retVal error:&JSONError];
    //NSLog(@"about to send JSON: %@", dataString);
    
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
	
	[self.theQCController.webView stringByEvaluatingJavaScriptFromString:jsString];
	
	//NSLog(@"image pick cancelled");
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
