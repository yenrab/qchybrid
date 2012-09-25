//
//  QCPickerDelegate.h
//  30Project
//
//  Created by lee on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "QuickConnectViewController.h"


@interface QCPickerDelegate : NSObject <ABPeoplePickerNavigationControllerDelegate>{
	NSArray *storedParams;
	QuickConnectViewController *theController;
}
@property (nonatomic, strong) NSArray *storedParams;
@property (nonatomic, strong) QuickConnectViewController *theController;

@end
