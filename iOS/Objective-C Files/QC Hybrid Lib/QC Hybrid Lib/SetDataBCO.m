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

#import "SetDataBCO.h"
#import "QuickConnectViewController.h"
#import "SQLiteDataAccess.h"
#import "DataAccessResult.h"


@implementation SetDataBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = dictionary[@"parameters"];
	QuickConnectViewController *controller = (QuickConnectViewController*)parameters[0];
	if( [parameters count] >= 3){
		NSString *dbName = parameters[1];
		NSString *SQL = parameters[2];
		NSArray *preparedStatementValues = nil;
		if([parameters count] >= 4){
			preparedStatementValues = parameters[3];
		}
        SQLiteDataAccess *aDBAccess = (SQLiteDataAccess*)(controller.databases)[dbName];
        if(aDBAccess == nil){
            aDBAccess = [[SQLiteDataAccess alloc] initWithDatabase:dbName isWriteable: YES];
            (controller.databases)[dbName] = aDBAccess;

        }
        NSMutableArray *interactionResult = nil;
        if (!(interactionResult = dictionary[@"dbInteractionResults"])) {
            interactionResult = [NSMutableArray arrayWithCapacity:1];
        }
        [interactionResult addObject:[aDBAccess setData:SQL withParameters:preparedStatementValues]];
        //NSLog(@"sql: %@ %@",SQL, preparedStatementValues);
        dictionary[@"dbInteractionResults"] = interactionResult;
        return QC_STACK_CONTINUE;
    }
    return QC_STACK_EXIT;
}

@end
