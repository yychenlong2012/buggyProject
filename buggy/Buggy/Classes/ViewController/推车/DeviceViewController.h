//
//  DeviceViewController.h
//  Buggy
//
//  Created by 孟德林 on 2017/3/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseVC.h"
@class DeviceModel;

@interface DeviceViewController : BaseVC

@property (nonatomic , strong)NSMutableArray *peripherals;   //扫描到的设备

//@property (nonatomic , strong)NSMutableArray<DeviceModel *> *bandPeripherals; //已经绑定的设备



@end
