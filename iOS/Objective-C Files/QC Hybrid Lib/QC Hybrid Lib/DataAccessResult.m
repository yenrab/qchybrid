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

#import "DataAccessResult.h"
#import "SBJSON.h"
#import "QuickConnectViewController.h"


@implementation DataAccessResult

@synthesize fieldNames;
@synthesize columnTypes;
@synthesize results;
@synthesize errorDescription;
@synthesize rowsAffected;
@synthesize insertedID;

- (NSDictionary*) asJSONObject{
    NSMutableDictionary *convertedObject = [NSMutableDictionary dictionaryWithCapacity:6];
    [convertedObject setObject:self.fieldNames != nil ? self.fieldNames : [NSArray array] forKey:@"fieldNames"];
    [convertedObject setObject:self.columnTypes != nil ? self.columnTypes : [NSArray array] forKey:@"columnTypes"];
    [convertedObject setObject:self.results forKey:@"results"];
    [convertedObject setObject:self.errorDescription forKey:@"errorDescription"];
    [convertedObject setObject:[NSNumber numberWithInt:self.rowsAffected] forKey:@"rowsAffected"];
    [convertedObject setObject:[NSNumber numberWithInt:self.insertedID] forKey:@"insertedID"];
    return convertedObject;
}

- (NSString*) JSONStringify{
    int numRows = [results count];
    //NSLog(@"row count %i",numRows);
    for(int i = 0; i < numRows; i++){
        NSMutableArray *row = [results objectAtIndex:i];
        int numRecords = [row count];
        //NSLog(@"record count %i",numRecords);
        for(int j = 0; j < numRecords; j++){
            NSObject *aField = [row objectAtIndex:j];
            if([aField respondsToSelector:@selector(rangeOfString:)]){
                NSString * aString = (NSString*)aField;
                aString = [aString stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
                aString = [aString stringByReplacingOccurrencesOfString:@"{" withString:@"&nlbrace;"];
                aString = [aString stringByReplacingOccurrencesOfString:@"}" withString:@"&nrbrace;"];
                aString = [aString stringByReplacingOccurrencesOfString:@"[" withString:@"&nlbracket;"];
                aString = [aString stringByReplacingOccurrencesOfString:@"]" withString:@"&nrbracket;"];
                aString = [aString stringByReplacingOccurrencesOfString:@"\"" withString:@"&nquote;"];
                //NSLog(@"modified string: %@",aString);
                [row replaceObjectAtIndex:j withObject:aString];
            }
        }
    }
    SBJSON *generator = [SBJSON alloc];
	NSError *error;
	NSString *dataString = [generator stringWithObject:self.results error:&error];
	NSString *fieldNamesString = fieldNames ? [generator stringWithObject:fieldNames error:&error] : @"[]";
    NSString *result = [NSString stringWithFormat:@"{\"data\":%@,\"errorMessage\":\"%@\",\"numRowsFetched\":%d,\"insertedID\":%d,\"numResultFields\":%d,\"fieldNames\":%@,\"rowsAffected\":%d}"
            , dataString
            , [self.errorDescription stringByReplacingOccurrencesOfString:@"\"" withString:@"'"]
            , [self.results count]
            , self.insertedID
            , [self.fieldNames count]
            , fieldNamesString
            , self.rowsAffected
            ];
    NSLog(@"result");
    return result;
}
@end
