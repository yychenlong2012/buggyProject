//
//  CarA4DetailViewController.h
//  Buggy
//
//  Created by goat on 2018/5/8.
//  Copyright © 2018年 ningwu. All rights reserved.
//
#import "BaseVC.h"

@interface CarA4DetailViewController : BaseVC
@property (nonatomic,copy) NSString *peripheralUUID;
@property (nonatomic,strong) NSString *deviceName;

@property (nonatomic,strong) UILabel *naviLabel;   //导航栏标题

@property (nonatomic,assign) NSInteger fuctionType;  //界面类别  A6的界面类别为3   牛顿为2

@property (nonatomic,strong) DeviceModel *deviceModel;  //

//解除绑定
-(void)deviceUnBound;
@end
