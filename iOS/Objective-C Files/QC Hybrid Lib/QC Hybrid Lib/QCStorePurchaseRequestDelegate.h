//
//  QCStorePurchaseRequestDelegate.h
//  QCLib
//
//  Created by lee on 3/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "QuickConnectViewController.h"


@interface QCStorePurchaseRequestDelegate : NSObject <SKPaymentTransactionObserver>{
	QuickConnectViewController *viewController;
}
@property (nonatomic, strong) QuickConnectViewController *viewController;
@end
