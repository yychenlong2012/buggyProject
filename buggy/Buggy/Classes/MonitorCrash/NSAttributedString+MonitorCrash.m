//
//  NSAttributedString+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSAttributedString+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSAttributedString (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class NSConcreteAttributedString = NSClassFromString(@"NSConcreteAttributedString");
        //initWithString:
        [MonitorCrash exchangeInstanceMethod:NSConcreteAttributedString oldMethod:@selector(initWithString:) newMethod:@selector(avoidCrashInitWithString:)];
        
        //initWithAttributedString
        [MonitorCrash exchangeInstanceMethod:NSConcreteAttributedString oldMethod:@selector(initWithAttributedString:) newMethod:@selector(avoidCrashInitWithAttributedString:)];
        
        //initWithString:attributes:
        [MonitorCrash exchangeInstanceMethod:NSConcreteAttributedString oldMethod:@selector(initWithAttributedString:) newMethod:@selector(avoidCrashInitWithAttributedString:)];
    });
    
}
    
    //=================================================================
    //                           initWithString:
    //=================================================================
#pragma mark - initWithString:
    
- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        return object;
    }
}
    
    
    //=================================================================
    //                          initWithAttributedString
    //=================================================================
#pragma mark - initWithAttributedString
    
- (instancetype)avoidCrashInitWithAttributedString:(NSAttributedString *)attrStr {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithAttributedString:attrStr];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        return object;
    }
}
    
    
    //=================================================================
    //                      initWithString:attributes:
    //=================================================================
#pragma mark - initWithString:attributes:
    
- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        return object;
    }
}
    
    
@end
