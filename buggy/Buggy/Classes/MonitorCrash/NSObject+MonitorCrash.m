//
//  NSObject+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSObject+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSObject (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //setValue:forKey:
        [MonitorCrash exchangeInstanceMethod:[self class] oldMethod:@selector(setValue:forKey:) newMethod:@selector(avoidCrashSetValue:forKey:)];
        
        //setValue:forKeyPath:
        [MonitorCrash exchangeInstanceMethod:[self class] oldMethod:@selector(setValue:forKeyPath:) newMethod:@selector(avoidCrashSetValue:forKeyPath:)];
        
        //setValue:forUndefinedKey:
        [MonitorCrash exchangeInstanceMethod:[self class] oldMethod:@selector(setValue:forUndefinedKey:) newMethod:@selector(avoidCrashSetValue:forUndefinedKey:)];
        
        //setValuesForKeysWithDictionary:
        [MonitorCrash exchangeInstanceMethod:[self class] oldMethod:@selector(setValuesForKeysWithDictionary:) newMethod:@selector(avoidCrashSetValuesForKeysWithDictionary:)];
    });
    
}
    
    //=================================================================
    //                         setValue:forKey:
    //=================================================================
#pragma mark - setValue:forKey:
    
- (void)avoidCrashSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forKey:key];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    
    //=================================================================
    //                     setValue:forKeyPath:
    //=================================================================
#pragma mark - setValue:forKeyPath:
    
- (void)avoidCrashSetValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self avoidCrashSetValue:value forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    
    
    //=================================================================
    //                     setValue:forUndefinedKey:
    //=================================================================
#pragma mark - setValue:forUndefinedKey:
    
- (void)avoidCrashSetValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
    
    //=================================================================
    //                  setValuesForKeysWithDictionary:
    //=================================================================
#pragma mark - setValuesForKeysWithDictionary:
    
- (void)avoidCrashSetValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    @try {
        [self avoidCrashSetValuesForKeysWithDictionary:keyedValues];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        
    }
}
    
@end
