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

#import "DatePickerVCO.h"
#import "DeviceWebView.h"
#import "QuickConnectViewController.h"


@implementation DatePickerVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];

    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSString *type = [(NSString*)[parameters objectAtIndex:1] lowercaseString];
    if([type compare:@"datetime"] == NSOrderedSame){
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    else if([type compare:@"date"] == NSOrderedSame){
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    

    //use the picker's optimum size
    //and position it at the bottom of the web view
    
    CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
    NSInteger barHeight= 34.0;

    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    datePicker.frame = CGRectMake(	0.0,
                                   screenFrame.size.height - barHeight - pickerSize.height,
                                   pickerSize.width,
                                   pickerSize.height + barHeight);
    [datePicker setBackgroundColor:[UIColor blackColor]];
    
	QuickConnectViewController *controller = (QuickConnectViewController*)[parameters objectAtIndex:0];
	DeviceWebView *webView = [controller webView];
    [webView setPicker:datePicker];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(0.0, pickerSize.height, 50.0, barHeight);
    [doneButton addTarget:controller action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    
    [datePicker addSubview:doneButton];
    
    [webView addSubview:datePicker];
    
    return QC_STACK_EXIT;
}

@end
