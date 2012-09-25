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

#import "ShowMapVCO.h"
#import "QCMapViewController.h"
#import "QCMapAnnotation.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"

#import <CoreLocation/CoreLocation.h>


@implementation ShowMapVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	NSArray *locations = [parameters objectAtIndex:1];
	NSDecimalNumber *showCurrentLocation = [parameters objectAtIndex:2];
	NSString *mapType = [parameters objectAtIndex:3];
    //NSLog(@"Locations: %@", locations);
	int numLocations = [locations count];
	if(numLocations == 0){
		return QC_STACK_EXIT;
	}
    QCMapViewController *aMapViewController = [[QCMapViewController alloc] initWithNibName:@"MapView" bundle:nil];
	QuickConnectViewController *theController = [parameters objectAtIndex:0];
	
	[aMapViewController.view setAlpha:0];
	[[[theController webView] superview] addSubview:aMapViewController.view];
	aMapViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	aMapViewController.view.autoresizesSubviews = YES;
    
    //CGRect contentRect = [[theController webView] bounds];
    DeviceWebView *theView = theController.webView;
    //NSLog(@"theView: %@",[theView frame]);
    CGRect frame = theView.frame;
    frame.size.height -= 80;
    frame.origin.y += 40;
    //theView.frame = frame;
    //CGRect contentRect = CGRectMake(-80, 80, 480, 320);
    aMapViewController.view.frame = frame;
    
    CGRect subContentRect = [[theController webView] bounds];
    //NSLog(@"subRect: %@",subContentRect);
    //CGRect subContentRect = CGRectMake(0, 0, 480, 320);
    aMapViewController.view.bounds = subContentRect;
    //aMapViewController.view.bounds = contentRect;
    
	/*
	if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft  
	   || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
		aMapViewController.startedInLandscape = YES;
        //CGRect contentRect = [[[theController webView] superview] bounds];
		CGRect contentRect = CGRectMake(-80, 80, 480, 320);
		//aMapViewController.view.superview.bounds = contentRect;
		
		CGRect subContentRect = CGRectMake(0, 0, 480, 320);
		aMapViewController.view.bounds = subContentRect;
        //aMapViewController.view.bounds = contentRect;
	}
	 */
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[aMapViewController.view setAlpha:1];
	[UIView commitAnimations];
	
	MKMapView *mapView = aMapViewController.mapView;
	if([mapType compare:@"satellite"] == NSOrderedSame){
		mapView.mapType = MKMapTypeSatellite;
	}
	else if([mapType compare:@"hybrid"] == NSOrderedSame){
		mapView.mapType = MKMapTypeHybrid;
	}
	
	//here are some imposibly positive and negative values
	//this allows us to set the greatest and least values
	//correctly
	double greatestLat = -200;
	double leastLat = 200;
	
	double greatestLon = -200;
	double leastLon = 200;
	if([showCurrentLocation intValue] == 1){
		mapView.showsUserLocation=YES;
		/*
		greatestLat = mapView.userLocation.location.coordinate.latitude;
		leastLat = greatestLat;
		greatestLon = mapView.userLocation.location.coordinate.longitude;
		leastLon = greatestLon;
		 */
	}
	
	NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:numLocations];
	
	CLLocationCoordinate2D theCenter;
	MKCoordinateSpan theSpan;
	
	if(numLocations == 1){
		
	}
	else{
		for (int i = 0; i < numLocations; i++) {
			NSArray *location = [locations objectAtIndex:i];
			CLLocationCoordinate2D adder;
			adder.latitude = [[location objectAtIndex:0] doubleValue];
			adder.longitude = [[location objectAtIndex:1] doubleValue];
			if(adder.latitude > greatestLat){
				greatestLat = adder.latitude;
			}
			if(adder.latitude < leastLat){
				leastLat = adder.latitude;
			}
			if(adder.longitude > greatestLon){
				greatestLon = adder.longitude;
			}
			if(adder.longitude < leastLon){
				leastLon = adder.longitude;
			}
			NSString *title;
			NSString *subtitle;
			
			if ([location count] >= 3) {
				title = [NSString stringWithString:[location objectAtIndex:2]];
			}
			else {
				title = [NSString stringWithString:@""];
			}

			if ([location count] >= 4) {
				subtitle = [NSString stringWithString:[location objectAtIndex:3]];
			}
			else {
				subtitle = [NSString stringWithString:@""];
			}
			//create an MKAnnotation
			QCMapAnnotation *annotation = [[QCMapAnnotation alloc] initWithCoordinate:adder andTitle:title andSubtitle:subtitle];
			[annotations addObject:annotation];
			[mapView addAnnotation:annotation];
			
		}
	}
	//aMapViewController.annotations = annotations;
	
	
	
	theCenter.latitude = (greatestLat + leastLat)/2;
	theCenter.longitude = (greatestLon + leastLon)/2;
	
	theSpan.latitudeDelta = fabs(greatestLat - leastLat);
	theSpan.longitudeDelta = fabs(greatestLon - leastLon);
	
	MKCoordinateRegion viewableRegion;
	viewableRegion.center = theCenter;
	viewableRegion.span = theSpan;
	
	[mapView setRegion:viewableRegion animated:YES];
	//aMapViewController.viewableRegion = viewableRegion;
	
	//NSLog(@"annotations: %@",annotations);
	//[mapView addAnnotations:annotations];
	
	return QC_STACK_EXIT;
}

@end
