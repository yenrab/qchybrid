/*
 Copyright (c) 2008, 2009, 2012 Lee Barney
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
#import <StoreKit/StoreKit.h>

#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "QuickConnect.h"
#import "AllCOHeaders.h"
#import "QCStorePurchaseRequestDelegate.h"
#import "DeviceWebView.h"
#import "InterlayerMessageSystem.h"



@implementation QuickConnectViewController

@synthesize theHandler;
@synthesize messagingSystem;

@synthesize activateAccelerometer;
@synthesize activateCompass;
@synthesize shouldAutoRotate;

@synthesize window;
@synthesize webView;
@synthesize imageView;
@synthesize locationManager;
@synthesize audioRecorder;
@synthesize audioPlayers;
@synthesize databases;


@synthesize nativeHeaders;
@synthesize nativeFooters;
@synthesize nativeButtons;

@synthesize shownFooters;


@synthesize purchaseDelegate;

@synthesize thePicker;
@synthesize theSession;
@synthesize thePeers;

@synthesize activityIndicator;
@synthesize tabbar;

@synthesize messagePollingQueue;

@synthesize imagePickerController;
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_0
@synthesize bannerView;
@synthesize previewer;
#endif
@synthesize bannerPosition;
@synthesize bannerIsVisible;
@synthesize bannerLocation;
@synthesize bannerPortraitY;
@synthesize bannerLandscapeY;
- (id)init
{
	//NSLog(@"initing QCVController");
    self = [super init];
	theHandler = [[QuickConnect alloc] init];
	//set the transaction complete delegate to be the QCViewController
	
	audioPlayers = [[NSMutableDictionary alloc] init];
    databases  = [[NSMutableDictionary alloc] init];
    
	nativeHeaders = [[NSMutableDictionary alloc] init];
    
	nativeFooters = [[NSMutableDictionary alloc] init];
    
	nativeButtons = [[NSMutableDictionary alloc] init];
    
	
	purchaseDelegate = [[QCStorePurchaseRequestDelegate alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:purchaseDelegate];
	
	thePicker = [[GKPeerPickerController alloc] init];
    thePicker.delegate=self;
	thePicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby | GKPeerPickerConnectionTypeOnline;
	thePeers=[[NSMutableArray alloc] init];
    
    
	//if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		[self loadView];
	//}
	return self;
}


- (void) addWebViewToWindow:(UIWindow*) aWindow{
    window = aWindow;
    //NSLog(@"adding webView: %@",self.webView);
    //NSLog(@"subViews -1: %@",window.subviews);
    [window addSubview:self.webView];
    //NSLog(@"subViews 0: %@",window.subviews);
}

- (void)loadView
{
    //NSLog(@"loading View");
	self.activateAccelerometer = NO;
	self.activateCompass = NO;
	self.shouldAutoRotate = YES;
	//NSLog(@"loading view");
	//[QCClassLoader loadCommandObjects];
    [self mapCommands];
	
	CGFloat toolbarHeight = 0;
	
	
	
	// create the location manager
	locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
    // Set a movement threshold for new events
    locationManager.distanceFilter = kCLDistanceFilterNone;
	
    
	//
	//End of location section
	//
	
	
	//create a frame that will be used to size and place the web view
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	
	//NSLog(@"theFrame now: %@",NSStringFromCGRect(webFrame));
	//webFrame.origin.y -= 20.0;	// shift the display up so that it covers the default open space from the content view
	webFrame.size.height -=toolbarHeight;
	DeviceWebView *aWebView = [[DeviceWebView alloc] initWithFrame:webFrame];
	self.webView = aWebView;
    self.view = aWebView;
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.view.autoresizesSubviews = YES;
    
    NSString *portraitImageFilePathString = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    NSString *landscapeImageFilePathString = [[NSBundle mainBundle] pathForResource:@"DefaultLandscape" ofType:@"png"];
    NSString *iPadportraitImageFilePathString = [[NSBundle mainBundle] pathForResource:@"Default-ipad" ofType:@"png"];
    NSString *iPadlandscapeImageFilePathString = [[NSBundle mainBundle] pathForResource:@"DefaultLandscape-ipad" ofType:@"png"];
    
    NSString *splashFileName = nil;
    if(portraitImageFilePathString != nil || landscapeImageFilePathString != nil){
        //CGRect splashFrame = [[UIScreen mainScreen] applicationFrame];
        CGRect splashFrame;
        UIInterfaceOrientation interfaceOrientation = [self interfaceOrientation];
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                splashFileName = iPadlandscapeImageFilePathString;
                splashFrame = CGRectMake(0, 0, 1024, 768);
            }
            
            else
            { 
                splashFileName = landscapeImageFilePathString;
                splashFrame = CGRectMake(0, 0, 480, 320);
            }
        }
        else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                splashFileName = iPadportraitImageFilePathString;
                splashFrame = CGRectMake(0, 0, 768, 1024);
            }
            
            else
            { 
                splashFileName = portraitImageFilePathString;
                splashFrame = CGRectMake(0, 0, 320, 480);//may need to be 460
            }
        }
        UIImage *splashImage = [[UIImage alloc] initWithContentsOfFile: splashFileName];
        UIImageView *splashView = [[UIImageView alloc] initWithImage:splashImage];
        splashView.frame = splashFrame;

        splashView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        //[splashView setDelegate:self];
		
        //[contentView addSubview:splashView];
        [window addSubview:splashView];
		[self.view setHidden:YES];//hide the webView
    }
	 
	
	/*
	 *	Uncomment the following line if you want the HTML to scale to fit.  
	 *	This also allows the pinch zoom in and out functionallity to work.
	 */
	//aWebView.scalesPageToFit = YES;
    
    self.messagingSystem = [[InterlayerMessageSystem alloc] initWithHandler:self];
    
    //set the web view delegate for the web view to be itself
	[aWebView setDelegate:self];
    aWebView.allowsInlineMediaPlayback = YES;
    aWebView.mediaPlaybackRequiresUserAction = NO;
    aWebView.mediaPlaybackAllowsAirPlay = YES;
    
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
    // the path to storage file
    NSString *storageFile = [documentsDirectory stringByAppendingPathComponent:@"local_storage_file"];
    NSDictionary *storageDictionary = [NSDictionary dictionaryWithContentsOfFile:storageFile];
    
    NSLog(@"existing dictionary: %@",storageDictionary);
    if(!storageDictionary){
        NSLog(@"new dictionary");
        storageDictionary = [NSDictionary dictionary];
    }
    NSLog(@"about to set local storage using: %@", storageDictionary);
    if(![self.messagingSystem setLocalStorage:storageDictionary]){
        NSLog(@"failed to set local storage in web view");
    }
     */
	
	//determine the path the to the index.html file in the Resources directory
	NSString *filePathString = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	//build the URL and the request for the index.html file
	NSURL *aURL = [NSURL fileURLWithPath:filePathString];
	NSURLRequest *aRequest = [NSURLRequest requestWithURL:aURL];
	
	
	//load the index.html file into the web view.
	[aWebView loadRequest:aRequest];
	
	//add the web view to the content view
	//[contentView addSubview:webView];
	
	
	
	//[contentView release];
}

- (void) mapCommands{
	//NSLog(@"mapping commands");
    
    /*
     * mappings for file IO
     */
    
    [theHandler mapCommandToBCO:@"saveFile" withObject:[SaveContentsToFileBCO class]];
    //[theHandler mapCommandToVCO:@"saveFile" withObject:[SendSaveResultsVCO class]];
    [theHandler mapCommandToVCO:@"saveFile" withObject:[FileManipulationVCO class]];
    
    [theHandler mapCommandToBCO:@"fileContents" withObject:[GetContentsOfFileBCO class]];
    [theHandler mapCommandToVCO:@"fileContents" withObject:[FileManipulationVCO class]];
    
    [theHandler mapCommandToBCO:@"makeDir" withObject:[CreateDirBCO class]];
    //[theHandler mapCommandToVCO:@"makeDir" withObject:[SendSaveResultsVCO class]];
    [theHandler mapCommandToVCO:@"makeDir" withObject:[SendSaveResultsVCO class]];
    
    [theHandler mapCommandToBCO:@"listFiles" withObject:[ListFilesBCO class]];
    [theHandler mapCommandToVCO:@"listFiles" withObject:[ListFilesVCO class]];
    
    [theHandler mapCommandToBCO:@"deleteFile" withObject:[DeleteFileBCO class]];
    [theHandler mapCommandToVCO:@"deleteFile" withObject:[FileManipulationVCO class]];
    
    /*
     * mappings for device behaviors
     */
    
	[self.theHandler mapCommandToBCO:@"switchAccelerometer" withObject:[SwitchAccelerometerBCO class]];
	
	[theHandler mapCommandToBCO:@"switchHeading" withObject:[SwitchHeadingBCO class]];
	
	[theHandler mapCommandToBCO:@"switchAutoRotation" withObject:[SwitchRotationBCO class]];
	
	[theHandler mapCommandToVCO:@"logMessage" withObject:[LoggingVCO class]];
	
	[theHandler mapCommandToVCO:@"playSound" withObject:[PlaySoundVCO class]];
    
	
	[theHandler mapCommandToBCO:@"loc" withObject:[LocationBCO class]];
	
	[theHandler mapCommandToVCO:@"sendloc" withObject:[LocationVCO class]];
    
	[theHandler mapCommandToVCO:@"showDate" withObject:[DatePickerVCO class]];
    
	[theHandler mapCommandToVCO:@"sendPickResults" withObject:[PickResultsVCO class]];
    
	[theHandler mapCommandToVCO:@"play" withObject:[PlayAudioVCO class]];
    
	[theHandler mapCommandToVCO:@"rec" withObject:[RecordAudioVCO class]];
    
	[theHandler mapCommandToVCO:@"showMap" withObject:[ShowMapVCO class]];
	
	[theHandler mapCommandToVCO:@"showEmail" withObject:[ShowEmailEditorVCO class]];
	
	[theHandler mapCommandToVCO:@"showImages" withObject:[ShowImagePickerVCO class]];
	
	[theHandler mapCommandToVCO:@"showCamera" withObject:[ShowCameraPickerVCO class]];
    [theHandler mapCommandToBCO:@"moveImage" withObject:[MoveImageToCameraRollBCO class]];
    [theHandler mapCommandToVCO:@"moveImage" withObject:[MoveImageToCameraRollVCO class]];
	
	[theHandler mapCommandToBCO:@"designTabBar" withObject:[TabBarBCO class]];
	
	[theHandler mapCommandToVCO:@"designSwitch" withObject:[SwitchBCO class]];
	
	[theHandler mapCommandToVCO:@"designProgressBar" withObject:[ProgressBarVCO class]];
    
    /*
     *  mappings for native SQLite database access
     */
	
	
	[theHandler mapCommandToBCO:@"handleTransactionRequest" withObject:[TransactionHandlerBCO class]];
	[theHandler mapCommandToVCO:@"handleTransactionRequest" withObject:[SendDBResultVCO class]];
    
	[theHandler mapCommandToBCO:@"getData" withObject:[GetDataBCO class]];
	[theHandler mapCommandToVCO:@"getData" withObject:[SendDBResultVCO class]];
    
	
	[theHandler mapCommandToBCO:@"setData" withObject:[SetDataBCO class]];
	[theHandler mapCommandToVCO:@"setData" withObject:[SendDBResultVCO class]];
    
    
	[theHandler mapCommandToBCO:@"closeData" withObject:[CloseDataBCO class]];
	[theHandler mapCommandToVCO:@"closeData" withObject:[CloseDataVCO class]];
	
	[theHandler mapCommandToBCO:@"runDBScript" withObject:[ExecuteDBScriptBCO class]];
	[theHandler mapCommandToVCO:@"runDBScript" withObject:[SendDBResultVCO class]];
	
	
	
    
    
	[theHandler mapCommandToVCO:@"sendDeviceDescription" withObject:[GetDeviceInfoVCO class]];
	
    
	[theHandler mapCommandToBCO:@"getPreference" withObject:[GetPreferencesBCO class]];
	[theHandler mapCommandToVCO:@"getPreference" withObject:[GetPreferencesVCO class]];
	
	
	/*
	 * StoreKit control
	 */
	
	
	[theHandler mapCommandToBCO:@"getProductInfo" withObject:[RequestStoreProductInfoBCO class]];
	
	[theHandler mapCommandToVCO:@"canMakePaymentsCheck" withObject:[CanMakePaymentsVCO class]];
	
	[theHandler mapCommandToBCO:@"startPurchase" withObject:[MakePurchaseBCO class]];
	
	
	/*
	 contacts control
     */
	[theHandler mapCommandToBCO:@"allContacts" withObject:[ContactPickerVCO class]];
	[theHandler mapCommandToVCO:@"sendPersonPickResults" withObject:[SendPersonPickerResultsVCO class]];
	
	
	[theHandler mapCommandToVCO:@"networkStatus" withObject:[VerifyDeviceIsConnectedToInternetVCO class]];
	
	
	/*
	 uploading and downloading files and data
	 */
	
	[theHandler mapCommandToBCO:@"uploadFile" withObject:[FileUploadBCO class]];
	[theHandler mapCommandToBCO:@"downloadFile" withObject:[FileDownloadBCO class]];
	[theHandler mapCommandToBCO:@"downloadFileBatch" withObject:[BatchFileDownloadBCO class]];
	
	[theHandler mapCommandToVCO:@"switchActivityIndicator" withObject:[SwitchActivityIndicatorVCO class]];
	[theHandler mapCommandToVCO:@"switchNetworkIndicator" withObject:[SwitchNetworkIndicatorBCO class]];
	
	/*
	 *  iAdd
	 */
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_0
	[theHandler mapCommandToBCO:@"iAd" withObject:[iAdBCO class]];
    
	[theHandler mapCommandToVCO:@"showFile" withObject:[ShowFileVCO class]];
#endif
    
    
    
	//NSLog(@"done mapping commands");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	//NSLog(@"in should rotate web view");
	////NSLog(@"iterate over all of the footers and hide them");
	if(self.shouldAutoRotate){
		NSMutableArray *paramsToPass = [NSMutableArray arrayWithCapacity:2];
		[paramsToPass insertObject:self atIndex:0];
		[paramsToPass insertObject:self atIndex:1];
		[paramsToPass insertObject:@"rotating" atIndex:2];
		NSArray *footerIds = [shownFooters allKeys];
		int numFooters = [footerIds count];
		
		for(int i = 0; i < numFooters; i++){
			
			NSString *footerId = footerIds[i];
			//UIToolbar *barToHide = [ nativeFooters objectForKey:footerId];
			paramsToPass[1] = footerId;
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
			[theHandler handleRequest:@"hideFooter" withParameters:parameters];
		}
	}
    //NSLog(@"returning %@", self.shouldAutoRotate?@"YES":@"NO");
    return self.shouldAutoRotate;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
	//NSLog(@"did rotate");
	NSString *orientationString = nil;
	switch ([[UIDevice currentDevice] orientation])
    {
		case UIDeviceOrientationPortrait:
			orientationString = @"window.__defineGetter__('orientation',function(){return 0;});";
			break;
		case UIDeviceOrientationLandscapeLeft:
			orientationString = @"window.__defineGetter__('orientation',function(){return 90;});";
            break;
        case UIDeviceOrientationLandscapeRight:
			orientationString = @"window.__defineGetter__('orientation',function(){return -90;});";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
			orientationString = @"window.__defineGetter__('orientation',function(){return 180;});";
            break;
			
        default:
            break;
    }
	
	NSString *orientationEventTriggerString = @"var orientationEvent=document.createEvent('Events');orientationEvent.initEvent('orientationchange', true, true);window.dispatchEvent(orientationEvent);";
	//NSString *resizeEventTriggerString = @"var resizeEvent=document.createEvent('Events');resizeEvent.initEvent('resize', true, true);window.dispatchEvent(resizeEvent);";
	NSString *resizeEventTriggerString = @"";
	NSString *JSString = [NSString stringWithFormat:@"%@%@%@",orientationString,orientationEventTriggerString,resizeEventTriggerString];
	//NSLog(@"orientation event string: %@",JSString);
	[webView stringByEvaluatingJavaScriptFromString:JSString];
	//NSLog(@"in did rotate");
    //NSLog(@"iterate over all of the footers and show them");
	
	NSMutableArray *paramsToPass = [NSMutableArray arrayWithCapacity:2];
	[paramsToPass insertObject:self atIndex:0];
	[paramsToPass insertObject:self atIndex:1];
	[paramsToPass insertObject:@"rotating" atIndex:2];
	
	NSArray *footerIds = [shownFooters allKeys];
	////NSLog(@"footerIds: %@",footerIds);
	int numFooters = [footerIds count];
	for(int i = 0; i < numFooters; i++){
		NSString *footerId = footerIds[i];
		//UIToolbar *barToShow = [nativeFooters objectForKey:footerId];
		////NSLog(@"showing footer: %@",footerId);
		paramsToPass[1] = footerId;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
		[theHandler handleRequest:@"showFooter" withParameters:parameters];
	}
}
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_0
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	if ([self bannerLocation]==0) {
		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = bannerPosition;
				bannerView.frame = frame;	
			}
		}else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = bannerPosition;
				bannerView.frame = frame;
			}
		}
	}else if ([self bannerLocation]==1) {
		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = CGPointMake(0.0, 410.0);
				[[self bannerView] setFrame:frame];
				self.bannerPosition = CGPointMake(0.0, 410.0);
			}
		}else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = CGPointMake(0.0, 268.0);
				[[self bannerView] setFrame:frame];
				self.bannerPosition = CGPointMake(0.0, 268.0);
			}
		}
	}else if ([self bannerLocation]==2) {
		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = CGPointMake(0.0, self.bannerPortraitY);
				[[self bannerView] setFrame:frame];
				self.bannerPosition = CGPointMake(0.0, self.bannerPortraitY);
			}
		}else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			[[self bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			if (self.bannerIsVisible) {
				CGRect frame = bannerView.frame;
				frame.origin = CGPointMake(0.0, self.bannerLandscapeY);
				[[self bannerView] setFrame:frame];
				self.bannerPosition = CGPointMake(0.0, self.bannerLandscapeY);
			}
		}		
	}

}             
#pragma mark ADBannerViewDelegate methods

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	//NSLog(@"Banner view is beginning an ad action");
	//BOOL shouldExecuteAction = [self allowActionToRun]; // your application implements this method
	//if (!willLeave && shouldExecuteAction) {
	// insert code here to suspend any services that might conflict with the advertisement
	//}
	
	if (!self.bannerIsVisible) {
		return FALSE;
	}
	return TRUE; //shouldExecuteAction;
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		// assumes the banner view is offset 50 pixels so that it is not visible.
        //banner.frame = CGRectOffset(banner.frame, 0, 50);
		CGRect frame = banner.frame;
		frame.origin = self.bannerPosition;
		banner.frame = frame;
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	if (self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        //banner.frame = CGRectOffset(banner.frame, 0, -50);
		CGRect frame = banner.frame;
		frame.origin = CGPointMake(0.0, -500.0);
		banner.frame = frame;
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

#endif

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if (self.activateAccelerometer) {
		//NSLog(@"accelerometer active");
		NSString* javaScriptCall = [NSString stringWithFormat:@"accelerate(%f, %f, %f)", acceleration.x, acceleration.y, acceleration.z];
		//NSLog(@"%@",javaScriptCall);
		[webView stringByEvaluatingJavaScriptFromString:javaScriptCall];
	}
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		//NSLog(@"shaken");
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	if (self.activateCompass) {
		//NSLog(@"heading active");
		NSString * headingDescription = [newHeading description];
		NSString* javaScriptCall = [NSString stringWithFormat:@"heading(%@)", headingDescription];
		//NSLog(@"%@",javaScriptCall);
		[webView stringByEvaluatingJavaScriptFromString:javaScriptCall];
	}
}


- (void) closeDown
{
	NSString* javaScriptCall = @"document.getElementsByTagName('body')[0].onunload()";
	[webView stringByEvaluatingJavaScriptFromString:javaScriptCall];
	//NSLog(@"closed");
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
	// Release anything that's not essential, such as cached data.
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"An error happened during load: %@",error);
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
	//NSLog(@"loading started");
}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
	//NSLog(@"finished loading");
	/* set the delegate for the accelerometer to be the QuickConnectViewController
	 *  do this after the page has loaded so that no javascript calls will be made
	 *  to push the values to the page before the page is loaded.
	 *
	 *  kAccelerometerFrequency is defined in the header file.
	 */
	//uncomment these lines of code if you want to use acceleration in your application
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	//[aWebView  stringByEvaluatingJavaScriptFromString:@"okToSend()"];
    
	
	[self.webView setHidden:NO];
    /*
     * start getting the list of commands to execute
     */
    messagePollingQueue = [NSOperationQueue new];
    [messagePollingQueue addOperation:self.messagingSystem];
    
}


- (void)action:(id)sender
{
    NSMutableArray * paramsToPass = [[NSMutableArray alloc] initWithCapacity:1];
    [paramsToPass addObject:self];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
    [theHandler handleRequest:@"sendPickResults" withParameters:parameters];
	
	
}
//uncomment these lines if you want to use locations in your JavaScript application

/*
 * Delegate method from the CLLocationManagerDelegate protocol.
 * This method is called asynchronously when the location is determined.
 * As such it has its' own command that it passes the handleRequest method.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	//NSLog(@"Location updated");
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //NSLog(@"date: %@    howRecent: %f",eventDate, howRecent);
    //if (abs(howRecent) < 5.0){
    NSMutableArray *paramsToPass = [[NSMutableArray alloc] initWithCapacity:3];
    [paramsToPass addObject:self];
    [paramsToPass addObject:newLocation];
    if (abs(howRecent) < 5.0 && oldLocation != nil) {
        //NSLog(@"have old location");
		CLLocationDistance distanceMoved = [newLocation distanceFromLocation:oldLocation];
        //NSLog(@"distance: %f",distanceMoved);
        /*
        //NSLog(@"%@",[NSString stringWithFormat:@"found location(%f, %f, %f, %f)",
               newLocation.coordinate.latitude,
               newLocation.coordinate.longitude,
               newLocation.altitude,
               newLocation.horizontalAccuracy]);
		 */
        if(abs(howRecent) < 5 && distanceMoved <= 1){
            //NSLog(@"stopping");
            [manager stopUpdatingLocation];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
            [theHandler handleRequest:@"sendloc" withParameters:parameters];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	//NSLog(@"Error: Unable to determine location");
}


- (BOOL)webView:(UIWebView *)curWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	//NSLog(@"URL: %@",[request URL]);
    /*
     * launch the appropriate view to display any file in the distribution package.
     */
	if (![[[request URL] scheme] hasPrefix:@"file"]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
    return YES;
}

- (void)designTabBar:(NSArray*) parameters
{
	//      0		QCVC
	//		1		X
	//		2		Y
	//		3		W
	//		4		H
	//		5		TabBarItems
	
	NSString *TabBarX = parameters[1];
	NSString *TabBarY = parameters[2];
	NSString *TabBarWidth = parameters[3];
	NSString *TabBarHeight = parameters[4];
	
	//	CGRect frame = CGRectMake(0.0f, 32.0f, 320.0f, 20.0f);
	CGRect frame = CGRectMake([TabBarX floatValue], [TabBarY floatValue], [TabBarWidth floatValue], [TabBarHeight floatValue]);
	tabbar = [[UITabBar alloc] initWithFrame:frame];
	
	NSArray *Items;	
	Items = parameters[5];
	NSMutableArray *tabItems = [[NSMutableArray alloc] initWithCapacity:[Items count]];
	
	for(int i = 0; i < [Items count]; i++){
		NSArray	*ItemRecords = Items[i];
		[tabItems addObject:[[UITabBarItem alloc] initWithTitle:ItemRecords[0] image:[UIImage imageNamed:ItemRecords[1]] tag:i+1]]; 	
		//[ItemRecords release];
	}
	
	tabbar.items = tabItems; 
	[tabbar setSelectedItem:tabItems[0]];
	tabbar.alpha = 1.0; 	
	tabbar.userInteractionEnabled = YES; 	
	[tabbar setBackgroundColor:[UIColor blueColor]];
	[tabbar setDelegate:self];
	[tabbar setHidden:YES];
	[self.view addSubview:tabbar];
}	

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
	//NSLog(@"%@",item.title);
	NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:1];
	[passingArray addObject:@(item.tag)];
	SBJSON *generator = [SBJSON alloc];
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];
	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('tabBarVal', '%@')", paramsToPass];
	//NSLog(jsString);
	[webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSMutableArray *paramsToPass = [[NSMutableArray alloc] initWithCapacity:2];
    [paramsToPass addObject:self];
    [paramsToPass addObject:pickerView];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
    [theHandler handleRequest:@"sendPickResults" withParameters:parameters];
    
}

/*
 *  StoreKit transaction complete delegate
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	int numTransactions = [transactions count];
	NSMutableArray *transactionResults = [[NSMutableArray alloc] init];
	for(int i = 0; i < numTransactions; i++)
    {
		SKPaymentTransaction *transaction = transactions[i];
		NSMutableArray *transactionResult = [NSMutableArray arrayWithCapacity:7];
		NSNumber *state = @(transaction.transactionState);
		[transactionResult insertObject:state atIndex:0];
		[transactionResult insertObject:transaction.payment.productIdentifier atIndex:1];
		[transactionResult insertObject:@(transaction.payment.quantity) atIndex:2];
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
				[transactionResult insertObject:[transaction.transactionDate description] atIndex:3];
				[transactionResult insertObject:transaction.transactionIdentifier atIndex:4];
				[transactionResult insertObject:[[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSASCIIStringEncoding] atIndex:5];
                break;
            case SKPaymentTransactionStateRestored:
				[transactionResult insertObject:[transaction.transactionDate description] atIndex:3];
				[transactionResult insertObject:transaction.transactionIdentifier atIndex:4];
				break;
            case SKPaymentTransactionStateFailed:
				[transactionResult insertObject:[transaction.error localizedDescription] atIndex:3];
                break;
            default:
                break;
        }
		
    }
	  NSError *error;
	  SBJSON *generator = [SBJSON alloc];
	  NSString *dataString = [generator stringWithObject:transactionResults error:&error];
	  //NSLog(@"error: %@",error);		
	  //NSLog(@"about to send JSON: %@", dataString);
	  
	  NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('transactionDone', '%@)", dataString];
	  //NSLog(@"",jsString);
	  [self.webView stringByEvaluatingJavaScriptFromString:jsString];
	 
	
	
								
}

- (void) switchChanged:(id) sender;
{
    UISwitch *onoff = (UISwitch *) sender;
	int switchId = [onoff tag];
	NSMutableArray *passingArray = [[NSMutableArray alloc] initWithCapacity:2];
	[passingArray addObject:@(switchId)];
	
	if (onoff.on == YES){
		[passingArray addObject:@"YES"];
	}
	else {
		[passingArray addObject:@"NO"];
	}
	
	SBJSON *generator = [SBJSON alloc];
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];
	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('switchVal', '%@')", paramsToPass];
	[webView stringByEvaluatingJavaScriptFromString:jsString];
}


/*
 *  push notification functions
 */

- (void) sendTokenToProvider:(NSData *)devToken{
	
	/*
	 * try both of these.  I think one will work.  It should send the hex values as a string
	 * to your server.
	 */
	//NSArray *passingArray = [NSArray arrayWithObject:[devToken description]];
	//this one is the one that I think works based on feedback from Mike.
	//NSArray *passingArray = [NSArray arrayWithObject:[devToken hexString]];
    
    //trying this one to work with OS 5
    const unsigned *tokenBytes = [devToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSArray *passingArray = @[hexToken];
	SBJSON *generator = [SBJSON alloc];
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];
	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('sendTokenToPushProvider', '%@')", paramsToPass];
	//NSLog(@"%@",jsString);
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	
	
}


- (void) pushNotificationToJavaScript:(NSDictionary *)userInfo{
	
	NSArray *passingArray = @[userInfo];
	SBJSON *generator = [SBJSON alloc];
	NSError *error;
	NSString *paramsToPass = [generator stringWithObject:passingArray error:&error];
	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('getNotificationPushData', '%@')", paramsToPass];
	//NSLog(@"%@",jsString);
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	
}


#pragma mark GameKit code




@end
