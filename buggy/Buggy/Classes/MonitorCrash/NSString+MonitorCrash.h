//
//  NSString+MonitorCrash.h
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MonitorCrash)

+ (void)monitorCrashExchangeMethod;

    /**
     *  Can avoid crash method
     *
     *  1. - (unichar)characterAtIndex:(NSUInteger)index
     *  2. - (NSString *)substringFromIndex:(NSUInteger)from
     *  3. - (NSString *)substringToIndex:(NSUInteger)to {
     *  4. - (NSString *)substringWithRange:(NSRange)range {
     *  5. - (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
     *  6. - (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
     *  7. - (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement
     *
     */
@end
