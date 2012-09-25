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

#import "HideFooterVCO.h"
#import "QuickConnectViewController.h"
#import "DeviceWebView.h"


@implementation HideFooterVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    //NSLog(@"hiding footer");
    QuickConnectViewController *controller = [parameters objectAtIndex:0];
	//NSLog(@"shown footers: %@",controller.shownFooters);
	NSString *footerId = [parameters objectAtIndex:1];
	//see if it is still being shown
	if([controller.shownFooters objectForKey:footerId] != nil){
		UIToolbar *barToHide = [[controller nativeFooters] objectForKey:footerId];
		
		Boolean rotating = NO;
		if([parameters count] == 3){
			rotating = YES;
		}
		
		CGRect toolbarFrame = [barToHide frame];
		double toolbarHeight = toolbarFrame.size.height;
		/*toolbarFrame.origin.y += toolbarHeight;
		 //NSLog(@"toobarFrame yloc %i",toolbarFrame.origin.y);
		 */
		CGRect mainViewFrame = controller.view.frame;
		CGRect adjustedBarFrame = CGRectMake(mainViewFrame.origin.x,
											 mainViewFrame.size.height,
											 mainViewFrame.size.width,
											 toolbarHeight);
		
		CGRect webViewFrame = [[controller webView] frame];
		webViewFrame.size.height += toolbarHeight;
		
		
		//animate the change
		if(!rotating){
			//NSLog(@"animated delete");
			[controller.shownFooters removeObjectForKey:footerId];
			//NSLog(@"modified shownFooters: %@)",controller.shownFooters);
			[UIWebView beginAnimations:nil context: nil];
			[UIWebView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIWebView setAnimationDuration:.25];
		}
		else{
			[barToHide removeFromSuperview];
		}
		[[controller webView] setFrame:webViewFrame];
		[barToHide setFrame:adjustedBarFrame];
		if(!rotating){
			[UIWebView commitAnimations];
		}
	}
	return QC_STACK_EXIT;
}
@end
