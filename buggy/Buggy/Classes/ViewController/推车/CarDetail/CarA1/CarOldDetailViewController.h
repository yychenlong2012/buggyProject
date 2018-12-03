//
//  CarA1DetailViewController.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface CarOldDetailViewController : BaseVC

@property (nonatomic ,copy) NSString *peripheralUUID;
@property (nonatomic ,strong) CBPeripheral *peripheral;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) UILabel *naviLabel;   //导航栏标题
@property (nonatomic,strong) DeviceModel *deviceModel;  //
- (void)connectionBLE:(id)per;

@end
