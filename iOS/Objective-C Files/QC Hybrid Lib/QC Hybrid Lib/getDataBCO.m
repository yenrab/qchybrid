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

#import "GetDataBCO.h"
#import "QuickConnectViewController.h"
#import "SQLiteDataAccess.h"
#import "DataAccessResult.h"



@implementation GetDataBCO

+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
    //NSLog(@"params in getdata %@", parameters);
	QuickConnectViewController *controller = (QuickConnectViewController*)[parameters objectAtIndex:0];
	if( [parameters count] >= 3){
		NSString *dbName = [parameters objectAtIndex:1];
		NSString *SQL = [parameters objectAtIndex:2];
		//SQL = [SQL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSArray *preparedStatementValues = nil;
		if([parameters count] >= 4){
            preparedStatementValues = [parameters objectAtIndex:3];
		}
        
        SQLiteDataAccess *aDBAccess = (SQLiteDataAccess*)[controller.databases objectForKey:dbName];
        if(aDBAccess == nil){
            aDBAccess = [[SQLiteDataAccess alloc] initWithDatabase:dbName isWriteable: YES];
            [controller.databases setObject:aDBAccess forKey:dbName];
        }
        //NSLog(@"prepared statement values: %@",preparedStatementValues);
        //[dictionary setObject:[aDBAccess getData:SQL withParameters:preparedStatementValues] forKey:@"dbInteractionResult"];
        NSMutableArray *interactionResult = nil;
        if (!(interactionResult = [dictionary objectForKey:@"dbInteractionResults"])) {
            interactionResult = [NSMutableArray arrayWithCapacity:1];
        }
        [interactionResult addObject:[aDBAccess getData:SQL withParameters:preparedStatementValues]];
        //NSLog(@"sql: %@ %@",SQL, preparedStatementValues);
        [dictionary setObject:interactionResult forKey:@"dbInteractionResults"];
		return QC_STACK_CONTINUE;
	}
	return QC_STACK_EXIT;
}

@end
