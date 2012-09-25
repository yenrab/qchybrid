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

/**
 @mainpage A small easy to use framework used to make your application development easier.
 
 QC Native offers you a 21st century design from which to build your applications.  By using QC Native you are able to create 
 your applications without duplication of effort.  QC Native handles all data passing for you.  You can focus on the behaviors 
 you want in your application instead of spending wasted cycles tracking data being passed from one part of your code to another.
 
 The design of QC Native allows you to write highly modular code without effort.  You create a series of Control Objects containing your functionality 
 and map them into stacks of functionality. 
 
 When you want the functionality in the stack to be executed it is a single method call and the framework handles all the rest.  This includes handling 
 threading for you.  Each time you make this single call to handleRequest:withParameters: the stack is run on a background worker thread.  This keeps your 
 application repsonsive to user interactions and optimizes the use of the CPU.  When the view needs to be updated the framework will run your view update 
 code correctly and appropriately without you needing to indicate that it should be run in the main UI thread.
 
 For more information on stacks and Control Objects see the QuickConnect class description.
 
 
 @section Features
 
 @li Easy-to-use API
 @li Thread-safe
 @li User device agnostic.  iOS and OS X are supported
 
 
 @section Links
 
 @li <a href="http://www.quickconnectfamily.org/qcnative">QC Native web site</a>.
 @li Browse <a href="http://sourceforge.net/projects/qcjava/">the project at sourceForge</a>.
 @li The <a href="http://quickconnect.pbworks.com/w/page/9183363/FrontPage">wiki</a> also has more information on Control Objects and stacks.
 
 */



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class QCMapper;

@class NSPersistentStoreCoordinator;

/**
 The QuickConnect class is used to create control stacks and execute them. Control stacks consist a few types of classes that all implement the ControlObject interface. These types are:
 
 <br/><br/><b>ValCO Validation Control Objects</b> - these stacks objects are used to validate values that will be used later in other control objects. The items validated are usually passed in as parameters. By convention names for classes of this type end with ValCO.  Control objects of this type are executed on a background thread.
 <br/><br/><b>BCO Business Control Objects</b> - these stack objects are used to interact with databases, remote servers, files, and are also used to do data manipulation/computation. By convention names for classes of this type end with BCO.  Control objects of this type are executed on a background thread.
 <br/><br/><b>VCOView Control Objects</b> - these stack objects are used to do user interface updates.  By convention names for classes of this type end with VCO.    Control objects of this type are executed on the main UI thread.
 <br/><br/><b>ECOError Control Objects</b> - these stack objects are used to notify the user of errors and do any view cleanup required if an bad data or an error/exception occurs during the execution of a stack. By convention names for classes of this type end with ECO.  This type of control object is executed 
 on the main UI thread.
 
 @section example
 An example of a login stack could include the following control objects:
 @li <b>CredentialsValCO</b> - the handleIt method performs length/content validation on the user name and password. Returns either true or false
 @li <b>GetUserBCO</b> - the handleIt method queries the database to see if a user exists with the validated user name and password. Returns the user, if any, or null.
 @li <b>LoginSuccessVCO</b> - the handleIt method updates the UI.

 */

@interface QuickConnect : NSObject {
	QCMapper *theMapper;
    NSPersistentStoreCoordinator *theCoordinator;
	
	
}
@property (nonatomic, strong) QCMapper *theMapper;
@property (nonatomic, strong) NSPersistentStoreCoordinator *theCoordinator;

/*
 *	parameters is an optional parameter to this method
 */
/**
 The default initialization method  
 
 @returns an initialized QuickConnect object
 */
- (QuickConnect*)init;
/**
 This initialization method is used when your application will be using CoreData.
 @param aCoordinator The <b>NSPersistentStoreCoordinator</b> instance for your application.  If Xcode generated your CoreData code for you this is found in your app delegate
 @returns an initialized QuickConnect object aware of the CoreData persistent store
 */
- (QuickConnect*)initWithPersistentStoreCoodinator:(NSPersistentStoreCoordinator*)aCoordinator;

/**
 This is the trigger for the execution of mapped stacks.  Each call to handle request is run on a background worker thread.
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Objects you want executed.
  @param parameters The <b>NSMutableDictionary</b> instance containing any and all values that you want passed to the indicated stack or nil if there are none.
 */
- (void) handleRequest: (NSString*) aCmd withParameters:(NSMutableDictionary*) parameters;
/**
 This method maps a specific Business Control Object, see the description at the top of this page, to the business (data) portion of the stack indicated by the command string.
 
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Objects being created.
 @param aClass The <b>Class</b> of the Control Object to be added to the stack.  Example: [GetUserBCO class] 
 */
- (void) mapCommandToBCO:(NSString*)aCommand withObject:(Class)aClass;
/**
 This method maps a specific View Control Object, see the description at the top of this page, to the view modification portion of the stack indicated by the command string.
 
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Objects being created.
 @param aClass The <b>Class</b> of the Control Object to be added to the stack.  Example: [LoginSuccessVCO class] 
 */
- (void) mapCommandToVCO:(NSString*)aCommand withObject:(Class)aClass;
/**
 This method maps a specific Validation Control Object, see the description at the top of this page, to the validation portion of the stack indicated by the command string.
 
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Objects being created.
 @param aClass The <b>Class</b> of the Control Object to be added to the stack.  Example: [CredentialsValCO class] 
 */
- (void) mapCommandToValCO:(NSString*)aCommand withObject:(Class)aClass;
/**
 This method maps a specific Error Control Object to an error stack indicated by the command string.  ECO's are mapped to their own stack not the stack in 
 which the error occurs.
 
 
 @param aCommand The <b>NSString</b> that uniquely identifies the stack of Control Objects being created.
 @param aClass The <b>Class</b> of the Control Object to be added to the stack.  Example: [InvalidCredentialsECO class] 
 
 */
- (void) mapCommandToECO:(NSString*)aCommand withObject:(Class)aClass;
- (void) mapCommandToSCO:(NSString*)aCommand withObject:(Class)aClass;


@end

