//
//  iAdBCO.m
//  QCLib
//
//  Created by Michael Adkins on 7/10/10.
//  Copyright 2010 Archanet Technologies. All rights reserved.
//

#import "iAdBCO.h"
#import "QuickConnectViewController.h"

//   iAd Params
//   0   QCVC
//   1   cmd



@implementation iAdBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    //NSArray *parameters = [dictionary objectForKey:@"parameters"];
	#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_0
	QuickConnectViewController *controller = [parameters objectAtIndex:0];
	NSString *cmd = [parameters objectAtIndex:1];
	NSString *myOrientation = @"0";
	
	
	if ([cmd isEqualToString:@"CreateBanner"]){
		//  Slider Params
		// 0   QCVC
		// 1   cmd
		// 2   Banner Location 0-TOP 1-BOTTOM 2-OTHER
		// 3   OPTIONAL if you chose 2 for OTHER.  Portrait  Y
		// 4   OPTIONAL if you chose 2 for OTHER.  Landscape Y
		
		
		///////
		controller.bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
		[[controller bannerView] setDelegate:controller];
		CGRect frame = controller.bannerView.frame;
		controller.bannerIsVisible = YES;
		controller.bannerLocation = [[parameters objectAtIndex:2] intValue];
		
		UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
		switch (o) {
			case UIDeviceOrientationPortrait:
				myOrientation=@"0";
				break;
            case UIDeviceOrientationPortraitUpsideDown:
                myOrientation=@"0";
                break;
			case UIDeviceOrientationLandscapeLeft:
				myOrientation=@"1";
				break;
			case UIDeviceOrientationLandscapeRight:
				myOrientation=@"1";
				break;
            case UIDeviceOrientationUnknown:
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
                break;
		}
		
		if ([controller bannerLocation]==0) {
			if ([myOrientation isEqualToString:@"0"]){
				frame.origin = CGPointMake(0.0, 0.0);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, 0.0);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			}else if ([myOrientation isEqualToString:@"1"]){
				frame.origin = CGPointMake(0.0, 0.0);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, 0.0);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			}
		}else if ([controller bannerLocation]==1) {
			if ([myOrientation isEqualToString:@"0"]){
				frame.origin = CGPointMake(0.0, 410.0);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, 410.0);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			}else if ([myOrientation isEqualToString:@"1"]){
				frame.origin = CGPointMake(0.0, 268.0);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, 268.0);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			}
		}else if ([controller bannerLocation]==2) {
			controller.bannerPortraitY = [[parameters objectAtIndex:3] floatValue]; 
			controller.bannerLandscapeY = [[parameters objectAtIndex:4] floatValue]; 
			
			if ([myOrientation isEqualToString:@"0"]){
				frame.origin = CGPointMake(0.0, [[parameters objectAtIndex:3] floatValue]);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, [[parameters objectAtIndex:3] floatValue]);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
			}else if ([myOrientation isEqualToString:@"1"]){
				frame.origin = CGPointMake(0.0, [[parameters objectAtIndex:4] floatValue]);
				[[controller bannerView] setFrame:frame];
				controller.bannerPosition = CGPointMake(0.0, [[parameters objectAtIndex:4] floatValue]);
				[[controller bannerView] setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
				[[controller bannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
			}
		}
		[[controller bannerView] setHidden:NO];
		[controller.view addSubview:[controller bannerView]];
		///////
	}
	else if ([cmd isEqualToString:@"setHidden"]){
		[[controller bannerView] setHidden:[[parameters objectAtIndex:2] boolValue]];
		if ([[parameters objectAtIndex:2] boolValue]){
			controller.bannerIsVisible = NO;
		}else {
			controller.bannerIsVisible = YES;
		}
	}	
#endif
	return QC_STACK_EXIT;
}
@end

