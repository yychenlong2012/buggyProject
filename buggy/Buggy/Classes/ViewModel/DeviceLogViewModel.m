//
//  DeviceLogViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/19.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceLogViewModel.h"

@implementation DeviceLogViewModel

+ (void)uploadDeviceRepairLog:(NSDictionary *)logDic completeHander:(CompleteDataHander )completeHander{
    
    NSString *bluetoothUUID = logDic[@"bluetoothUUID"];
    NSString *repairInfo = logDic[@"repairInfo"];
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query  = [AVQuery queryWithClassName:@"DeviceHardwareInfo"];
    [query whereKey:@"createdAt" equalTo:[NSDate date]];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        
        if (!object) {
            object = [AVObject objectWithClassName:@"DeviceHardwareInfo"];
            [object setObject:user forKey:@"user"];
            [object setObject:nil forKey:@"logInfo"];
            [object setObject:bluetoothUUID forKey:@"bluetoothUUID"];
            [object setObject:repairInfo forKey:@"repairInfo"];
            [object setObject:logDic[@"logType"] forKey:@"logType"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completeHander) {
                    completeHander(succeeded,error);
                }
            }];
        }

    }];
  
}

+ (void)uploadDeviceNormalLog:(NSDictionary *)logDic completeHander:(CompleteDataHander)completeHander{
    
    NSString *bluetoothUUID = logDic[@"bluetoothUUID"];
    NSString *logInfo = logDic[@"logInfo"];
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query  = [AVQuery queryWithClassName:@"DeviceHardwareInfo"];
    [query whereKey:@"createdAt" equalTo:[NSDate date]];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if (!object) {
            object = [AVObject objectWithClassName:@"DeviceHardwareInfo"];
            [object setObject:user forKey:@"user"];
            [object setObject:logInfo forKey:@"repairInfo"];
            [object setObject:logDic[@"logType"] forKey:@"logType"];
            [object setObject:nil forKey:@"logInfo"];
            [object setObject:bluetoothUUID forKey:@"bluetoothUUID"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completeHander) {
                    completeHander(succeeded,error);
                }
            }];
        }
    }];
}

//+ (void)find{
//    
//    AVQuery *query  = [AVQuery queryWithClassName:@"DeviceUpdateFile"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        DLog(@"-------%@",objects);
//    }];
//}

@end
