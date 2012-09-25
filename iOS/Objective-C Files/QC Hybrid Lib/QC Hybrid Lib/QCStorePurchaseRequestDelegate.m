//
//  QCStorePurchaseRequestDelegate.m
//  QCLib
//
//  Created by lee on 3/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "QCStorePurchaseRequestDelegate.h"
#import "SBJSON.h"
#import "DeviceWebView.h"


@implementation QCStorePurchaseRequestDelegate

@synthesize viewController;

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	int numTransactions = [transactions count];
	for (int i = 0; i < numTransactions; i++) {
		SKPaymentTransaction *aTransaction = transactions[i];
		NSMutableArray *retVal = [[NSMutableArray alloc] init];
		//remove compled transactions
		if (aTransaction.transactionState != SKPaymentTransactionStatePurchasing) {
			[queue finishTransaction:aTransaction];
		}
		
		if(aTransaction.transactionState == SKPaymentTransactionStatePurchased
		   || aTransaction.transactionState == SKPaymentTransactionStateRestored){
			[retVal addObject:@"purchaseSuccess"];
			[retVal addObject:aTransaction.payment.productIdentifier];
			 [retVal addObject:@(aTransaction.payment.quantity)];
		}
		else if(aTransaction.transactionState == SKPaymentTransactionStateFailed){
			[retVal addObject:@"purchaseFailure"];
			[retVal addObject:[[aTransaction error] localizedDescription]];
			 [retVal addObject:[[aTransaction error] localizedFailureReason]];
		}
		else {
			//may still be processing
			continue;
		}
		
		NSError *error;
		SBJSON *generator = [SBJSON alloc];
		NSString *dataString = [generator stringWithObject:retVal error:&error];
		//NSLog(@"error: %@",error);
		//NSLog(@"about to send JSON: %@", dataString);
		dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
		dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
			  
		NSString *jsString = [[NSString alloc] initWithFormat:@"handleJSONRequest('purchaseComplete', '%@')", dataString];
		//NSLog(@"%@",jsString);
		
		
		[self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];

	}
}
@end
