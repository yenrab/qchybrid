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

#import "ExecuteDBScriptBCO.h"
#import "QuickConnectViewController.h"
#import "SBJSON.h"
#import "DataAccessResult.h"
#import "SQLiteDataAccess.h"


@implementation ExecuteDBScriptBCO
+ (BOOL) handleIt:(NSMutableDictionary*) dictionary{
    NSArray *parameters = [dictionary objectForKey:@"parameters"];
	//NSLog(@"executing script %@", parameters);
	DataAccessResult* retVal=nil;
    QuickConnectViewController *controller = (QuickConnectViewController*)[parameters objectAtIndex:0];
	//NSLog(@"param count: %i",[parameters count]);
	if( [parameters count] >= 2){
		NSString *dbName = [parameters objectAtIndex:1];
		NSArray *linker = [parameters objectAtIndex:2];
		
		
		
		
		SQLiteDataAccess *aDBAccess = (SQLiteDataAccess*)[controller.databases objectForKey:dbName];
		if(aDBAccess == nil){
			aDBAccess = [[SQLiteDataAccess alloc] initWithDatabase:dbName isWriteable: YES];
			[controller.databases setObject:aDBAccess forKey:dbName];
		}
		retVal = [aDBAccess startTransaction];
		
		SBJSON *generator = [SBJSON alloc];
		NSError *error;
		int numStatements = [linker count];
		for (int i = 0; i < numStatements; i++) {
			NSArray *row = [linker objectAtIndex:i];
			NSString *SQL = [row objectAtIndex:1];
			
			SQL = [SQL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//NSLog(@"SQL: %@",SQL);
			NSArray *key = [generator objectWithString:[row objectAtIndex:0] error:&error];
			NSArray *values = [key objectAtIndex:1];
			NSMutableArray *mutableValues = [NSMutableArray arrayWithArray:values];
			//NSLog(@"values: %@",mutableValues);
			for (int i = 0; i < [mutableValues count]; i++) {
				//NSLog(@"class: %@ value: %@",[[mutableValues objectAtIndex:i] class],[mutableValues objectAtIndex:i]);
				if ([mutableValues objectAtIndex:i] == [NSNull null]) {
					[mutableValues replaceObjectAtIndex:i withObject:@""];
				}
			}
			//NSLog(@"values: %@",mutableValues);
			retVal = [aDBAccess setData:SQL withParameters:mutableValues];
			//NSLog(@"error description: %@",retVal.errorDescription);
			if([[retVal errorDescription] compare:@"not an error"] != NSOrderedSame){
				break;
			}
		}
		if([[retVal errorDescription] compare:@"not an error"] == NSOrderedSame){
			retVal = [aDBAccess endTransaction];
		}
		else{
			[aDBAccess rollback];
		}
    }
    [dictionary setObject:retVal?retVal : @"Must have 3 parameters" forKey:@"dbScriptResults"];
    return QC_STACK_CONTINUE;
}
@end
