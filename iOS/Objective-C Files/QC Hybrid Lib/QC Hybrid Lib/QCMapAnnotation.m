//
//  QCMapAnnotation.m
//  MapExample
//
//  Created by lee on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCMapAnnotation.h"


@implementation QCMapAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
	return subtitle;
}

- (NSString *)title{
	return title;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString*)aTitle andSubtitle:(NSString*)aSubtitle{
	coordinate = aCoordinate;
	title = aTitle;
	subtitle = aSubtitle;
	return self;
}

@end
