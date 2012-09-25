//
//  MakePurchaseBCO.m
//  QCLib
//
//  Created by lee on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MakePurchaseBCO.h"
#import <StoreKit/StoreKit.h>


@implementation MakePurchaseBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    
	SKMutablePayment *payment = [SKMutablePayment paymentWithProductIdentifier:[parameters objectAtIndex:1]];
	payment.quantity = (NSInteger)[parameters objectAtIndex:2];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	return QC_STACK_EXIT;
}
@end
