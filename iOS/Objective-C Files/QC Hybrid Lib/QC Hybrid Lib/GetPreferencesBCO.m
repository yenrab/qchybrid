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

#import "GetPreferencesBCO.h"
#import "QuickConnectViewController.h"


@implementation GetPreferencesBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"default domain names array %@", [defaults persistentDomainNames]);
    id results = nil;
    if([[defaults persistentDomainNames] count] < 3){
            results = @"Preference values are not accessable from code until they have been viewed in the Settings app.";
    }
    else{
        NSDictionary *allPrefs = [defaults persistentDomainForName:[defaults persistentDomainNames][2]];
        results = allPrefs;
        //NSLog(@"preferences map: %@", allPrefs);
        NSString * prefName = parameters[1];
        //NSLog(@"preference name wanted: %@", prefName);
        if([prefName compare:@"all"] != NSOrderedSame){
            results = allPrefs[prefName];
            if(results == nil){
                results = [NSString stringWithFormat:@"No such preference as %@",prefName];
            }
        }
    }
    dictionary[@"preferences"] = results?results : @"No preferences";
    return QC_STACK_CONTINUE;
}
@end
