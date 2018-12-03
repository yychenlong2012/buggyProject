//
//  NSArray+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSArray+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSArray (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类方法交换
        [MonitorCrash exchangeClassMethod:[self class] oldMethod:@selector(arrayWithObjects:count:) newMethod:@selector(MonitorCrashArrayWithObjects:count:)];
        // 实例方法交换
        Class __NSArray = NSClassFromString(@"NSArray");
        [MonitorCrash exchangeInstanceMethod:__NSArray oldMethod:@selector(objectsAtIndexes:) newMethod:@selector(monitorCrashObjectsAtIndexes:)];
        [MonitorCrash exchangeInstanceMethod:__NSArray oldMethod:@selector(objectAtIndex:) newMethod:@selector(monitorCrashObjectAtIndex:)];
        [MonitorCrash exchangeInstanceMethod:__NSArray oldMethod:@selector(getObjects:range:) newMethod:@selector(NSArrayMonitorCrashGetObjects:range:)];
    });
    
    
}
  
// arrayWithObjects:count:
+ (instancetype)MonitorCrashArrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    
    id instance = nil;
    @try {
        instance = [self MonitorCrashArrayWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = @"This framework default is to remove nil object and instance a array.";
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        //以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
        NSInteger newObjsIndex = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        instance = [self MonitorCrashArrayWithObjects:newObjects count:newObjsIndex];
    }
    @finally {
        return instance;
    }
}
    
// objectsAtIndexes:
- (NSArray *)monitorCrashObjectsAtIndexes:(NSIndexPath *)indexes{
    NSArray *newArray = nil;
    @try {
        newArray = [self monitorCrashObjectsAtIndexes:indexes];
    } @catch (NSException *exception) {
        NSString *defaultDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultDo];
    } @finally {
        return newArray;
    }
}
 
//__NSArrayI  objectAtIndex:
- (id)monitorCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self monitorCrashObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    }
    @finally {
        return object;
    }
}
    
    
//NSArray getObjects:range:
- (void)NSArrayMonitorCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    
    @try {
        [self NSArrayMonitorCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
    } @finally {
        
    }
}
    
@end
