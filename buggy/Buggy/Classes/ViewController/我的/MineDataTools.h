//
//  MineDataTools.h
//  Buggy
//
//  Created by goat on 2018/5/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

@interface MineDataTools : NSObject

+(NSInteger)getSelectedMusicCount;  //获取收藏音乐数目
+(NSInteger)getDownloadMusicCount;  //获取下载音乐数目

//+(void)requestDeviceListWithBlock:(void(^)(NSArray <DeviceModel *>* modelArray))block;
@end
