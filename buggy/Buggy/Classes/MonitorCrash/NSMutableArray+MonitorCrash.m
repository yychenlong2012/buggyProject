//
//  NSMutableArray+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSMutableArray+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSMutableArray (MonitorCrash)

    
+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class arrayMClass = NSClassFromString(@"__NSArrayM");
        //objectAtIndex:
        [MonitorCrash exchangeInstanceMethod:arrayMClass oldMethod:@selector(objectAtIndex:) newMethod:@selector(avoidCrashObjectAtIndex:)];
        
        //setObject:atIndexedSubscript:
        [MonitorCrash exchangeInstanceMethod:arrayMClass oldMethod:@selector(setObject:atIndexedSubscript:) newMethod:@selector(avoidCrashSetObject:atIndexedSubscript:)];
        
        //removeObjectAtIndex:
        [MonitorCrash exchangeInstanceMethod:arrayMClass oldMethod:@selector(removeObjectAtIndex:) newMethod:@selector(avoidCrashRemoveObjectAtIndex:)];
        
        
        //insertObject:atIndex:
        [MonitorCrash exchangeInstanceMethod:arrayMClass oldMethod:@selector(insertObject:atIndex:) newMethod:@selector(avoidCrashInsertObject:atIndex:)];
        
        //getObjects:range:
        [MonitorCrash exchangeInstanceMethod:arrayMClass oldMethod:@selector(getObjects:range:) newMethod:@selector(avoidCrashGetObjects:range:)];
    });
}
    
    //=================================================================
    //                    array set object at index
    //=================================================================
#pragma mark - get object from array
    
    
- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    
    @try {
        [self avoidCrashSetObject:obj atIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [MonitorCrash showErrorWithException:exception shouldDo:AvoidCrashDefaultReturnNil];
    }
    @finally {
        
    }
}
    
    
    //=================================================================
    //                    removeObjectAtIndex:
    //=================================================================
#pragma mark - removeObjectAtIndex:
    
- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)index {
    @try {
        [self avoidCrashRemoveObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [MonitorCrash showErrorWithException:exception shouldDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}
    
    
    //=================================================================
    //                    insertObject:atIndex:
    //=================================================================
#pragma mark - set方法
- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        [MonitorCrash showErrorWithException:exception shouldDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}
    
    
    //=================================================================
    //                           objectAtIndex:
    //=================================================================
#pragma mark - objectAtIndex:
    
- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self avoidCrashObjectAtIndex:index];
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
    //                         getObjects:range:
    //=================================================================
#pragma mark - getObjects:range:
    
- (void)avoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    @try {
        [self avoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        
    } @finally {
        
    }
}
    
@end
