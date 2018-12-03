//
//  CarA3DetailsViewController.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
//@class BlueToothManager;


@interface CarA3DetailsViewController : BaseVC

@property (nonatomic, strong) CBPeripheral *canConnectPeripheral;    //需要连接的蓝牙设备
@property (nonatomic ,copy) NSString *peripheralUUID;
@property (nonatomic ,copy) NSString *name;

@property (nonatomic,strong) NSString *deviceName;

@property (nonatomic,strong) UILabel *naviLabel;   //导航栏标题
@property (nonatomic,strong) DeviceModel *deviceModel;  //
- (void)connectionBLE:(id)per;
@end
