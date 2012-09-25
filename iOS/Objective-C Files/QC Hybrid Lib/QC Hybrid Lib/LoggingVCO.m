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

#import "LoggingVCO.h"


@implementation LoggingVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    //NSLog(@"logging: %@",dictionary);
    
    NSArray *parameters = dictionary[@"parameters"];
    //NSLog(@"parameters: %@",parameters);
	NSString *message =@"ERROR: A Message was to be logged but an error occured preparing it.\n\n\n";
	if([parameters count] >= 1){
        //NSLog(@"parameter: %@",[parameters objectAtIndex:1]);
		//message = [[parameters objectAtIndex:1] stringByReplacingOccurrencesOfString:@"_@_"  withString:@"\n\t\t"];
        message = parameters[1];
	}
	NSLog(@"JavaScriptMessage: %@",message);
	return QC_STACK_EXIT;
}

@end