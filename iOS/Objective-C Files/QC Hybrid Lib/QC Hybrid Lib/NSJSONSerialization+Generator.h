//
//  NSJSONSerialization+Generator.h
//  QC Hybrid Lib
//
//  Created by Sam Barney on 12/19/12.
//
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Generator)
+(NSString *) stringWithJSONObject:(id)obj error:(NSError **)error;
+(id) JSONObjectWithString:(NSString *)str error:(NSError **)error;
@end
