//
//  DryFootApi.h
//  Buggy
//
//  Created by goat on 2019/2/22.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DryFootApi : NSObject

//获取蓝牙信息
+ (NSData *)getDeviceData;
//体重体脂数据
+ (NSData *)getWeightAndFatData;
//重量单位设置
+ (NSData *)setWeightUnit:(NSInteger)unit;
//风力档位设置
+ (NSData *)setWindLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
