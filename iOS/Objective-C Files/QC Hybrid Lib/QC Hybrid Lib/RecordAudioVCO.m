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


#include <AudioToolbox/AudioToolbox.h>

#import "RecordAudioVCO.h"
#import "QuickConnectViewController.h"



@implementation RecordAudioVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    QuickConnectViewController *aController = [parameters objectAtIndex:0];
    NSString *fileName = [parameters objectAtIndex:1];
    
    if(!aController.audioRecorder){
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *soundFilePath = [docsDir
                                   stringByAppendingPathComponent:fileName];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        NSDictionary *recordSettings = [NSDictionary 
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16], 
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2], 
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0], 
                                        AVSampleRateKey,
                                        nil];
        
        NSError *error = nil;
        
        aController.audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:soundFileURL
                         settings:recordSettings
                         error:&error];
        
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            return QC_STACK_EXIT;
        }
    }
    [aController.audioRecorder prepareToRecord];
    
    NSString *flag = [parameters objectAtIndex:2];
    if([flag compare:@"start"] == NSOrderedSame){
        if (!aController.audioRecorder.recording)
        {
            [aController.audioRecorder record];
        }

    }
    else{
        if (aController.audioRecorder.recording)
        {
            [aController.audioRecorder stop];
            aController.audioRecorder = nil;
        }

    }

    /*
    // before instantiating the recording audio queue object, 
    //	set the audio session category
    UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    
    QuickConnectViewController *aController = [parameters objectAtIndex:0];
    NSString *flag = [parameters objectAtIndex:2];
    if([flag compare:@"start"] == NSOrderedSame){
        NSString *fileName = [parameters objectAtIndex:1];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *audioFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        //NSLog(@"audio file path: %@", audioFilePath);
        NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
        //NSLog(@"audio url: %@", audioFileURL);
        
        AudioRecorder *aRecorder = [[AudioRecorder alloc] initWithURL:audioFileURL];
        aController.audioRecorder = aRecorder;
       
        
        AudioSessionSetActive (true);
        [aController.audioRecorder record];
    }
    else{
        //NSLog(@"Stopping recording.");
        
        //deactivate the audio session
        AudioSessionSetActive (false);
    }
    //NSLog(@"done with RecordAudioVCO");
     */
    return QC_STACK_EXIT;
}
@end
