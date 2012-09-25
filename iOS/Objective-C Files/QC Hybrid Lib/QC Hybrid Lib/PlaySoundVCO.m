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


#import "PlaySoundVCO.h"
#import "AudioToolbox/AudioToolbox.h"
#import "QuickConnectViewController.h"

@implementation PlaySoundVCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
	//NSLog(@"playing sound");
	
	SystemSoundID aSound = [((NSNumber*)parameters[1]) intValue];
	if(aSound == -1){
		aSound = kSystemSoundID_Vibrate;
	}
    else{
        NSString *fullFileName = parameters[2];
        NSArray *fileNamePortions = [fullFileName componentsSeparatedByString:@"."];
        NSString *fileName = fileNamePortions[0];
        NSString *fileType = fileNamePortions[1];
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        
        NSURL *url = [NSURL fileURLWithPath:soundFile];
        //if the audio file is takes longer than 5 seconds to play you will get a -1500 error
        AudioServicesCreateSystemSoundID( (CFURLRef) CFBridgingRetain(url), &aSound );
    }
	AudioServicesPlaySystemSound(aSound);
    //NSLog(@"done playing sound: %i", aSound);
	return QC_STACK_EXIT;
}

@end

