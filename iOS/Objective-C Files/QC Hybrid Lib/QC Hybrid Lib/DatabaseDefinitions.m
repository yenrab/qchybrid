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
 
 The end-user documentation included with the redistribution, if any, must 
 include the following acknowledgment: 
 "This product was created using the QuickConnect framework.  http://quickconnect.sourceforge.net/", 
 in the same place and form as other third-party acknowledgments.   Alternately, this acknowledgment 
 may appear in the software itself, in the same form and location as other 
 such third-party acknowledgments.
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "DatabaseDefinitions.h"
#import "SQLiteDataAccess.h"


@implementation DatabaseDefinitions

@synthesize databases;

/*
 * Setup all of your databases inside of the initDatabases method.
 * You can have any number and type of databases.  Define them all here.
 * 
 * Add each database with a key.  This will allow you to retrieve it later.
 */


- (DatabaseDefinitions*)initDatabases{
	self.databases = [NSMutableDictionary dictionaryWithCapacity:10];
	//do not modify anything before this comment line.
	
	/*
	 * Setup all of the connections to your databases here.
	 */
	
	/* example setup
	SQLiteDataAccess *demoDB = [[SQLiteDataAccess alloc] initWithDatabase:@"demo.sqlite" isWriteable:YES];
	[self.databases setObject:demoDB forKey:@"demoDB"];
	[demoDB release];
	 */
	
	
	//don't change anything after this line
	return self;
}



/*
 * This is a helper method.  Don't change it.
 */

- (SQLiteDataAccess*)getDatabaseForName:(NSString*)aDatabaseName{
	return (self.databases)[aDatabaseName];
}




@end
