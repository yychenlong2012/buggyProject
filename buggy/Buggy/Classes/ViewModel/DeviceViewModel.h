//
//  DeviceViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

typedef void(^UploadFinish)(BOOL success,NSError *error);
typedef void(^DeleteFinish)(BOOL success,NSError *error);

@interface DeviceViewModel : NSObject

/**
 生成数据模型
 
 @param dic
 @return
 */

+ (DeviceModel *)compositeDeviceModel:(NSDictionary *)dic;

/**
 添加绑定的设备

 @param model 要添加的设备模型
 @param uploadFinish 完成的回调
 */
+ (void)updatecSelectedDevice:(DeviceModel *)model finish:(UploadFinish)uploadFinish;


/**
 更新设备名称

 @param name 设备名称
 @param UUID uuid
 
 @param uploadFinish
 */
+ (void)updatecDeviceName:(NSString *)name UUID:(NSString *)UUID finish:(UploadFinish )uploadFinish;

/**
 删除当前设备

 @param model 要删除的设备
 @param uploadFinish 完成的回调
 */
+ (void)deleteSelectedDeviceUUID:(NSString *)bluetoothUUID finish:(DeleteFinish)deleteFinish;

@end
