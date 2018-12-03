//
//  NSMutableDictionary+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSMutableDictionary+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSMutableDictionary (MonitorCrash)
    
+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
        //setObject:forKey:
        [MonitorCrash exchangeInstanceMethod:dictionaryM oldMethod:@selector(setObject:forKey:) newMethod:@selector(avoidCrashSetObject:forKey:)];
        //removeObjectForKey:
        Method removeObjectForKey = class_getInstanceMethod(dictionaryM, @selector(removeObjectForKey:));
        Method avoidCrashRemoveObjectForKey = class_getInstanceMethod(dictionaryM, @selector(avoidCrashRemoveObjectForKey:));
        method_exchangeImplementations(removeObjectForKey, avoidCrashRemoveObjectForKey);
    });
}
    
    //=================================================================
    //                       setObject:forKey:
    //=================================================================
#pragma mark - setObject:forKey:
    
- (void)avoidCrashSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    @try {
        [self avoidCrashSetObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        [MonitorCrash showErrorWithException:exception shouldDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}
    
    //=================================================================
    //                       removeObjectForKey:
    //=================================================================
#pragma mark - removeObjectForKey:
    
- (void)avoidCrashRemoveObjectForKey:(id)aKey {
    
    @try {
        [self avoidCrashRemoveObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        [MonitorCrash showErrorWithException:exception shouldDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}
   
    
    
@end
