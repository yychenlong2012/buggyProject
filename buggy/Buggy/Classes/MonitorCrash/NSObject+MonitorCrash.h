//
//  NSObject+MonitorCrash.h
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MonitorCrash)

+ (void)monitorCrashExchangeMethod;
    
    /**
     *  Can avoid crash method
     *
     *  1.- (void)setValue:(id)value forKey:(NSString *)key
     *  2.- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
     *  3.- (void)setValue:(id)value forUndefinedKey:(NSString *)key //这个方法一般用来重写，不会主动调用
     *  4.- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
     *
     */
@end
