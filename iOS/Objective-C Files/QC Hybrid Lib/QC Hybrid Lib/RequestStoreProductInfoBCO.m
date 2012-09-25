//
//  RequestStoreProductInfoBCO.m
//  QCLib
//
//  Created by lee on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RequestStoreProductInfoBCO.h"
#import "QuickConnectViewController.h"
#import "QCStoreRequestDelegate.h"

#import <StoreKit/StoreKit.h>


@implementation RequestStoreProductInfoBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
	
	NSArray *identifierArray = parameters[1];
	
    SKProductsRequest *aRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:identifierArray]];
	
	QCStoreRequestDelegate *theDelegate = [[QCStoreRequestDelegate alloc] initWithPassthroughParameters:parameters];
	
	aRequest.delegate = theDelegate;
	[aRequest start];
	
	return QC_STACK_EXIT;
}
@end
