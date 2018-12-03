//
//  NSMutableDictionary+MonitorCrash.h
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MonitorCrash)

+ (void)monitorCrashExchangeMethod;
    
    /**
     *  Can avoid crash method
     *
     *  1. - (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
     *  2. - (void)removeObjectForKey:(id)aKey
     *
     */
    
@end
