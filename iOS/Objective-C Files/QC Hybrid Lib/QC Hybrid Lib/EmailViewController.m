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

#import "EmailViewController.h"
#import "SBJSON.h"
#import "DeviceWebView.h"

@implementation EmailViewController

@synthesize passThroughParams;
@synthesize theQCController;

-(void) showEmailModalView {
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self; // <- very important step if you want feedbacks on what the user did with your email view
	
	//NSLog(@"parameters: %@", self.passThroughParams);
	[picker setToRecipients:(self.passThroughParams)[1]];
	// Fill out the email body text
	[picker setSubject:(self.passThroughParams)[2]];
	
	[picker setMessageBody:(self.passThroughParams)[3] isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	[self presentModalViewController:picker animated:YES];

	
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	NSString* resultMessage=@"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
				
		case MFMailComposeResultCancelled:
			resultMessage = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			resultMessage = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			resultMessage = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			resultMessage = @"Result: failed";
			break;
		default:
			resultMessage = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
    
	//[self.theQCController.webView.superview bringSubviewToFront:self.theQCController.webView];
    
	SBJSON *generator = [SBJSON alloc];
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	[retVal addObject:resultMessage];
	[retVal addObject:(self.passThroughParams)[4]];
	NSError *JSONError;
	NSString *dataString = [generator stringWithObject:retVal error:&JSONError];
    //NSLog(@"about to send JSON: %@", dataString);
    
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
    //NSString *jsString = @"alert('hello')";
	//NSLog(@"JSON String: %@",jsString);
	[self.theQCController.webView stringByEvaluatingJavaScriptFromString:jsString];

	//NSLog(@"after");
}

@end
