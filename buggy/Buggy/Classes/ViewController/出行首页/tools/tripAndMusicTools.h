//
//  tripAndMusicTools.h
//  Buggy
//
//  Created by goat on 2018/5/17.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"
typedef void(^deviceList)(NSArray <DeviceModel *>*deviceArray);

@interface tripAndMusicTools : NSObject

//请求已绑定的设备列表
+ (void)requestBoundedDeviceList:(deviceList)list;
//上传离线操作信息
+ (void)UploadOfflineOperationData;
//下载设备类型列表   测试版没有这张表
+ (void)downloadDeviceTypeList;
//检测新版本
+ (void)checkVersion;
@end
