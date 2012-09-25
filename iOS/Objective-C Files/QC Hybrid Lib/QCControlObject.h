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


#import <UIKit/UIKit.h>

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (false)
#endif

#define QC_STACK_CONTINUE      (BOOL)1            
#define QC_STACK_EXIT          (BOOL)0

/**
 The QCControlObject class is the class from which all Control Objects you create for your stacks inherit.  All ValCO, BCO, VCO, and ECO objects must inherit from this class in order to be processed correctly.
 
 <br/><br/>Your Control Object that inherits from this class must override the handleIt: method of this class.  Your class' handleIt: method must contain all of the functionality for that particular defined behavior.  A basic rule to follow is "Each Control Object should do one thing, do it efficiently, and do it well".  This is where the modularity of your application is achieved.
 
 */

@interface QCControlObject : NSObject {

}
/**
 The handleIt: method to override
 @param parameters The <b>NSMutableDictionary</b> instance passed into the QuickConnect handleRequest:withParameters: method by your application
 @returns <b>QC_STACK_CONTINUE</b> if no errors or exceptions happened within the handleIt: call or <b>QC_STACK_EXIT</b> if they did.
 */
+ (BOOL) handleIt:(NSMutableDictionary*) parameters;
@end
