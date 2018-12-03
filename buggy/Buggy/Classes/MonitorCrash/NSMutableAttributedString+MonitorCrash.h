//
//  NSMutableAttributedString+MonitorCrash.h
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (MonitorCrash)

+ (void)monitorCrashExchangeMethod;
    
@end


/**
 *  Can avoid crash method
 *
 *  1.- (instancetype)initWithString:(NSString *)str
 *  2.- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs
 */
