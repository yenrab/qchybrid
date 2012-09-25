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

#import "PrepareNonStandardEntity.h"



@interface PrepareNonStandardEntity (hidden)

+(NSString*) toCustomEntityString:(ABMultiValueRef)multi;

@end

@implementation PrepareNonStandardEntity
+ (NSDictionary*) ABRecordRef:(ABRecordRef) aRecord{
	
	//NSMutableString *personString = [[NSMutableString alloc] init];
	NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];

	NSString *namePrefix = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonPrefixProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonPrefixProperty) : [[NSString alloc]init];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	namePrefix = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	
	NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonFirstNameProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonFirstNameProperty) : [[NSString alloc]init];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	firstName = [firstName stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonMiddleNameProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonMiddleNameProperty) : [[NSString alloc]init];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	middleName = [middleName stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonLastNameProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonLastNameProperty) : [[NSString alloc]init];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *nameSuffix = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonSuffixProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonSuffixProperty) : [[NSString alloc]init];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	nameSuffix = [nameSuffix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *birthday = [((__bridge NSDate*)ABRecordCopyValue(aRecord, kABPersonBirthdayProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonBirthdayProperty) : [[NSString alloc]init]) description];
	birthday = [[birthday componentsSeparatedByString:@" "] objectAtIndex:0];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	birthday = [birthday stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	birthday = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	
	
	ABMultiValueRef addressValues = ABRecordCopyValue(aRecord, kABPersonAddressProperty);
	NSDictionary *addresses = [PrepareNonStandardEntity toCustomEntityString:addressValues];
	
	NSString *organization = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonOrganizationProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonOrganizationProperty) : [[NSString alloc]init];
	organization = [organization stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	organization = [organization stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	organization = [organization stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	organization = [organization stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	organization = [organization stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	organization = [organization stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	organization = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *jobTitle = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonJobTitleProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonJobTitleProperty) : [[NSString alloc]init];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	jobTitle = [jobTitle stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	jobTitle = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	NSString *department = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonDepartmentProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonDepartmentProperty) : [[NSString alloc]init];
	department = [department stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	department = [department stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	department = [department stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	department = [department stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	department = [department stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	department = [department stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	department = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	
	
	ABMultiValueRef multiEmail = ABRecordCopyValue(aRecord, kABPersonEmailProperty);
	NSDictionary *email = [PrepareNonStandardEntity toCustomEntityString:multiEmail];
	
	NSString *note = (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonNoteProperty) != nil ? (__bridge NSString *)ABRecordCopyValue(aRecord, kABPersonNoteProperty) : [[NSString alloc]init];
	note = [note stringByReplacingOccurrencesOfString:@"'" withString:@"&napos;"];
	note = [note stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	note = [note stringByReplacingOccurrencesOfString:@"{" withString:@"&#123;"];
	note = [note stringByReplacingOccurrencesOfString:@"}" withString:@"&#125;"];
	note = [note stringByReplacingOccurrencesOfString:@"[" withString:@"&#91;"];
	note = [note stringByReplacingOccurrencesOfString:@"]" withString:@"&#93;"];
	note = [note stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	birthday = [namePrefix stringByReplacingOccurrencesOfString:@":" withString:@"&#58;"];
	
	ABMultiValueRef multiPhones = ABRecordCopyValue(aRecord, kABPersonPhoneProperty);
	NSDictionary *phones = [PrepareNonStandardEntity toCustomEntityString:multiPhones];
	
	
	ABMultiValueRef imRefs = ABRecordCopyValue(aRecord, kABPersonInstantMessageProperty);
	NSDictionary *im = [PrepareNonStandardEntity toCustomEntityString:imRefs];
	
	[retVal setObject:namePrefix forKey:@"prefix"];
	[retVal setObject:firstName forKey:@"fname"];
	[retVal setObject:middleName forKey:@"mname"];
	[retVal setObject:lastName forKey:@"lname"];
	[retVal setObject:nameSuffix forKey:@"suffix"];
	[retVal setObject:birthday forKey:@"birthday"];
	[retVal setObject:addresses forKey:@"address"];
	[retVal setObject:organization forKey:@"organization"];
	[retVal setObject:jobTitle forKey:@"jobTitle"];
	[retVal setObject:department forKey:@"department"];
	[retVal setObject:email forKey:@"email"];
	[retVal setObject:note forKey:@"note"];
	[retVal setObject:phones forKey:@"phone"];
	[retVal setObject:im forKey:@"im"];
	
	//NSLog(@"retVal: %@",retVal);
	return retVal;
}

+(NSDictionary*) toCustomEntityString:(ABMultiValueRef)multi{
	NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
	int numRecords = ABMultiValueGetCount(multi);
	for (CFIndex i = 0; i < numRecords; i++) {
		CFTypeRef valueRef = ABMultiValueCopyValueAtIndex(multi, i);
		
		NSMutableString *mutableStr = [NSMutableString stringWithCapacity:0];
		NSString *label = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(multi, i);
		[mutableStr appendString:label];
		[mutableStr replaceOccurrencesOfString:@"_$!<" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableStr length])];
		[mutableStr replaceOccurrencesOfString:@">!$_" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableStr length])];
		label = mutableStr;
		NSMutableArray *values = [retVal valueForKey:label];
		if(values == nil){
			values = [NSMutableArray arrayWithCapacity:1];
			[retVal setObject:values forKey:label];
		}
		[values addObject:(__bridge id)valueRef];
	}
	return retVal;
}
@end
