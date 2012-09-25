//
//  QCMapAnnotation.h
//  MapExample
//
//  Created by lee on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface QCMapAnnotation : NSObject <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString*)aTitle andSubtitle:(NSString*)aSubtitle;
- (NSString *)title;
- (NSString *)subtitle;

@end
