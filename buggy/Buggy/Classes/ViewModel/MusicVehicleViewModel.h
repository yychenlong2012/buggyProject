//
//  MusicVehicleViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/5.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlueToothManager.h"

@interface MusicVehicleViewModel : NSObject

/**
 设置代理
 
 @param delegate
 */
- (void)setDelegate:(id)delegate;

/**
 清空代理
 */
- (void)clearDelegate;


/**
 获取设备上所有的mode
 */
- (void)getDeviceLinkMode;


/**
  获取设备当前mode
 */
- (void)getCurrentMode;

/**
 选择设备
 @param deviceName 设备名称
 */
- (void)selectDeviceMode:(NSString *)deviceName;


@end
