//
//  DeviceModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceModel.h"

@implementation DeviceModel

//可以在这里设置默认值，可以在生成模型时将数据转化成想要的格式
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if (oldValue == nil || [oldValue isKindOfClass:[NSNull class]]) {
        if([property.name isEqualToString:@"devicetype"]){
            return 0;
        }else if([property.name isEqualToString:@"bluetoothdeviceid"]){
            return @"";
        }else if([property.name isEqualToString:@"bluetoothuuid"]){
            return @"";
        }else if([property.name isEqualToString:@"bluetoothname"]){
            return @"";
        }else if([property.name isEqualToString:@"deviceidentifier"]){
            return @"";
        }else if([property.name isEqualToString:@"fuctiontype"]){
            return @"";
        }else if([property.name isEqualToString:@"company"]){
            return @"";
        }else if([property.name isEqualToString:@"objectid"]){
            return @"";
        }
    }
    return oldValue;
}

-(NSString *)getTheDeviceName{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"deviceTypeList.plist"];
    NSArray  *deviceTypeList = [NSArray arrayWithContentsOfFile:filePath];
    
    NSString *deviceName;
    //有名字则直接使用名字
    if (self.bluetoothname != nil && self.bluetoothname.length>0) {
        return self.bluetoothname;
    }
    //有设备标识 则根据设备标识判断
    if (self.deviceidentifier != nil && self.deviceidentifier.length > 0) {
        for (NSDictionary *dict in deviceTypeList) {
            if ([self.deviceidentifier isEqualToString:dict[@"deviceIdentifier"]]) {
                return dict[@"bluetoothName"];
            }
        }
    }
    //老版本的判断
    switch (self.devicetype) {
        case 0:
            deviceName = @"3POMELOS_G";
            break;
        case 1:
            deviceName = @"3POMELOS_A3_BLE";
            break;
        case 2:
            deviceName = @"CBchair111";
            break;
        default:
            deviceName = @"未知设备";
            break;
    }
    self.bluetoothname = deviceName;
    
    return deviceName;
}

@end
