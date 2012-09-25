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

#import "QCHTTPHandler.h"
#include <sys/socket.h>
#include <CFNetwork/CFNetwork.h>

#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "BatchQCHTTPHandler.h"
#import "DeviceWebView.h"

#pragma mark * Utilities



// A category on NSStream that provides a nice, Objective-C friendly way to create 
// bound pairs of streams.

@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(CFReadStreamRef)inputStreamPtr outputStream:(CFWriteStreamRef)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
@end

@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(CFReadStreamRef)inputStreamPtr outputStream:(CFWriteStreamRef)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;

    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );

    readStream = NULL;
    writeStream = NULL;

	CFStreamCreateBoundPair(
		NULL, 
		((inputStreamPtr  != nil) ? &readStream : NULL),
		((outputStreamPtr != nil) ? &writeStream : NULL), 
		(CFIndex) bufferSize
	);
    
    if (inputStreamPtr != NULL) {
        inputStreamPtr  = readStream;
    }
    if (outputStreamPtr != NULL) {
        outputStreamPtr = writeStream;
    }
}

@end
        
#pragma mark * PostController

enum {
    kPostBufferSize = 32768
};


@interface QCHTTPHandler ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, readonly) BOOL              isSending;
@property (nonatomic, strong)   NSURLConnection * connection;
@property (nonatomic, copy)     NSData *          bodyPrefixData;
@property (nonatomic, strong)   NSInputStream *   fileStream;
@property (nonatomic, copy)     NSData *          bodySuffixData;
@property (nonatomic, strong)   NSOutputStream *  producerStream;
@property (nonatomic, strong)   NSInputStream *   consumerStream;
@property (nonatomic, assign)   const uint8_t *   buffer;
@property (nonatomic, assign)   uint8_t *         bufferOnHeap;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;

@end

@implementation QCHTTPHandler

@synthesize producerStream;
@synthesize consumerStream;


+ (void)releaseObj:(id)obj
    // +++ See comment in -_stopSendWithStatus:.
{
    //[obj release];
}

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)_sendDidStart
{
	
}

- (void)_updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    //NSLog(@"status updated to: %@",statusString);
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

@synthesize connection      = _connection;
@synthesize bodyPrefixData  = _bodyPrefixData;
@synthesize fileStream      = _fileStream;
@synthesize bodySuffixData  = _bodySuffixData;
@synthesize buffer          = _buffer;
@synthesize bufferOnHeap    = _bufferOnHeap;
@synthesize bufferOffset    = _bufferOffset;
@synthesize bufferLimit     = _bufferLimit;
@synthesize doingAGet;
@synthesize batchHandler;
@synthesize shouldOverwrite;
@synthesize fileName;
@synthesize getResult;

@synthesize passThroughParameters;

- (BOOL)isSending
{
    return (self.connection != nil);
}

- (NSString *)_generateBoundaryString
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)startPost:(NSString *)fullFileName asName:(NSString *)asName toURL:(NSString *)URLString withUserName:(NSString *)userName andPassword:(NSString *)pword contentType:(NSString *)mimeType URLParameters:(NSDictionary *)URLParameters
{
    BOOL                    success;
    NSURL *                 url;
    NSMutableURLRequest *   request;
    NSString *              boundaryStr;
    NSString *              bodyPrefixStr;
    NSString *              bodySuffixStr;
    NSNumber *              fileLengthNum;
    unsigned long long      bodyLength;
    
	
	NSArray *fileNamePortions = [fullFileName componentsSeparatedByString:@"."];
	NSString *aFileName = fileNamePortions[0];
	NSString *fileType = fileNamePortions[1];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:aFileName ofType:fileType];
	
	/*
	 * Check to see if the file to be uploaded is part of the application bundle itself.
	 * If it is not, look in the applications document directory.
	 */
	NSFileManager *filemgr = [NSFileManager defaultManager];
	if ([filemgr fileExistsAtPath: filePath ] == NO){
		/*
		 * get the path to the applications document directory and append the name of the file
		 */
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = paths[0];
		filePath = [documentsDirectory stringByAppendingPathComponent:fullFileName];
		/*
		 *  check to see if the file was found in the applications document directory.
		 *  If it is not, abort the upload.
		 */
		if ([filemgr fileExistsAtPath: filePath ] == NO){
			filePath = nil;
		}
	}
	
	if(filePath != nil){
		/*
		 *  convert the URL string into a URL object and check it
		 */
		url = [NSURL URLWithString:URLString];
		success = (url != nil);
	}
	else {
		success = NO;
		NSLog(@"unable to locate file %@ for uploading",fullFileName);
	}


    // If the URL is bogus, let the developer know.  Otherwise kick off the connection.
    if ( ! success) {
        NSLog(@"Invalid URL");
    } else {
        // Determine the MIME type of the file.
        
        if ( [filePath.pathExtension isEqual:@"png"] ) {
            mimeType = @"image/png";
        } 
		else if ( [filePath.pathExtension isEqual:@"mp4"] ) {
            mimeType = @"video/mp4";
        } 
		else if ( [filePath.pathExtension isEqual:@"caf"] ) {
            mimeType = @"audio/x-caf";
        }
        /*
		 * since this is a multi-part message generate a unique identifier for the boundry between parts
		 */
        boundaryStr = [self _generateBoundaryString];
        
		/*
		 *  Each upload consists of a prefix, the file to be uploaded, and the suffix
		 *  The pre and suffix contents are defined in international standards
		 */
        bodyPrefixStr = [NSString stringWithFormat:
            @
            "\r\n"
            "--%@\r\n"
            "Content-Disposition: form-data; name=\"fileContents\"; filename=\"%@\"\r\n"
            "Content-Type: %@\r\n"
            "\r\n",
            boundaryStr,
            asName,
            mimeType
        ];
        
		/*
		 *  The suffix consists of any key value pairs that would usually appear in the URL after the ? as
		 *  well as the standards defined information
		 */

        bodySuffixStr = [NSString stringWithFormat:
            @
            "\r\n"
            "--%@\r\n"
            "Content-Disposition: form-data; name=\"uname\"\r\n"
            "\r\n"
            "%@\r\n"
            "--%@--\r\n" 
            "\r\n"
			 "\r\n"
			 "--%@\r\n"
			 "Content-Disposition: form-data; name=\"pword\"\r\n"
			 "\r\n"
			 "%@\r\n"
            ,
            boundaryStr, 
			userName,
			boundaryStr,
			boundaryStr, 
			pword
        ];
		//add in any url parameters sent
		NSArray *keys = [URLParameters allKeys];
		for(NSString *aKey in keys){
			NSString *aValue = URLParameters[aKey];
			bodySuffixStr = [bodySuffixStr stringByAppendingFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n"
							 "\r\n"
							 "%@\r\n",
							 aKey,
							 aValue
							 ];
		}
		
		bodySuffixStr = [bodySuffixStr stringByAppendingFormat:@"--%@--\r\n\r\n", boundaryStr];
        assert(bodySuffixStr != nil);
		/*
		 *  convert the prefix and the suffix to bytes so that they can be sent in the same byte stream as the file to be uploaded.
		 */
        self.bodyPrefixData = [bodyPrefixStr dataUsingEncoding:NSASCIIStringEncoding];
        
        self.bodySuffixData = [bodySuffixStr dataUsingEncoding:NSASCIIStringEncoding];
        

        fileLengthNum = (NSNumber *) [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL][NSFileSize];
        

        bodyLength =
              (unsigned long long) [self.bodyPrefixData length]
            + [fileLengthNum unsignedLongLongValue]
            + (unsigned long long) [self.bodySuffixData length];
        
        // Open a stream for the file we're going to send.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        /*
		 * since we will be interfering with the data upload we use these
		 * two streams to interupt the flow and insert the prefix and suffix
		 */
        
        [NSStream createBoundInputStream:self->_consumerStream outputStream:self->_producerStream bufferSize:32768];
        
        assert(self.consumerStream != nil);
        assert(self.producerStream != nil);
        
        self.producerStream.delegate = self;
        [self.producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream open];
        
        // Set up our state to send the body prefix first.
        
        self.buffer      = [self.bodyPrefixData bytes];
        self.bufferLimit = [self.bodyPrefixData length];
        
        // Open a connection for the URL, configured to POST the file.

        request = [NSMutableURLRequest requestWithURL:url];
        assert(request != nil);
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBodyStream:self.consumerStream];
        
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundaryStr] forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%llu", bodyLength] forHTTPHeaderField:@"Content-Length"];
        /*
		 * create the connection.  This automatically starts the upload.
		 */
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        
        // Tell the UI we're sending.
        
        [self _sendDidStart];
		
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
}

- (void)startGet:(NSString *)savedFileName fromURL:(NSString *)URLString URLParameters:(NSString *)URLParameters shouldOverwrite:(BOOL)overwriteFlag{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	self.doingAGet = YES;
	self.shouldOverwrite = overwriteFlag;
	self.fileName = savedFileName;
	self.getResult = [NSMutableData dataWithLength:0];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = paths[0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
	//NSLog(@"get writeable path: %@",writablePath);
	if ([fileManager fileExistsAtPath:writablePath] && !self.shouldOverwrite) {
		if (batchHandler == nil) {
			NSArray *resultArray = @[writablePath];
			[self sendResultsBack:resultArray];
		}
		else {
			[batchHandler notifyRequestComplete:writablePath];
		}
		//NSLog(@"exits");
		return;
	}
	
    NSURL *url;
	/*
	 *  convert the URL string into a URL object and check it
	 */
	if ([URLParameters compare: @"url_param_place_holder"] != NSOrderedSame) {
		URLString = [NSString stringWithFormat:@"%@?%@",URLString, URLParameters];
	}
	 url = [NSURL URLWithString:URLString];
	 if (url == nil) {
		 NSLog(@"Invalid URL");
		 return;
	 }
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	//NSLog(@"making request with %@",request);
	/*
	 * create the connection.  This automatically starts the upload.
	 */
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	//NSLog(@"connection made %@",self.connection);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
	
}

- (void)_stopSendWithStatus:(NSString *)statusString
{
    if (self.bufferOnHeap) {
        free(self.bufferOnHeap);
        self.bufferOnHeap = NULL;
    }
    self.buffer = NULL;
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    self.bodyPrefixData = nil;
    if (self.producerStream != nil) {
        self.producerStream.delegate = nil;
        [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream close];
        self.producerStream = nil;
    }
    self.consumerStream = nil;
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bodySuffixData = nil;
	//NSLog(@"stopped with: %@",statusString);
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
    // An NSStream delegate callback that's called when events happen on our 
    // network stream.
{
    #pragma unused(aStream)
    assert(aStream == self.producerStream);

    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
             //NSLog(@"producer stream opened");
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
			//NSLog(@"space available");
            // Check to see if we've run off the end of our buffer.  If we have, 
            // work out the next buffer of data to send.
            
            if (self.bufferOffset == self.bufferLimit) {

                // See if we're transitioning from the prefix to the file data.
                // If so, allocate a file buffer.
                
                if (self.bodyPrefixData != nil) {
                    self.bodyPrefixData = nil;

                    assert(self.bufferOnHeap == NULL);
                    self.bufferOnHeap = malloc(kPostBufferSize);
                    assert(self.bufferOnHeap != NULL);
                    self.buffer = self.bufferOnHeap;
                    
                    self.bufferOffset = 0;
                    self.bufferLimit  = 0;
                }
                
                // If we still have file data to send, read the next chunk. 
                
                if (self.fileStream != nil) {
                    NSInteger   bytesRead;
                    
                    bytesRead = [self.fileStream read:self.bufferOnHeap maxLength:kPostBufferSize];
                    
                    if (bytesRead == -1) {
                        [self _stopSendWithStatus:@"File read error"];
						[self sendResultsBack:@[@"File Error",@"Unable to read file"]];
                    } else if (bytesRead != 0) {
                        self.bufferOffset = 0;
                        self.bufferLimit  = bytesRead;
                    } else {
                        // If we hit the end of the file, transition to sending the 
                        // suffix.

                        [self.fileStream close];
                        self.fileStream = nil;
                        
                        assert(self.bufferOnHeap != NULL);
                        free(self.bufferOnHeap);
                        self.bufferOnHeap = NULL;
                        self.buffer       = [self.bodySuffixData bytes];

                        self.bufferOffset = 0;
                        self.bufferLimit  = [self.bodySuffixData length];
                    }
                }
                
                // If we've failed to produce any more data, we close the stream 
                // to indicate to NSURLConnection that we're all done.  We only do 
                // this if producerStream is still valid to avoid running it in the 
                // file read error case.
                
                if ( (self.bufferOffset == self.bufferLimit) && (self.producerStream != nil) ) {
                    // We set our delegate callback to nil because we don't want to 
                    // be called anymore for this stream.  However, we can't 
                    // remove the stream from the runloop (doing so prevents the 
                    // URL from ever completing) and nor can we nil out our 
                    // stream reference (that causes all sorts of wacky crashes). 
                    //
                    // +++ Need bug numbers for these problems.
                    self.producerStream.delegate = nil;
                    // [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    [self.producerStream close];
                    // self.producerStream = nil;
                }
            }
            
            // Send the next chunk of data in our buffer.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.producerStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                if (bytesWritten <= 0) {
                    [self _stopSendWithStatus:@"Network write error"];
					[self sendResultsBack:@[@"Network write failure",@"Unable to send data"]];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"producer stream error %@", [aStream streamError]);
            [self _stopSendWithStatus:@"Stream open error"];
			[self sendResultsBack:@[@"File Error",@"Unable to open file"]];
        } break;
        case NSStreamEventEndEncountered: {
			[self sendResultsBack:@[@"Networking Error",@"Unable to access upload site.  Please check your device for access and check the URL."]];
        } break;
        default: {
			[self sendResultsBack:@[@"Generic Error",@"Unable to upload file"]];
        } break;
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
    // A delegate method called by the NSURLConnection when the request/response 
    // exchange is complete.  We look at the response to check that the HTTP 
    // status code is 2xx.  If it isn't, we fail right now.
{
	//NSLog(@"got reponse");
	#pragma unused(theConnection)
    assert( [response isKindOfClass:[NSHTTPURLResponse class]] );
    NSHTTPURLResponse * httpResponse;
    
    httpResponse = (NSHTTPURLResponse *) response;
	//NSLog(@"response code: %@",[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]);
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self _stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
		
		[self sendResultsBack:@[@"HTTP Error",
							   [NSString stringWithFormat:@"HTTP Error: %zd %@",(ssize_t) httpResponse.statusCode,[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]]]];
    } else {
        //NSLog(@"Response OK.");
		//NSLog(@"headers: %@",[httpResponse allHeaderFields]); 
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
    // A delegate method called by the NSURLConnection as data arrives.
{
	//NSLog(@"got data");
    #pragma unused(theConnection)
	if (self.doingAGet) {
		[self.getResult appendData:data];
	}
	else{
		NSString* results = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		//NSLog(@"the result is: %@",results);
		
		//NSLog(@"parameters: %@",self.passThroughParameters);
		NSArray *resultArray = @[@"Upload Complete",results];
		[self sendResultsBack:resultArray];
	}
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
    // A delegate method called by the NSURLConnection if the connection fails. 
    // We shut down the connection and display the failure.  Production quality code 
    // would either display or log the actual error.
{
	//NSLog(@"connection error: %@",error);
	self.doingAGet = NO;
    #pragma unused(theConnection)
    
    [self _stopSendWithStatus:@"Connection failed"];
	NSArray *results = @[@"Connection Failed",[error localizedFailureReason]];
	[self sendResultsBack:results];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
    // A delegate method called by the NSURLConnection when the connection has been 
    // done successfully.
{
	if (self.doingAGet) {
		//NSLog(@"done getting");
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = paths[0];
		NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
		//NSLog(@"path: %@",writablePath);
		//NSLog(@"%@ %@",self.fileName, self.getResult);
		[self.getResult writeToFile:writablePath atomically:YES];
		if (batchHandler == nil) {
			NSArray *resultArray = @[writablePath];
			[self sendResultsBack:resultArray];
		}
		else {
			[batchHandler notifyRequestComplete:writablePath];
		}

		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
	}
	
	
	
    #pragma unused(theConnection)
    
    [self _stopSendWithStatus:nil];
	self.doingAGet = NO;
}

- (void) sendResultsBack:(NSArray*)results{
	
	
	[self performSelectorOnMainThread:@selector(sendResultsToWebView:)
						   withObject:results
						waitUntilDone:YES];
}
- (void) sendResultsToWebView:(NSArray*)results{	
	NSMutableArray *retVal = [[NSMutableArray alloc] init];
	//NSLog(@"results: %@",results);
	[retVal addObject:results];
	[retVal addObject:(self.passThroughParameters)[8]];
    NSError *genError;
	SBJSON *generator = [SBJSON alloc];
	NSString *dataString = [generator stringWithObject:retVal error:&genError];
	//NSLog(@"error: %@",error);
    //NSLog(@"about to send JSON: %@", dataString);
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
	NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
	//NSLog(@"pass through %@",passThroughParameters);
    QuickConnectViewController *controller = passThroughParameters[0];
	[controller.webView stringByEvaluatingJavaScriptFromString:jsString];
}


- (void)dealloc
{
    [self _stopSendWithStatus:@"Stopped"];
}

@end
