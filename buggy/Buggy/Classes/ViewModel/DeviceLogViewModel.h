//
//  DeviceLogViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/19.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteDataHander)(BOOL success,NSError *error);

@interface DeviceLogViewModel : NSObject

/**
 上传修复的日志信息

 @param logDic 日志信息
 @param completeHander
 */
+ (void)uploadDeviceRepairLog:(NSDictionary *)logDic completeHander:(CompleteDataHander)completeHander;


/**
 上传正常的日志信息

 @param logDic 日志信息
 @param completeHander
 */
+ (void)uploadDeviceNormalLog:(NSDictionary *)logDic completeHander:(CompleteDataHander)completeHander;

//+ (void)find;

@end
