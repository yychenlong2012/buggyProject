//
//  DryFootApi.m
//  Buggy
//
//  Created by goat on 2019/2/22.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import "DryFootApi.h"

//干脚器

@implementation DryFootApi

//获取蓝牙信息
+ (NSData *)getDeviceData{
    Byte byte[] = {0x55,0xAA,0X00,0x0D,0x01,0-(0x0D+0x01)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    NSLog(@"发送数据 %@",data);
    return data;
}

//体重体脂数据  注意这条指令是用于停止蓝牙发送指令
+ (NSData *)getWeightAndFatData{
    Byte byte[] = {0x55,0xAA,0X00,0x0D,0x02,0-(0x0D+0x02)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//重量单位设置
+ (NSData *)setWeightUnit:(NSInteger)unit{
    Byte u = 0x00;
    switch (unit) {
        case 1:
            u = 0x00;   //KG
            break;
        case 2:
            u = 0x40;   //斤
            break;
        case 3:
            u = 0x80;   //磅
            break;
        default:
            break;
    }
    Byte byte[] = {0x55,0xAA,0X01,0x0D,0x03,u,0-(1+0x0D+0x03+u)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//风力档位设置
+ (NSData *)setWindLevel:(NSInteger)level{
    if (level >= 0 && level <= 11) {
        Byte u = 0x00 + level;
        if (level == 11) {   //最高档是0xff
            u = 0xff;
        }
        Byte byte[] = {0x55,0xAA,0X01,0x0D,0x04,u,0-(1+0x0D+0x04+u)};
        NSData *data = [[NSData alloc] initWithBytes:byte length:6];
        return data;
    }else{
        return nil;
    }
}

@end
