//
//  DeviceModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

@property (nonatomic ,assign) BOOL bluetoothbind;

@property (nonatomic ,assign) NSInteger devicetype; // 0： 老车  1： 新车  404 未知的设备   已经废弃

@property (nonatomic ,copy) NSString *bluetoothdeviceid;   //安卓用到的mac地址

@property (nonatomic ,copy) NSString *bluetoothuuid;       //iOS用到的UUID

@property (nonatomic ,copy) NSString *bluetoothname;

@property (nonatomic ,copy) NSString *deviceidentifier;  //标识  最新添加的用于判断车型的标识

@property (nonatomic ,copy) NSString *fuctiontype; //推车对应的界面类型

@property (nonatomic ,copy) NSString *company; /**公司名称<*/

@property (nonatomic ,copy) NSString *objectid;

-(NSString *)getTheDeviceName;  //获得该车的名字
@end


//{
//    bluetoothbind = 1;
//    bluetoothdeviceid = "";
//    bluetoothname = 0;
//    bluetoothuuid = "3B13C3AA-06DD-07E6-C860-EFA21DD7ED50";
//    company = 3Pomelos;
//    deviceidentifier = "Pomelos_A3";
//    devicetype = 1;
//    fuctiontype = 1;
//    objectid = 1134;
//    }
