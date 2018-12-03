//
//  NSDictionary+MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "NSDictionary+MonitorCrash.h"
#import "MonitorCrash.h"
@implementation NSDictionary (MonitorCrash)

+ (void)monitorCrashExchangeMethod{
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MonitorCrash exchangeClassMethod:[self class] oldMethod:@selector(dictionaryWithObjects:forKeys:count:) newMethod:@selector(avoidCrashDictionaryWithObjects:forKeys:count:)];
    });
}
+ (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    
    id instance = nil;
    
    @try {
        instance = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = @"This framework default is to remove nil key-values and instance a dictionary.";
        [MonitorCrash showErrorWithException:exception shouldDo:defaultToDo];
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}
    
@end
