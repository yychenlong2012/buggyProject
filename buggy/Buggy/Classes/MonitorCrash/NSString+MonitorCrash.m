//
//  NSString+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSString+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSString (MonitorCrash)
+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class stringClass = NSClassFromString(@"__NSCFConstantString");
        
        //characterAtIndex
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(characterAtIndex:) newMethod:@selector(avoidCrashCharacterAtIndex:)];
        //substringFromIndex
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(substringFromIndex:) newMethod:@selector(avoidCrashSubstringFromIndex:)];
        
        //substringToIndex
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(substringToIndex:) newMethod:@selector(avoidCrashSubstringToIndex:)];
        //substringWithRange:
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(substringWithRange:) newMethod:@selector(avoidCrashSubstringWithRange:)];
        
        //stringByReplacingOccurrencesOfString:
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(stringByReplacingOccurrencesOfString:withString:) newMethod:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:)];
        
        //stringByReplacingOccurrencesOfString:withString:options:range:
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(stringByReplacingOccurrencesOfString:withString:options:range:) newMethod:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:options:range:)];
        
        //stringByReplacingCharactersInRange:withString:
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(stringByReplacingCharactersInRange:withString:) newMethod:@selector(avoidCrashStringByReplacingCharactersInRange:withString:)];
    });
}
    
    //=================================================================
    //                           characterAtIndex:
    //=================================================================
#pragma mark - characterAtIndex:
    
- (unichar)avoidCrashCharacterAtIndex:(NSUInteger)index {
    
    unichar characteristic;
    @try {
        characteristic = [self avoidCrashCharacterAtIndex:index];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = @"This framework default is to return a without assign unichar.";
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        return characteristic;
    }
}
    
    //=================================================================
    //                           substringFromIndex:
    //=================================================================
#pragma mark - substringFromIndex:
    
- (NSString *)avoidCrashSubstringFromIndex:(NSUInteger)from {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringFromIndex:from];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}
    
    //=================================================================
    //                           substringToIndex
    //=================================================================
#pragma mark - substringToIndex
    
- (NSString *)avoidCrashSubstringToIndex:(NSUInteger)to {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringToIndex:to];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}
    
    
    //=================================================================
    //                           substringWithRange:
    //=================================================================
#pragma mark - substringWithRange:
    
- (NSString *)avoidCrashSubstringWithRange:(NSRange)range {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringWithRange:range];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}
    
    //=================================================================
    //                stringByReplacingOccurrencesOfString:
    //=================================================================
#pragma mark - stringByReplacingOccurrencesOfString:
    
- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    
    NSString *newStr = nil;
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}
    
    //=================================================================
    //  stringByReplacingOccurrencesOfString:withString:options:range:
    //=================================================================
#pragma mark - stringByReplacingOccurrencesOfString:withString:options:range:
    
- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}
    
    
    //=================================================================
    //       stringByReplacingCharactersInRange:withString:
    //=================================================================
#pragma mark - stringByReplacingCharactersInRange:withString:
    
- (NSString *)avoidCrashStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    
    NSString *newStr = nil;
    @try {
        newStr = [self avoidCrashStringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}
    
    
    
    
    
@end
