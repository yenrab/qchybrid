/*
 Copyright (c) 2012 Lee Barney
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

#import "InterlayerMessageSystem.h"
#import "QuickConnectViewController.h"
#import "QuickConnect.h"
#import "DeviceWebView.h"

@implementation InterlayerMessageSystem

@synthesize theQCViewController;


- (id) initWithHandler:(QuickConnectViewController*)theController{
    self = [super init];
    if (self) {
        self.theQCViewController = theController;
    }
    
    return self;
}

-(void)main {
    if(self.isCancelled){
       return; 
    }
    
    while (YES) {
        if(self.isCancelled){
          return;  
        }
        [NSThread sleepForTimeInterval:0.3];
        //this string will hold the 'return value'.  i.e. the JSON string after it is retrieved.
        NSMutableString *theQueueAsJSON = [NSMutableString stringWithCapacity:1];
        //NSLog(@"json: %@",theQueueAsJSON);
        [self performSelectorOnMainThread:@selector(getJSONStringFromWebView:) withObject:theQueueAsJSON waitUntilDone:YES];
        /*
         *  Check to see if class standard JSON class exists.  If not then use SBJSON.
         */
        NSError *error = nil;
        NSArray *theQueue = (NSArray*)[NSJSONSerialization JSONObjectWithData:[theQueueAsJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"got JSON error: %@",[error localizedDescription]);
            continue;
        }
        for (NSMutableDictionary *aRequest in theQueue) {
            NSString *command = aRequest[@"cmd"];
            NSMutableArray *parameters = aRequest[@"parameters"];
            [parameters insertObject:theQCViewController atIndex:0];//this is here for backwards compatibility.  See about removing it.
            //send the request as the paramters since it has the command in it.  That is needed later in the libraries.
            [theQCViewController.theHandler handleRequest:command withParameters:aRequest];
        }
    }
    
}

- (void) getJSONStringFromWebView:(NSMutableString*)jsonStringHolder{
    NSString *queueAsJSON = [theQCViewController.webView stringByEvaluatingJavaScriptFromString:@"qc.messageQueueAsJSON()"];
    [jsonStringHolder setString:queueAsJSON];
}

/*
 *  sendCompletionRequest should only be called from within a VCO.  Do NOT give into the temptation to send it to the main UI thread yourself from some other type of object.
 */
- (BOOL) sendCompletionRequest:(NSArray*)dataToSend{
    /*
     *  Still need to check to see if standard JSON class exists.  If not then use SBJSON.
     */
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
    if (error) {
        return NO;
    }
    NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@",dataString);
    /*
     *  Are these really needed????? See about removing them.
     */
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    //dataString = [dataString stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"NSFile" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *jsString = [[NSString alloc] initWithFormat:@"handleRequestCompletionFromNative('%@')", dataString];
    //NSLog(@"jsString: %@",jsString);
    [theQCViewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    return YES;
}

- (BOOL) pushRequestDataWithoutStack:(NSArray*)dataToSend{
    
    return YES;
}

/*
- (NSDictionary*)getLocalStorage:(NSError**)error{
    NSLog(@"getting");
    NSString *executableString = @"qc.getLocalStorageAsJSON()";
    NSString *localStorageJSON = [theQCViewController.webView stringByEvaluatingJavaScriptFromString:executableString];
    NSData *localStorageData = [localStorageJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:localStorageData options:NSUTF8StringEncoding error:&jsonError];
    if(jsonObject && !jsonError){
        NSLog(@"get worked: %@",jsonObject);
        error = nil;
        return (NSDictionary*)jsonObject;
    }
    else{
        NSLog(@"failed: %@",jsonError);
        error = &jsonError;
        return nil;
    }
}
 */

- (BOOL)setLocalStorage:(NSDictionary*)theStorageDictionary{
    NSLog(@"setting");
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theStorageDictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString && !error) {
        NSString *executableString = [NSString stringWithFormat:@"localStorage = %@ ;",jsonString];
        NSLog(@"about to set local storage: %@", executableString);
        [theQCViewController.webView stringByEvaluatingJavaScriptFromString:executableString];
        return YES;
    }
    return NO;
}

@end
