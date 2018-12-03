//
//  BLEA4API.h
//  Buggy
//
//  Created by goat on 2018/5/8.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEA4API : NSObject

//数据监听准备完毕
+ (NSData *)notifySuccess;
//获取出行数据
+ (NSData *)getDeviceTravelData;
//刹车状态获取
+ (NSData *)getStateOfTheBrake;
//一键防盗打开
+ (NSData *)openSafety;
//一键防盗关闭
+ (NSData *)closeSafety;
//电量获取
+ (NSData *)getDeviceElectric;
//一键关机
+ (NSData *)closeDevice;
//检测修复
+ (NSData *)DeviceRepair;
//蓝牙数据获取
+ (NSData *)getDeviceData;
//时间同步
+ (NSData *)synchronizationTime;
//获取固件版本号
+ (NSData *)getDeviceVersion;

//设置刹车模式
//关闭电子刹车
+ (NSData *)closeBrake;
//自动刹车 松手即刹
+ (NSData *)setAutoBrake;
//智能刹车
+ (NSData *)setSmartBrake;

//获取推行数据
+ (NSData *)getPushData:(NSDate *)date;

//逐条获取推行数据
+ (NSData *)getPushDataOnce:(NSDate *)date;

//读取一条剩余推行数据
+ (NSData *)getSurplusPushData;

//获取环境温度
+ (NSData *)getTemperature;

//开关提示音  otherSound暂时默认开启  num是铃声种类
+ (NSData *)setupWarningSound:(BOOL)flag1 andOtherSound:(BOOL)flag2 bellsNumber:(NSInteger)num;

//设置提示音量
+ (NSData *)setWarningVolume:(NSInteger)level;

//设置车灯  是否开启  车灯模式  1表示呼吸灯模式  0表示常亮模式
+ (NSData *)setCarLight:(BOOL)isOpen lightMode:(NSInteger)mode;

//设定系统语言
+ (NSData *)setSystemLanguage:(NSString *)language;

//设置最小的有效推行间隔   单位是秒
+ (NSData *)setupMinTrvalLength:(NSInteger)seconds;

//获取刹车次数
+ (NSData *)getBrakeNumber;

//设置刹车灵敏度
+ (NSData *)setBrakeSensitivity:(NSInteger)sensitivity;
@end
