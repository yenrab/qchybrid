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

#import "FileUploadBCO.h"
#import "QCHTTPHandler.h"


@implementation FileUploadBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	//NSLog(@"uploading file: %@",parameters);
    NSString *fileName = [parameters objectAtIndex:1];
	NSString *URLString = [parameters objectAtIndex:2];
	NSString *userName = [parameters objectAtIndex:3];
	NSString *pword = [parameters objectAtIndex:4];
	NSString *mimeType = [parameters objectAtIndex:5];
	NSDictionary *URLParameters = [parameters objectAtIndex:6];
	NSString *asName = [parameters objectAtIndex:7];
	if ([asName compare:@"No_Ne"] == NSOrderedSame) {
		asName = fileName;
	}
	QCHTTPHandler *postHandler = [[QCHTTPHandler alloc] init];
	
	postHandler.passThroughParameters = parameters;
	[postHandler startPost:fileName asName:asName toURL:URLString withUserName:userName andPassword:pword contentType:mimeType URLParameters:URLParameters];
	//NSLog(@"startPost called");
	return QC_STACK_EXIT;
}
@end
