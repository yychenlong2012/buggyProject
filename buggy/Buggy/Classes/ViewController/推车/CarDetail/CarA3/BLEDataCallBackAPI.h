//
//  BLEDataCallBackAPI.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"

@protocol BLEDataCallBackAPIDelegate <NSObject>

@optional
/**
 上传设备行程信息

 @param parm 设置字典信息
 */
- (void)deviceuploadTravel:(NSDictionary *)param;


///**
// 设备上传修复信息
//
// @param repairInfo 修复信息
// */
//- (void)deviceuploadRepairInfo:(NSString *)repairInfo;


/**
 设备关闭回调(成功改变当前界面的状态)

 @param success yes / no
 */
- (void)deviceCloseDevice:(BOOL)success;


/**
 刹车状态的回调

 @param success yes 刹车状态  /  no 解刹状态
 */
- (void)deviceBrake:(BOOL)success;


/**
 设备刹车成功

 @param sucess 成功
 */
- (void)deviceBrakeOrderSuccess:(BOOL)sucess;

/**
 设备防盗成功
 
 @param sucess 成功
 */
- (void)deviceAntiTheftSuccess:(BOOL)sucess;
/**
 设备电量的回调

 @param battery 设备电量
 */
- (void)deviceBattery:(NSString *)battery;


/**
 修复完成的回调

 @param success 成功
 */
- (void)deviceRepairFinish:(NSData *)repairData;


/**
 从机数据获取

 @param data 获取的数据
 */
- (void)deviceDetailLog:(NSData *)data;
/**
 设置背光的回调

 @param success 回调成功
 */
- (void)deviceSetBackLightFinish:(NSInteger )value;


/**
 同步时间的回调

 @param success
 */
- (void)deviceSyncTime:(BOOL)success;


/**
 是否取消刹车系统

 @param destroy 接受来自底层设备的字节判断
 */
- (void)deviceCancleBrakeSystom:(BOOL)cancle;

@end


@interface BLEDataCallBackAPI : NSObject

@property (nonatomic ,weak) id<BLEDataCallBackAPIDelegate> delegate;

/**
 获取当前设备的所有起始状态（今日平均时速、今日里程、总里程、刹车状态、电量获取、版本号、背光起始状态）
 */
- (void)sendOrderToAchieveCurrentDeviceStatus;

/**
 设备刹车

 @param brake yes 刹车  /  no 解除刹车
 */
- (void)sendOrderToSetDeviceBrake:(BOOL)brake;



/**
 设置刹车是否开启

 @param brake 刹车是否开启
 */
- (void)sendOrderToSetCancleDeviceBrake:(BOOL)brake;

/**
 关闭设备
 */
- (void)sendOrderToCloseDevice;


/**
 一键修复设备
 */
- (void)sendOrderToRepair;


/**
 设置背光
 */
- (void)sendOrderToSetBackLight:(int)lightNum;


/**
 同步时间
 */
- (void)sendorderToSyncTime;


/**
 处理回调数据

 @param dataArray 回调数据
 */
- (void)parserData:(NSArray *)dataArray;

@end
