//
//  NSString+Additions.m
//  Buggy
//
//  Created by ningwu on 16/6/3.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)
+ (NSString *)cleanString:(NSString *)str {
    if (str == nil) {
        return @"";
    }
    NSMutableString *cleanString = [NSMutableString stringWithString:str];
    [cleanString replaceOccurrencesOfString:@"\n" withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [cleanString length])];
    [cleanString replaceOccurrencesOfString:@"\r" withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [cleanString length])];
    [cleanString replaceOccurrencesOfString:@" " withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [cleanString length])];
    return cleanString;
}
@end
