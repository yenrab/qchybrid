//
//  QCMapViewDelegate.h
//  MapExample
//
//  Created by lee on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface QCMapViewController : UIViewController <MKMapViewDelegate>{
	IBOutlet UITextField *addressField;
	IBOutlet UIBarButtonItem *goButton;
	IBOutlet UIBarButtonItem *doneButton;
	IBOutlet UIView *fullView;
	IBOutlet MKMapView *mapView;
	NSArray *annotations;
	MKCoordinateRegion viewableRegion;
	BOOL startedInLandscape;
}
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIView *fullView;
@property (nonatomic, retain) NSArray *annotations;
@property (nonatomic) MKCoordinateRegion viewableRegion;
@property (readwrite) BOOL startedInLandscape;

- (IBAction) doneSelected:(id)sender;
- (IBAction) goSelected:(id)sender;

@end
