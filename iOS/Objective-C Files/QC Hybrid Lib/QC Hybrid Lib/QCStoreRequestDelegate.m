/*
 Copyright (c) 2008, 2009 Lee Barney
 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation the 
 rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the Software 
 is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be 
 included in all copies or substantial portions of the Software.
 
 
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "QCStoreRequestDelegate.h"
#import "SBJSON.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"

#import <StoreKit/StoreKit.h>

@implementation QCStoreRequestDelegate

@synthesize passThroughParameters;

- (QCStoreRequestDelegate*)initWithPassthroughParameters:(NSArray *)params{
	passThroughParameters = params;\
	return self;
}

//StoreKit response to a request
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	
	int numProducts = [response.products count];
	NSMutableArray *productDescriptionArray = [NSMutableArray arrayWithCapacity:numProducts];
	for (int i = 0; i < numProducts; i++) {
		SKProduct *aProduct = [response.products objectAtIndex:i];
		NSMutableArray *aProductDescription = [NSMutableArray arrayWithCapacity:5];
		[aProductDescription addObject:aProduct.productIdentifier];
		[aProductDescription addObject:aProduct.localizedTitle];
		[aProductDescription addObject:aProduct.localizedDescription];
		[aProductDescription addObject:aProduct.price];
		[aProductDescription addObject:aProduct.priceLocale.localeIdentifier];
		
		
		[productDescriptionArray addObject:aProductDescription];
	}
	
	[retVal addObject:productDescriptionArray];
	//NSLog(@"paramArray: %@",self.passThroughParameters);
    //add the execution key in to send them back to the JavaScript
    [retVal addObject:[[self.passThroughParameters objectAtIndex:6] objectAtIndex:0]];
	//NSLog(@"returning results from QCStoreRequestDelegate: %@",retVal);
	
	
	
	NSError *error;
	SBJSON *generator = [SBJSON alloc];
	NSString *dataString = [generator stringWithObject:retVal error:&error];
	//NSLog(@"error: %@",error);
    //NSLog(@"about to send JSON: %@", dataString);
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
	
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"%@",jsString);
	
	QuickConnectViewController *controller = [self.passThroughParameters objectAtIndex:0];
	[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
	
}


@end
