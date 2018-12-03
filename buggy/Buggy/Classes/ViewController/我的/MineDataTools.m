//
//  MineDataTools.m
//  Buggy
//
//  Created by goat on 2018/5/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MineDataTools.h"
#import "PreferenceDataBase.h"
#import "DownLoadDataBase.h"
#import "HomeViewModel.h"

@implementation MineDataTools

+(NSInteger)getSelectedMusicCount{
    PreferenceDataBase *dataBase = [[PreferenceDataBase alloc] init];
    return [dataBase selectAllDatas].count;
}

+(NSInteger)getDownloadMusicCount{
    DownLoadDataBase *dataBase = [[DownLoadDataBase alloc] init];
    return [dataBase selectAllDatas].count;
}

+(void)requestDeviceListWithBlock:(void (^)(NSArray<DeviceModel *> * modelArray))block{
    // 网络获取所有上传过的蓝牙设备
    [HomeViewModel requestDeviceList:^(NSArray *list, NSError *error) {
        block(list);
    }];
}

@end
