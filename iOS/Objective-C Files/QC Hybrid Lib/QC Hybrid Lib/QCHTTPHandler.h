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
#import <Foundation/Foundation.h>
@class QuickConnectViewController;
@class BatchQCHTTPHandler;

@interface QCHTTPHandler : NSObject <NSStreamDelegate>
{
    UITextField *               _urlText;
    UILabel *                   _statusLabel;
    UIActivityIndicatorView *   _activityIndicator;
    UIBarButtonItem *           _cancelButton;
    
    NSURLConnection *           _connection;
    NSData *                    _bodyPrefixData;
    NSInputStream *             _fileStream;
    NSData *                    _bodySuffixData;
    CFWriteStreamRef            _producerStream;
    CFReadStreamRef             _consumerStream;
    const uint8_t *             _buffer;
    uint8_t *                   _bufferOnHeap;
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
	
	BOOL						doingAGet;
	NSString					*fileName;
	NSArray						*passThroughParameters;
	NSMutableData				*getResult;
	BatchQCHTTPHandler			*batchHandler;
	BOOL						shouldOverwrite;
}
@property (nonatomic, strong) NSArray *passThroughParameters;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSMutableData *getResult;
@property (readwrite) BOOL doingAGet;
@property (nonatomic, strong) BatchQCHTTPHandler *batchHandler;
@property (readwrite) BOOL shouldOverwrite;

- (void)startPost:(NSString *)fullFileName asName:(NSString *)asName toURL:(NSString *)URLString withUserName:(NSString *)userName andPassword:(NSString *)pword contentType:(NSString *)mimeType URLParameters:(NSDictionary *)URLParameters;
- (void)startGet:(NSString *)savedFileName fromURL:(NSString *)URLString URLParameters:(NSString *)URLParameters shouldOverwrite:(BOOL)overwriteFlag;
- (void) sendResultsBack:(NSArray*)results;
@end
