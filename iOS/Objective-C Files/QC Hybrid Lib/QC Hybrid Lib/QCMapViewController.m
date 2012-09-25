//
//  QCMapViewDelegate.m
//  MapExample
//
//  Created by lee on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCMapViewController.h"
#import "QCMapAnnotation.h"

#import <CoreLocation/CoreLocation.h>

@interface QCMapViewController (Private)

	-(CLLocationCoordinate2D) addressLocation;

@end


@implementation QCMapViewController
@synthesize mapView;
@synthesize fullView;
@synthesize annotations;
@synthesize viewableRegion;
@synthesize startedInLandscape;
/*
-(void)viewDidLoad{
	[mapView setRegion:viewableRegion animated:YES];
	//NSLog(@"adding annotations %@", annotations);
	[mapView addAnnotations:annotations];
}
 */

- (IBAction) doneSelected:(id)sender{
	//NSLog(@"done");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[fullView setAlpha:0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeMapFromView:)];
	[UIView commitAnimations];
}
 -(void) removeMapFromView{
	 [fullView removeFromSuperview];
 }
- (IBAction) goSelected:(id)sender{
	//NSLog(@"going");
	//Hide the keypad
	[addressField resignFirstResponder];
	NSString *searchValue = [NSString stringWithString:addressField.text];

	//NSLog(@"%@",searchValue);
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	CLLocationCoordinate2D location = [self addressLocation];
	region.span=span;
	region.center=location;

	QCMapAnnotation *addAnnotation = [[QCMapAnnotation alloc] initWithCoordinate:location andTitle:searchValue andSubtitle:@""];
	[mapView addAnnotation:addAnnotation];
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
}

-(CLLocationCoordinate2D) addressLocation {
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
						   [addressField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
	NSArray *listItems = [locationString componentsSeparatedByString:@","];
	
	CLLocationCoordinate2D location;
	location.latitude = 0.0;
	location.longitude = 0.0;
	
	if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
		location.latitude = [[listItems objectAtIndex:2] doubleValue];
		location.longitude = [[listItems objectAtIndex:3] doubleValue];
	}
	else {
		//Show error
	}
	return location;
}


@end
