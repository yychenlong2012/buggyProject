//
//  NSMutableString+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSMutableString+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSMutableString (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class stringClass = NSClassFromString(@"__NSCFString");
        //replaceCharactersInRange
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(replaceCharactersInRange:withString:) newMethod:@selector(avoidCrashReplaceCharactersInRange:withString:)];
        
        //insertString:atIndex:
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(insertString:atIndex:) newMethod:@selector(avoidCrashInsertString:atIndex:)];
        
        //deleteCharactersInRange
        [MonitorCrash exchangeInstanceMethod:stringClass oldMethod:@selector(deleteCharactersInRange:) newMethod:@selector(avoidCrashDeleteCharactersInRange:)];
    });
}
    
    //=================================================================
    //                     replaceCharactersInRange
    //=================================================================
#pragma mark - replaceCharactersInRange
    
- (void)avoidCrashReplaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    
    @try {
        [self avoidCrashReplaceCharactersInRange:range withString:aString];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    //=================================================================
    //                     insertString:atIndex:
    //=================================================================
#pragma mark - insertString:atIndex:
    
- (void)avoidCrashInsertString:(NSString *)aString atIndex:(NSUInteger)loc {
    
    @try {
        [self avoidCrashInsertString:aString atIndex:loc];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    //=================================================================
    //                   deleteCharactersInRange
    //=================================================================
#pragma mark - deleteCharactersInRange
    
- (void)avoidCrashDeleteCharactersInRange:(NSRange)range {
    
    @try {
        [self avoidCrashDeleteCharactersInRange:range];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    
    
@end
