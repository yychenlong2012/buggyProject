//
//  DeviceViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceViewModel.h"

@implementation DeviceViewModel

//这里确定车类型
+ (DeviceModel *)compositeDeviceModel:(NSDictionary *)dic{
    
    DeviceModel *model = [[DeviceModel alloc] init];
    model.bluetoothuuid = dic[@"UUID"];
    NSString *name = dic[@"name"];
    if ([name containsString:@"3POMELOS_A3"]) { 
        model.devicetype = 1;
    }else if ([name containsString:@"3POMELOS_G"]) {
        model.devicetype = 0;
    }else{
        model.devicetype = 404;
    }
    model.bluetoothbind = YES;
    model.bluetoothdeviceid = @"";
    return model;
}

//添加或更新设备
+ (void)updatecSelectedDevice:(DeviceModel *)model finish:(UploadFinish )uploadFinish{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVUser *user = [AVUser currentUser];
        AVQuery *query = [AVQuery queryWithClassName:@"DeviceUUIDList"];
        [query whereKey:@"post" equalTo:user];
        [query whereKey:@"bluetoothUUID" equalTo:model.bluetoothuuid];
        AVObject *object = nil;
        NSError *error;
        object = [query getFirstObject:&error];
        if (object) { //更新
            [object setObject:@(model.bluetoothbind) forKey:@"bluetoothBind"];
            [object setObject:model.bluetoothdeviceid forKey:@"bluetoothDeviceId"];
            [object setObject:model.bluetoothuuid forKey:@"bluetoothUUID"];
            [object setObject:@(model.devicetype) forKey:@"deviceType"];
            
            [object setObject:model.fuctiontype forKey:@"fuctionType"];
            [object setObject:kStringConvertNull(model.deviceidentifier) forKey:@"deviceIdentifier"];
            [object setObject:model.company forKey:@"company"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (uploadFinish) {
                    uploadFinish(succeeded,error);
                }
            }];
            return;
        }else{ //添加
            object = [AVObject objectWithClassName:@"DeviceUUIDList"];
            [object setObject:user forKey:@"post"];
            [object setObject:@(model.bluetoothbind) forKey:@"bluetoothBind"];
            [object setObject:model.bluetoothdeviceid forKey:@"bluetoothDeviceId"];
            [object setObject:model.bluetoothuuid forKey:@"bluetoothUUID"];
            [object setObject:@(model.devicetype) forKey:@"deviceType"];
            
            [object setObject:model.fuctiontype forKey:@"fuctionType"];
            [object setObject:kStringConvertNull(model.deviceidentifier) forKey:@"deviceIdentifier"];
            [object setObject:model.company forKey:@"company"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (uploadFinish) {
                    uploadFinish(succeeded,error);
                }
            }];
        }
    });
}

//修改设备名
+ (void)updatecDeviceName:(NSString *)name UUID:(NSString *)UUID finish:(UploadFinish )uploadFinish{
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"DeviceUUIDList"];
    [query whereKey:@"post" equalTo:user];
    [query whereKey:@"bluetoothUUID" equalTo:UUID];
    AVObject *object = nil;
    NSError *error;
    object = [query getFirstObject:&error];
    if (object) {
        [object setObject:name forKey:@"bluetoothName"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (uploadFinish) {
                uploadFinish(succeeded,error);
            }
        }];
    }
}

+ (void)deleteSelectedDeviceUUID:(NSString *)bluetoothUUID finish:(DeleteFinish)deleteFinish{
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"DeviceUUIDList"];
    [query whereKey:@"post" equalTo:user];
    [query whereKey:@"bluetoothUUID" equalTo:bluetoothUUID];
    AVObject *object = nil;
    NSError *error;
    object = [query getFirstObject:&error];
    if (object) {
        [object deleteEventuallyWithBlock:^(id object, NSError *error) {
//            DLog(@"%@",object);
            if (object && !error) {
                deleteFinish(YES,error);
            }
            if (error) {
                deleteFinish(NO,error);
            }
        }];
    }
    if (!object) {
        if (deleteFinish) {
            deleteFinish(YES,error);
        }
    }
}



@end
