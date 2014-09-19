//
//  NSJSONSerialization+Generator.m
//  QC Hybrid Lib
//
//  Created by Sam Barney on 12/19/12.
//
//

#import "NSJSONSerialization+Generator.h"

@implementation NSJSONSerialization (Generator)

+(NSString *) stringWithJSONObject:(id)obj error:(NSError **)error {
   NSData * data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
	NSString *JSONString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
   return JSONString;
}

+(id) JSONObjectWithString:(NSString *)str error:(NSError **)error {
   NSData * data = [str dataUsingEncoding:NSASCIIStringEncoding];
   return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}
@end
