//
//  NSMutableAttributedString+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSMutableAttributedString+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSMutableAttributedString (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class NSConcreteMutableAttributedString = NSClassFromString(@"NSConcreteMutableAttributedString");
        
        //initWithString:
        [MonitorCrash exchangeInstanceMethod:NSConcreteMutableAttributedString oldMethod:@selector(initWithString:) newMethod:@selector(avoidCrashInitWithString:)];
        
        //initWithString:attributes:
        [MonitorCrash exchangeInstanceMethod:NSConcreteMutableAttributedString oldMethod:@selector(initWithString:attributes:) newMethod:@selector(avoidCrashInitWithString:attributes:)];
    });
    
}
  
    //=================================================================
    //                          initWithString:
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
    //                     initWithString:attributes:
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
