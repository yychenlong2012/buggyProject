//
//  CWDeviceManager.h
//  CarWins
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 CarWins Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AYDeviceManager : NSObject

/**
 *  获取屏幕的大小
 *
 *  @return 屏幕的大小
 */
+ (CGSize)currentScreenSize;

/**
 *  获取操作系统的版本号
 *
 *  @return 操作系统的版本号
 */
+ (CGFloat)currentVersion;

/**
 *  获取设备的型号
 *
 *  @return 设备的型号
 */
+ (NSString *)currentModel;

/**
 *  获取设备的名称
 *
 *  @return 设备的名称  such as "Saxue Yang的iPhone"
 */
+ (NSString *)currentName;

/**
 *  获取设备的UUID such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
 *  App在用户设备上安装后将会获得一个唯一的UUID,当用户卸载App后重新安装将会重新生成一个唯一的UUID
 *
 *  @return 设备的UUID
 */
+ (NSString *)currentUUID;

/**
 *  获取设备的详细型号
 *
 *  @return 设备型号 如: iPhone 6 Plus
 */
+ (NSString *)deviceModel;

/**
 *  获取iPhone本机ip
 *
 *  @return ip
 */
+ (NSString *)currentIp;

/**
 *  获取当前App版本号
 *
 *  @return App版本号
 */
+ (NSString *)currentAppVersion;

/**
 *  获取当前App Build号
 *
 *  @return APP build号
 */
+ (NSString *)currentAppBuild;


@end
