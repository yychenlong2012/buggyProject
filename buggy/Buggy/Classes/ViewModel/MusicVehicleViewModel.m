//
//  MusicVehicleViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/5.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicVehicleViewModel.h"

@implementation MusicVehicleViewModel

- (void)setDelegate:(id)delegate{
    BLEMANAGER.delegate = delegate;
}

- (void)clearDelegate{
    BLEMANAGER.delegate = nil;
}

- (void)getDeviceLinkMode{
    
    Byte byte[] = {0x55,0xaa,0x00,0x01,0x04,0xfb};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}


- (void)getCurrentMode{

    Byte byte[] = {0x55,0xaa,0x00,0x01,0x03,0xfc}; // 获取当期的设备类型
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}


- (void)selectDeviceMode:(NSString *)deviceName{
    
    Byte modeByte;
    if ([deviceName containsString:@"SD"]) {
        modeByte = 0x01;
    }else if ([deviceName containsString:@"USB"]){
        modeByte = 0x02;
    }else if ([deviceName containsString:@"蓝牙(BlueTooth)"]){
        modeByte = 0x03;
    }else{
        modeByte = 0x00;
    }
    Byte byte[] = {0x55,0xaa,0x01,0x01,0x02,modeByte,(0 - (4 + modeByte))};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    [BLEMANAGER writeValueForPeripheral:data];
}

@end
