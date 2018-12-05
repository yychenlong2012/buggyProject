//
//  CarDetailsViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarKcalModel.h"
typedef void(^CompleteHander)(NSDictionary *dic,BOOL success);
// 背光亮度
typedef enum : NSUInteger {
    BACKLIGHT_CLOSE = 0, // 0x00 关闭背光
    BACKLIGHT_ONE,       // 0x01 背光PWM 7%
    BACKLIGHT_TWO,       // 0X02 背光PWM 20%
    BACKLIGHT_THREE,     // 0X03 背光PWM 40%
    BACKLIGHT_FOUR,      // 0X04 背光PWM 60%
    BACKLIGHT_FIVE,      // 0X05 背光PWM 80%
    BACKLIGHT_SIX        // 0X06 背光PWM 100%
} BACKLIGHT_TYPE;

// 请求表的类型
typedef enum : NSUInteger {
    FETCHTABLENAME_A1 = 0, // A1 版车的数据模型
    FETCHTABLENAME_A3 = 1  // A2 新版车数据模型
} FETCHTABLENAMETYPE;

@interface CarDetailsViewModel : NSObject

/**
 获取卡路里界面详情
 
 @param finish 完成回调
 */

//+ (void)getCarKcalType:(FETCHTABLENAMETYPE)type UUID:(NSString *)UUID Model:(void(^)(CarKcalModel *carKcalModel ,NSError *error))finish;

/**
 上传数据
 */
+ (void)postTravel:(NSDictionary *)param tableType:(FETCHTABLENAMETYPE )tableType complete:(CompleteHander )success;

/**
 获取设备的关于行程的所有指令(今日里程、总里程、平均速度、电量、刹车状态，数据会依次回调)

 @return 获取指令
 */
+ (NSData *)getDeviceStatus;



/**
 获取设备行程信息

 @return 获取总里程指令
 */
+ (NSData *)getDeviceTravelData;


/**
// 获取刹车状态
//
// @return 获取刹车状态指令
// */
//+ (NSData *)getBrakeStatus;
//

///**
// 获取刹车电量
//
// @return 获取电池电量指令
// */
//+ (NSData *)getBattery;
//
/**
 获取日志信息

 @return 获取日志信息指令
 */
+ (NSData *)getLogInfo;


/**
 获取设备版本

 @return 获取设备版本指令
 */
+ (NSData *)getDeviceVersion;

/**
 设置刹车

 @return 设置刹车指令
 */
+ (NSData *)setBraking;


/**
 设置解除刹车

 @return 设置解除刹车指令
 */
+ (NSData *)setRelieveBraking;

/**
 设置防盗
 
 @return 设置刹车指令
 */
+ (NSData *)setAntiTheft;


/**
 设置解除防盗
 
 @return 设置解防盗车指令
 */
+ (NSData *)setCancelAntiTheft;


/**
 设置关闭设备

 @return
 */
+ (NSData *)setCloseDevice;


/**
 设置背光调节

 @return 设置背光调节指令
 */
+ (NSData *)setBacklight:(BACKLIGHT_TYPE)type;


/**
 设置同步时间

 @return 同步时间指令
 */
+ (NSData *)setSynchronizationTime;


/**
 校验设备，并自动修复

 @return 校验设备指令
 */
+ (NSData *)checkAndRepairDevice;

//+ (BOOL)canBrake;

@end
