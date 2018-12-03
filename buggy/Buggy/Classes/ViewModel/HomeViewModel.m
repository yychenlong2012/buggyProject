//
//  HomeViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/1/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "HomeViewModel.h"
#import <AVCloud.h>
#import "WNJsonModel.h"
#import "DeviceDataBase.h"


@implementation HomeViewModel

+ (void)requestDeviceList:(RequestFinish)finish{
    __block NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"DeviceUUIDList"];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query setMaxCacheAge:365 * 24 * 3600];
    [query whereKey:@"post" equalTo:user];
    [query whereKeyExists:@"bluetoothUUID"];
    [query orderByDescending:@"updatedAt"];
    [query selectKeys:@[@"bluetoothUUID",@"bluetoothBind",@"deviceType",@"bluetoothName",@"deviceIdentifier"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects > 0) {
            for (AVObject *ob in objects) {
                DeviceModel *deviceModel = [WNJsonModel modelWithDict:ob[@"localData"] className:@"DeviceModel"];
                [datas addObject:deviceModel];
            }
            if (finish) {
                finish(datas,error);
            }
        }
    }];
}

@end
