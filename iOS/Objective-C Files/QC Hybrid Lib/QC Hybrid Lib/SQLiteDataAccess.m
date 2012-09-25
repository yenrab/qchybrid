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

#import "SQLiteDataAccess.h"
#import "QCParameter.h"
#import <unistd.h>



static NSString *dbSemaphore = @"dblock";

// Private interface for AppDelegate - internal only methods.
@interface SQLiteDataAccess (Private)
- (DataAccessResult*)dbAccess:(NSString*)SQL withParameters:(NSArray*)parameters treatAsChangeData:(BOOL)treatAsChangeData;
//internal bind methods
- (int) bind_blob:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;
- (int) bind_double:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;
- (int) bind_int:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;
- (int) bind_text:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;
- (int) bind_zeroblob:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;
- (int) bind_null:(sqlite3_stmt*)statement withIndex:(int)anIndex andBindVariable:(id)aVariable;

@end

@implementation SQLiteDataAccess


- (SQLiteDataAccess*)initWithDatabase: (NSString*) dbName isWriteable: (BOOL) isWriteable{
	//if (self = [super init]) {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
    if(isWriteable){
        
        // The application ships with a default database in its bundle. If anything in the application
        // bundle is altered, the code sign will fail. We want the database to be editable by users, 
        // so we need to create a copy of it in the application's Documents directory.   
        
        BOOL success;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
        //NSLog(@"%@",writableDBPath);
        success = [fileManager fileExistsAtPath:writableDBPath];
        if (!success){
            // The writable database does not exist, so copy the default to the appropriate location.
            //NSLog(@"%@",path);
            //NSLog(@"%@",writableDBPath);
			
			@synchronized(dbSemaphore) {
				success = [fileManager copyItemAtPath:path toPath:writableDBPath error:&error];
			}
            if (!success) {
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
                return nil;
            }
        }
        path = writableDBPath;
    }
    sqlite3 *aDatabase;
    //NSLog(@"path: %@",path);
    if (sqlite3_open([path UTF8String], &aDatabase) == SQLITE_OK) {
        //NSLog(@"database opened");
        self->database = aDatabase;
        
        //NSLog(@"assigned");
        //create the dictionary that maps parameter types to bind method calls
        NSArray *keys = @[[NSString class], [NSDecimalNumber class]];
        ////NSLog(@"keys %@", keys);
        NSMutableArray * values = [[NSMutableArray alloc] init];
        [values addObject:@"bind_text:withIndex:andBindVariable:"];
        [values addObject:@"bind_double:withIndex:andBindVariable:"];
        //NSLog(@"values");
        //NSLog(@"keys and objects ready");
        NSDictionary *aDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];

        //NSLog(@"dictionary ready");
        self->bindTypeDictionary = aDictionary;
        //NSLog(@"dictionary set");
        //NSLog(@"successfully loaded database");
        return self;
    }
    else{
        //since we failed to open the database completely close it down to make sure that everyting is cleaned up
        sqlite3_close(aDatabase);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(aDatabase));
    }
	//}
	return nil;
}

- (DataAccessResult*)getData:(NSString*)SQL withParameters:(NSArray*)parameters{
	NSLog(@"getting data");
	return [self dbAccess:SQL withParameters:parameters treatAsChangeData:FALSE];
}


- (DataAccessResult*)setData:(NSString*)SQL withParameters:(NSArray*)parameters{
    NSLog(@"setting Data");
	DataAccessResult *retVal;
	@synchronized(dbSemaphore) {
		retVal =  [self dbAccess:SQL withParameters:parameters treatAsChangeData:TRUE];
	}
	return retVal;
}

- (DataAccessResult*)dbAccess:(NSString*)SQL withParameters:(NSArray*)parameters treatAsChangeData:(BOOL)treatAsChangeData{
    SQL = [SQL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//NSLog(@"paramArrayString after 1: %@\n\n\n",SQL);
	//NSLog(@"in dbAccess");
	DataAccessResult *theResult = [DataAccessResult alloc];
	if(parameters != nil && [parameters count] > 0){
		//make sure the the number of parameters is equal to the number of qestion marks in the SQL string
	}
	int numResultColumns = 0;
	sqlite3_stmt *statement = nil;	 // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator. 
	const char* SQLChar = [SQL UTF8String];//this needs to be deallocated after we don't need it any more.
	//NSLog(@"about to prepare %@",SQL);
	if (sqlite3_prepare_v2(database, SQLChar, -1, &statement, NULL) == SQLITE_OK) {
        //NSLog(@"prepared");
        if(!treatAsChangeData){
            //NSLog(@"columns not changing");
            //retrieve the number of columns in the result of the execution of the select statement
            numResultColumns = sqlite3_column_count(statement);
            //NSLog(@"numRecentColumns: %i",numResultColumns);
            NSMutableArray *fieldNames = [[NSMutableArray alloc] initWithCapacity:0];
            for(int i = 0; i < numResultColumns; i++){
                const char *name = sqlite3_column_name(statement, i);
                NSString * columnName = [[NSString alloc]initWithCString:name encoding:NSUTF8StringEncoding];
                [fieldNames addObject:columnName];
            }
            [theResult setFieldNames:fieldNames];
            
        }
        //NSLog(@"Checking SQL prepared statement parameters: %@", parameters);
        if(parameters != nil && [parameters count] > 0){
            int numParams = [parameters count];
            //NSLog(@"numQueryParams: %i", numParams);
            for (int i = 0; i < numParams; i++) {
                id value = parameters[i];
                //NSLog(@"value type: %@", [value class]);
                if ([value isKindOfClass:[NSString class]]) {
                    //bind_text:(sqlite3_stmt*)statement withIndex:(int) andBindVariable:(id)aVariable
                    [self bind_text:statement withIndex:i+1 andBindVariable:value];
                }
                else if([value isKindOfClass:[NSNumber class]]){
                    [self bind_double:statement withIndex:i+1 andBindVariable:value];
                }
                /*if([value respondsToSelector:NSSelectorFromString(@"getCharacters:")]){
                    value = (NSString*)value;
                }
                //NSLog(@"value type: %@", [value class]);
                //NSString *name = [parameter name];
                //id value = [parameter value];
                ////NSLog(@"name: %@, value: %@", name, value);
                //[parameter autorelease];
                //NSString *funcType;
                //NSStrings don't show up as NSStrings but as NSCFStrings
                
                if([value respondsToSelector:NSSelectorFromString(@"getCharacters:")]){
                    funcType = [bindTypeDictionary objectForKey:[NSString class]];
                }
                else{
                    funcType = [bindTypeDictionary objectForKey:[value class]];
                }
                 */
                
                
                //SEL aSelector = NSSelectorFromString(funcType);
                //bind the variables here
                //objc_msgSend(self, aSelector, statement, i+1, value);
                
                
                
                //sqlite3_bind_text(statement, i+1, value, [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding], SQLITE_TRANSIENT);
                /*
                 const char* valueChars = [value cStringUsingEncoding:NSASCIIStringEncoding];
                 sqlite3_bind_text(statement, i+1, valueChars, [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding], SQLITE_TRANSIENT);
				 */
            }
        }
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];//[[NSMutableArray alloc] initWithCapacity:0];
        [theResult setErrorDescription:@(sqlite3_errmsg(database))];
		
        // We "step" through the results - once for each row.
        // if the statement executed is not a select statement sqlite3_step will return SQLITE_DONE on the first iteration.
		int numTimesToTry = 20;
		int numTriesAttempted = 0;
		int queryResult = 0;
		//NSLog(@"about to attempt");
		while((numTriesAttempted++) <= numTimesToTry){
			//NSLog(@"attempting %i",numTriesAttempted);
			while (YES) {
				queryResult = sqlite3_step(statement);
				if(queryResult == SQLITE_BUSY){
					usleep(20);
					break;
				}
				else if(queryResult == SQLITE_ROW){
					if([theResult columnTypes] == nil){
						NSMutableArray *columnTypes = [[NSMutableArray alloc] initWithCapacity:0];
						for(int i = 0; i < numResultColumns; i++){
							NSNumber * columnType = @(sqlite3_column_type(statement,i));
							[columnTypes addObject:columnType];
							//[columnType autorelease];
						}
						[theResult setColumnTypes:columnTypes];
					}
				}
				else if(queryResult == SQLITE_DONE){
					numTriesAttempted = numTimesToTry+1;
					break;
				}
				else{
					numTriesAttempted = numTimesToTry+1;
					NSString *errorString = @(sqlite3_errmsg(database));
					//NSLog(@"error %i message  %@",queryResult, errorString);
					[theResult setErrorDescription:errorString];
					break;
				}
				/*
				 *  Iterate over all of the columns.  Determine their type and retrieve its value
				 *	 SQLITE_INTEGER
				 *  SQLITE_FLOAT
				 *  SQLITE_BLOB
				 *  SQLITE_NULL
				 *  SQLITE_TEXT
				 */
				
				NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:numResultColumns];
				for(int i = 0; i < numResultColumns; i++){
					int type  = [[theResult columnTypes][i] intValue];
					if(type == SQLITE_INTEGER){
						//NSLog(@"integer: %i",sqlite3_column_int(statement, i));
						NSNumber *aNum = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, i)];
						[row addObject:aNum];
					}
					else if(type == SQLITE_FLOAT){
						//NSLog(@"float");
						NSNumber *aFloat = [[NSNumber alloc] initWithFloat:sqlite3_column_double(statement, i)];
						[row addObject:aFloat];
					}
					else if(type == SQLITE_TEXT){
						//sqlite3_column_text returns a const unsigned char *.  initWithCString requires a const char *.
						char *cText = (char*)sqlite3_column_text(statement, i);
						NSString *aText = [[NSString alloc]initWithCString:cText encoding:NSUTF8StringEncoding];
						[row addObject:aText];
					}
					else if(type == SQLITE_BLOB){
						//NSLog(@"blob");
						NSData *aData = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:sqlite3_column_bytes(statement,i)];
						[row addObject:aData];
					}
					else{//SQLITE_NULL
						[row addObject:@"null"];
					}
				}
				[results addObject:row];
				//NSLog(@"current results: %@", results); 
				row = nil;
			}
        }
		if(results == nil){
			results = [NSMutableArray array];
		}
		[theResult setResults:results];
		//[results release];
        //NSLog(@"final results: %@", theResult.results);
    }
	else{
		/*NSString *error;
         error = [[NSString alloc]initWithCString:sqlite3_errmsg(database) encoding:NSASCIIStringEncoding];
         [theResult setErrorDescription:error];
         [error release];
         */
        [theResult setErrorDescription:@(sqlite3_errmsg(database))];
		
		[theResult setResults:[NSMutableArray array]];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
    
    //rows changed is 0 if not a change
    if(treatAsChangeData){
        int numberRecordsChanged =sqlite3_changes(database);
        [theResult setRowsAffected:numberRecordsChanged] ;
    }
    else{
        [theResult setRowsAffected:0];
    }
    
	sqlite3_finalize(statement);
    
    
    
	//[pool drain];
    //NSLog(@"returning: %@",theResult);
	return theResult;
}

- (DataAccessResult*)startTransaction{
	NSString* sql = @"BEGIN EXCLUSIVE TRANSACTION";
	return [self setData:sql withParameters:nil];
}
- (DataAccessResult*)endTransaction{
	NSString* sql = @"COMMIT";
	return [self setData:sql withParameters:nil];
	
}
- (DataAccessResult*)rollback{
	NSString* sql = @"ROLLBACK";
	return [self setData:sql withParameters:nil];
}

- (void)close{
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

// internal bind methods

- (int) bind_blob:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(NSData*)aVariable{
	/*
	if (![aVariable respondsToSelector:@selector(lengthOfBytes:)]) {
		return -1;
	}
     */
	//by default have the library make a copy, SQLITE_TRANSIENT, since we don't know if the variable may be changed
	//by something else in the application.
    
	return sqlite3_bind_blob(statement, parameterIndex, [aVariable bytes], [aVariable length], SQLITE_TRANSIENT);
}
- (int) bind_double:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(id)aVariable{
    //NSLog(@"binding parameter %i", parameterIndex);
	return sqlite3_bind_double(statement, parameterIndex, [aVariable doubleValue]);
}
- (int) bind_int:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(id)aVariable{
	return sqlite3_bind_int(statement, parameterIndex, [aVariable integerValue]);
}
- (int) bind_text:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(id)aVariable{
    //NSLog(@"binding parameter %i", parameterIndex);
	//assume an ASCII string
    const char* valueChars = [aVariable cStringUsingEncoding:NSUTF8StringEncoding];
	return sqlite3_bind_text(statement, parameterIndex, valueChars, [aVariable lengthOfBytesUsingEncoding:NSUTF8StringEncoding], SQLITE_TRANSIENT);
}
- (int) bind_zeroblob:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(int)aVariable{
	return sqlite3_bind_zeroblob(statement, parameterIndex, aVariable);
}
- (int) bind_null:(sqlite3_stmt*)statement withIndex:(int)parameterIndex andBindVariable:(id)aVariable{
	return sqlite3_bind_null(statement, parameterIndex);
}


@end
