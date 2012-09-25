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

#import <AVFoundation/AVFoundation.h>

#import "PlayAudioVCO.h"
#import "QuickConnectViewController.h"


@implementation PlayAudioVCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	NSString *flag = [parameters objectAtIndex:2];
	QuickConnectViewController *aController = [parameters objectAtIndex:0];
	NSString *fileName = [parameters objectAtIndex:1];
    NSInteger numLoops = [[parameters objectAtIndex:3] integerValue];
    
    AVAudioPlayer *audioPlayer = [aController.audioPlayers objectForKey:fileName];
    if(!audioPlayer){
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *soundFilePath = [docsDir
                                   stringByAppendingPathComponent:fileName];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] 
                       initWithContentsOfURL:soundFileURL                                    
                       error:&error];
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            return QC_STACK_EXIT;
        }
    }
    
    if([flag isEqualToString:@"start"]){
        audioPlayer.numberOfLoops = numLoops;
        [audioPlayer play];
        
    }
    else if([flag isEqualToString:@"pause"]){
        [audioPlayer pause];
    }
    else{
        [audioPlayer stop];
        [aController.audioPlayers removeObjectForKey:fileName];
    }

    /*
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	NSString *flag = [parameters objectAtIndex:2];
	QuickConnectViewController *aController = [parameters objectAtIndex:0];
	NSString *fileName = [parameters objectAtIndex:1];
	NSArray *split = [fileName componentsSeparatedByString:@"."];
    if([flag compare:@"start"] == NSOrderedSame){
		NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:[split objectAtIndex:0] ofType:[split objectAtIndex:1]];
		if(audioFilePath == nil){
			//recorded file.
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			audioFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
		}
        
		if([aController.audioPlayers objectForKey:fileName] == nil){
			//NSLog(@" not already playing");
			AVAudioPlayer *audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL];
			
			//NSLog(@"loop count: %@", parameters);
			NSInteger numLoops = [[parameters objectAtIndex:3] integerValue];
			if(numLoops != 0){
				audioPlayer.numberOfLoops = numLoops;
			}
			audioPlayer.volume = 1.0;
			[aController.audioPlayers setObject:audioPlayer forKey:fileName];
			
		}	
        //NSLog(@"about to play");
		
		BOOL plays = [[aController.audioPlayers objectForKey:fileName] play];
		if(plays){
			//NSLog(@"done playing");
		}
		else{
			//NSLog(@"play failed");
		}
	}
	else if([flag compare:@"pause"] == NSOrderedSame){
		//NSLog(@"pausing");
		[[aController.audioPlayers objectForKey:fileName] pause];
		//NSLog(@"paused");
	}
	else{
		[[aController.audioPlayers objectForKey:fileName] stop];
		[aController.audioPlayers removeObjectForKey:fileName];
	}
    //NSLog(@"done with PlayAudioVCO");
     */
    return QC_STACK_EXIT;
}
@end
