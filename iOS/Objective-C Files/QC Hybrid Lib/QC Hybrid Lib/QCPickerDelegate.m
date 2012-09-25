//
//  QCPickerDelegate.m
//  30Project
//
//  Created by lee on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCPickerDelegate.h"
#import "QuickConnect.h"


@implementation QCPickerDelegate

@synthesize storedParams;
@synthesize theController;

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [theController dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	NSMutableArray *paramsToPass = [NSMutableArray arrayWithArray:storedParams];
    //NSMutableArray *paramsToPass = [[NSMutableArray alloc] initWithCapacity:2];
    [paramsToPass addObject:(id)CFBridgingRelease(person)];
    [theController dismissModalViewControllerAnimated:YES];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:paramsToPass forKey:@"parameters"];
    [theController.theHandler handleRequest:@"sendPersonPickResults" withParameters:parameters];
	
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}


@end
