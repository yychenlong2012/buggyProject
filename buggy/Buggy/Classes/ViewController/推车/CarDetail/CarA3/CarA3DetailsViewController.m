//
//  CarA3DetailsViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3DetailsViewController.h"
#import "RepairViewController.h"
#import "CarA3HeaderView.h"
#import "CarA3StatusTableViewCell.h"
#import "CarA3SetTableViewCell.h"
#import "FunctionViewController.h"
#import "AlertManager.h"
#import "BabyModel.h"
#import "BlueToothManager.h"
#import "BLEDataCallBackAPI.h"
#import "NSDate+travelDate.h"
#import "AYInstructionsViewController.h"
#import "NetWorkStatus.h"
#import "pushDataAPI.h"
#import "CLImageView.h"
@interface CarA3DetailsViewController ()<UITableViewDelegate,UITableViewDataSource,BlueToothManagerDelegate,BLEDataCallBackAPIDelegate,UIAlertViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) CarA3HeaderView *carA3HeaderView; 
@property (nonatomic ,strong) BLEDataCallBackAPI *bleDataCallBackAPI;
@property (nonatomic ,assign) BOOL isGuardOpen;          //一键防盗是否开启  或者是未刹车状态
@property (nonatomic ,strong) UIView *bgView;            //引导页背景
@property (nonatomic ,strong) UIView *DeviceUpdateView;  //固件升级提示view
@property (nonatomic ,assign) BOOL haveNewVersion;       //有新版本
@property (nonatomic ,strong) UIView *naviView;             //自定义导航栏背景view

@property (nonatomic,strong) CarA3StatusTableViewCell *oneCell;
@property (nonatomic,strong) CarA3SetTableViewCell *twoCell;
@property (nonatomic,strong) CarA3SectionView *twoSectionHeader;
@property (nonatomic,strong) UIView *lockHUD;      //一键防盗提示
@property (nonatomic,strong) NSString *carBattery;    //推车电量
@end

@implementation CarA3DetailsViewController
- (void)dealloc{   

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BLEMANAGER.delegate = self;
    if ([self bleConnecting] == NO) {
        NSUUID *justuuid = [[NSUUID UUID]initWithUUIDString:self.peripheralUUID];
        CBPeripheral * justperi =[[BLEMANAGER.centralManager  retrievePeripheralsWithIdentifiers:@[justuuid]] firstObject];
        [self connectionBLE:justperi];
    }
}

//连接蓝牙
- (void)connectionBLE:(id)per{
    BLEMANAGER.delegate = self;
    if (![self bleConnecting]) {   //未连接则连接蓝牙
        [BLEMANAGER connectPeripheralDevice:per];
    }
    [MainModel model].bluetoothUUID = _peripheralUUID;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.naviView];
    _bleDataCallBackAPI = [[BLEDataCallBackAPI alloc] init];
    _bleDataCallBackAPI.delegate = self;
    BLEMANAGER.delegate = self;
    
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.carA3HeaderView;
    
    __weak typeof(self) weakself = self;
    MJRefreshGifHeader * header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakself requestNetworkData];             //刷新头部数据
    }];
    [self setRefresh:header];                     //设置header  不用看
    self.tableView.mj_header = header;
    [self requestNetworkData];                     //请求头部数据
//    [self setupNav];
    
    //加载页面时 如果蓝牙已经开启 那么直接请求设备状态
    if ([self bleConnecting]) {
        [_bleDataCallBackAPI sendOrderToAchieveCurrentDeviceStatus];  //请求设备状态
    }else{
        if (BLEMANAGER.centralManager.state != CBManagerStatePoweredOn) {
            [self showAlertMessage:NSLocalizedString(@"请开启手机蓝牙", nil)];
        }
    }
    
    //第一次启动引导
    [self performSelector:@selector(version3) withObject:nil afterDelay:2];
}

//提示作用
-(void)version3{
    //获取推车固件版本
    NSString *version = kStringConvertNull(KUserDefualt_Get(KA3Version));
    NSArray *array = [version componentsSeparatedByString:@"."];
    NSInteger versionNum = 0;
    if (array.count == 3) {
        versionNum = [array[0] integerValue] * 100 + [array[1] integerValue] * 10 + [array[2] integerValue];
    }
    
    //1.0.3版本新特性提示
    if (versionNum >= 103) {  //版本号大于等于1.0.3
        //引导页
        NSString * isload = KUserDefualt_Get(version);
        
        if (![isload isEqualToString:@"1"]) {
            //展示引导
            UIView *bgView = [[UIView alloc] init];
            bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            bgView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-64);
            [self.view addSubview:bgView];
            self.bgView = bgView;
    
            UIImageView *imageV = [[UIImageView alloc] init];
            imageV.image = [UIImage imageNamed:@"103版本提示"];
            imageV.frame = CGRectMake(0, 0, RealWidth(321), RealHeight(237));
            imageV.center = bgView.center;
            [bgView addSubview:imageV];
            
            imageV.userInteractionEnabled = YES;
            __weak typeof(self) wself = self;
            [imageV addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                [wself.bgView removeFromSuperview];
                wself.bgView = nil;
            }];
            KUserDefualt_Set(@"1", version);
        }
    }
}

///请求头部数据
- (void)requestNetworkData{
    [NETWorkAPI requestUserTravelInfoCallback:^(id  _Nullable model, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        if (model != nil && [model isKindOfClass:[userTravelInfoModel class]] && error == nil) {
            [self.carA3HeaderView configUIWith:model];
        }
    }];
}

//- (void)setupNav{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageNamed(@"moreSet") style:UIBarButtonItemStyleDone target:self action:@selector(settting)];
//}


/**<设置下拉刷新*/
- (void)setRefresh:(MJRefreshGifHeader *)header{
    // 设置普通状态的动画图片
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    NSMutableArray *idleImages = [NSMutableArray array];
    for (int i = 1; i<=12; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%i", i]];
        if (image) {
          [idleImages addObject:image];
        }
    }
    [header setImages:idleImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (int i = 1; i<=12; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%i", i]];
            if (image) {
            [refreshingImages addObject:image];
        }
    }
    [header setImages:refreshingImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

#pragma mark --- BlueToothManagerDelegate
- (void)getValueForPeripheral{  //调用了这个方法 说明callback中有数据
    NSArray *dataArray = BLEMANAGER.deviceCallBack;
    [_bleDataCallBackAPI parserData:dataArray];     //根据蓝牙信息进行ui布局
}

-(void)didDiscoverPeripheral:(NSMutableArray<CBPeripheral *>*)peripherals{
    //判断扫描到的蓝牙里面有没有同名的
    for (CBPeripheral *per in peripherals) {
        if ([per.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
            if (BLEMANAGER.currentPeripheral == nil) {
                [BLEMANAGER connectPeripheralDevice:per];
            }
        }
    }
}

-(void)BLE_BlueToothOpen{
    [BLEMANAGER startScanBLEWithTimeout:3];
}

- (void)didDisconnectPeripheral:(NSError *)error{
    [MainModel model].bluetoothUUID = nil;
    [self.oneCell setBLEConnectStatus:NO];
    [self.twoCell setBLEConnectStatus:NO];
}

//连接成功的回调
- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    [MainModel model].bluetoothUUID = peripheral.identifier.UUIDString;
    //由于蓝牙刚连接手机时 会向手机发送一系列不必要的数据  所以这里延时1秒再请求蓝牙的状态信息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_bleDataCallBackAPI sendOrderToAchieveCurrentDeviceStatus];  //请求设备状态
        });
    });
   
    //连接蓝牙成功后 改变界面样式 打开相关功能
    [self.oneCell setBLEConnectStatus:YES];
    [self.twoCell setBLEConnectStatus:YES];
}

#pragma mark --- BLEDataCallBackAPIDelegate
//从硬件中获取参数值
- (void)deviceuploadTravel:(NSDictionary *)param{
    __weak typeof(self) wself = self;
    if ([NetWorkStatus isNetworkEnvironment]) {
        NSInteger mileage = [param[@"todayMileage"] integerValue];
        CGFloat totalMileage = [param[@"totalMileage"] floatValue];
        CGFloat averageSpeed = [param[@"averageSpeed"] floatValue];
        NSLog(@"蓝牙里程-----：%@",param);
        //上传今日里程，速度，总里程
        [NETWorkAPI uploadAverageSpeed:averageSpeed todayMileage:mileage totalMileage:totalMileage callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                //上传成功
                [self requestNetworkData];
            }
        }];
    }else{
        if (param) {
            userTravelInfoModel *cModel =  [[userTravelInfoModel alloc] init];
            cModel.todaymileage = [NSString stringWithFormat:@"%0.2f",[[param objectForKey:@"todayMileage"] floatValue]];
            cModel.totalmileage = [param objectForKey:@"totalMileage"];
            cModel.todayvelocity = [param objectForKey:@"averageSpeed"];
            [wself.carA3HeaderView configUIWith:cModel];
        }
    }
}

- (void)deviceCloseDevice:(BOOL)success{
    if (success) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"关闭成功", nil)];
        [MainModel model].bluetoothUUID = @"";
    }
    if (!success) {
        [MBProgressHUD showError:NSLocalizedString(@"关闭失败", nil)];
    }
    [self.tableView reloadData];
}

// 刹车状态
- (void)deviceBrake:(BOOL)success{
    NSLog(@"刹车状态 = %@",success ? @"已刹车" : @"未刹车");
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    CarA3StatusTableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    if (cell) {
        [cell setBrakeStatus:success];
    }
    //刹车时关闭灯光调节
    CarA3SetTableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [cell2 closeOrOpenLight:success];
}

// 设置背光调节成功
- (void)deviceSetBackLightFinish:(NSInteger )value{
    DLog(@"背光调节:%@",(value >= 0 ?@"成功":@"失败"));
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    CarA3SetTableViewCell *setCell = [self.tableView cellForRowAtIndexPath:index];
    if (setCell) {
        [setCell setBackLightProgress:value];
    }
}

// 时间同步成功
- (void)deviceSyncTime:(BOOL)success{
    DLog(@"时间同步：%@",(success?@"成功":@"失败"));
}

// 设备电量的回调
- (void)deviceBattery:(NSString *)battery{
    self.carBattery = battery;
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    CarA3StatusTableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    [cell setBattery:battery];
    [self.tableView reloadData];
}

//智能刹车是否开启
- (void)deviceBrakeOrderSuccess:(BOOL)sucess{
//    [self.oneCell setBrakeStatus:sucess];
//    [self.oneCell setCloseStatus:sucess];
    [self.oneCell isSmartBrakeOpen:sucess];
    self.twoCell.autoBrakeBtn.on = sucess;
    self.twoCell.switchBtn.enabled = sucess;
    if (sucess) {
        [MBProgressHUD showToast:NSLocalizedString(@"智能刹车开启", nil)];
    }else{
        [MBProgressHUD showToast:NSLocalizedString(@"智能刹车关闭", nil)];
    }
}

//一键防盗
- (void)deviceAntiTheftSuccess:(BOOL)sucess{
    self.isGuardOpen = sucess;
    self.twoCell.switchBtn.on = sucess;
    self.twoCell.autoBrakeBtn.enabled = !sucess;
    self.twoSectionHeader.lock.hidden = !sucess;
    if (sucess) {
        [MBProgressHUD showToast:NSLocalizedString(@"一键防盗开启", nil)];
    }else{
        [MBProgressHUD showToast:NSLocalizedString(@"一键防盗关闭", nil)];
    }
}
- (void)deviceDetailLog:(NSData *)data{
    // 上传设备正常日志
    NSString *logStr = [NSString stringWithFormat:@"%@",data];
//    NSDictionary *dic = @{@"logInfo":logStr,@"logType":@(1),@"bluetoothUUID":[BLEMANAGER.currentPeripheral.identifier UUIDString]};
    if (data.length != 0) {
        [NETWorkAPI uploadDeviceRepairData:self.deviceModel.deviceidentifier deviceAddress:@"" repair:logStr bleUUID:self.deviceModel.bluetoothuuid callback:^(BOOL success, NSError * _Nullable error) {
            
        }];
//        [DeviceLogViewModel uploadDeviceNormalLog:dic completeHander:^(BOOL success, NSError *error) {}];
    }
}

//打开关闭刹车系统
- (void)deviceCancleBrakeSystom:(BOOL)cancle{
    CarA3StatusTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell cancleBrakeStatus:cancle];
}

#pragma mark --- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{return 1;}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 2;}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CarA3StatusTableViewCellHeight;
    }
    return CarA3SetTableViewCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CarA3SectionViewHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [[CarA3SectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,CarA3SectionViewHeight ) withName:NSLocalizedString(@"推车状态", nil)];
    }
    if (section == 1) {
        if (self.twoSectionHeader == nil) {
            self.twoSectionHeader = [[CarA3SectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,CarA3SectionViewHeight ) withName:NSLocalizedString(@"推车控制", nil)];
        }
        return self.twoSectionHeader;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return self.oneCell;
    }else if(indexPath.section == 1){
        return self.twoCell;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
}


- (void)settting{
    
    if (![self.peripheralUUID isEqualToString:[MainModel model].bluetoothUUID]) {
        [self.view showMessage:NSLocalizedString(@"蓝牙未连接无法操作", nil)];
        return;
    }
    AlertManager *alert = [[AlertManager alloc] init];
    alert.haveNewVersion = self.haveNewVersion;
    alert.isGuardOpen = self.isGuardOpen;
    __weak typeof(self) wself = self;
    NSString *version = kStringConvertNull(KUserDefualt_Get(KA3Version));
    version = version.length == 0?@"V 1.0.0":version;
    [alert showFunctionList:@[@"Travel_Repair",@"修改蓝牙名称",@"固件版本",@"使用说明",@"Travel_Unbind"] titleList:@[NSLocalizedString(@"一键修复", nil),NSLocalizedString(@"修改设备名称", nil), [NSString stringWithFormat:@"%@：V  %@",NSLocalizedString(@"固件版本", nil),version],NSLocalizedString(@"使用说明", nil),NSLocalizedString(@"解除绑定", nil)] IndexBlock:^(NSInteger index) {
        // 问题检测与修复
        if (index == 0) {
            //一键防盗开启则关闭此功能
            if (self.isGuardOpen) {
                [self.view showMessage:NSLocalizedString(@"关闭一键防盗，才可一键修复哦", nil)];
            }else{
                RepairViewController *per = [[RepairViewController alloc] init];
                per.device = self.deviceModel;
                [wself.navigationController pushViewController:per animated:YES];
            }
        }
        // 解除绑定
        if (index == 4) {
            AlertManager *alert = [[AlertManager alloc] init];
            [alert showAlertMessage:NSLocalizedString(@"您将解除手机与设备的绑定，将清空本次绑定记录", nil) title:NSLocalizedString(@"提示", nil) cancle:NSLocalizedString(@"取消", nil) confirm:NSLocalizedString(@"解除绑定", nil) others:nil];
            [alert show];
            alert.indexBlock = ^(NSInteger index) {
                if (index == 1) {
//                    [[BabyModel manager] updateItemInBabyInfo:@"" key:@"bluetoothUUID" complete:^(NSString *item) {
//
//                        [MainModel model].bluetoothUUID = @"";
//                        [MainModel model].blueToothName = @"3POMELOS_L";
//                        [MainModel model].isContectDevice = NO;
//                        [BLEMANAGER cancelConnect];
//
//                    }];
//                    [DeviceViewModel deleteSelectedDeviceUUID:wself.peripheralUUID finish:^(BOOL success, NSError *error) {
//                        if (success) {
//                            //[MBProgressHUD showToast:@"解除绑定成功"];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kACCESSESEQUIPMENTLIST object:nil];
//                            [wself.navigationController popToRootViewControllerAnimated:YES];
//                        }else{
//                            [MBProgressHUD showError:NSLocalizedString(@"解绑失败",nil)];
//                        }
//                    }];
                    [NETWorkAPI deleteDeviceWithId:self.deviceModel.objectid callback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            [MBProgressHUD showToast:@"解除绑定成功"];
                            [BLEMANAGER cancelConnect];
                            [wself.navigationController popToRootViewControllerAnimated:YES];
                        }else{
                            [MBProgressHUD showError:NSLocalizedString(@"解绑失败",nil)];
                        }
                    }];
                }
            };
        }
        if (index == 1) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备新名称", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            UITextField *nameField = [alertView textFieldAtIndex:0];
            nameField.placeholder = NSLocalizedString(@"设备新名称", nil);
            nameField.keyboardType = UIKeyboardTypeDefault;
            [alertView show];
        }
        if (index == 2) {  //固件版本
            FunctionViewController *vc = [[FunctionViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (index == 3) {  //使用说明
            AYInstructionsViewController *VC = [AYInstructionsViewController new];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    typeof(self) wself = self;
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([Check DeviceName:textField.text]) {
//            [DeviceViewModel updatecDeviceName:textField.text UUID:self.peripheralUUID finish:^(BOOL success, NSError *error) {
//                [MBProgressHUD showToast:NSLocalizedString(@"修改成功", nil)];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kACCESSESEQUIPMENTLIST object:nil];
//                wself.naviLabel.text = textField.text;
//            }];
            [NETWorkAPI updateDeviceName:textField.text Id:self.deviceModel.objectid callback:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [MBProgressHUD showToast:NSLocalizedString(@"修改成功", nil)];
                    wself.naviLabel.text = textField.text;
                }
            }];
        }
    }
}

- (BOOL)bleConnecting{
    if (BLEMANAGER.currentPeripheral == nil) {    //连接的状态未连接
        return NO; // test yes             未连接蓝牙时这里会调用很多次
    }else{
        if (![[BLEMANAGER.currentPeripheral.identifier UUIDString] isEqualToString:self.peripheralUUID]) {
            return NO;
        }else{
            return YES;
        }
    }
}
#pragma mark --- Setter And Getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]  initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (CarA3HeaderView *)carA3HeaderView{
    if (_carA3HeaderView == nil) {
        _carA3HeaderView = [[CarA3HeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CarA3HeaderViewHeight)];
    }
    return _carA3HeaderView;
}

-(CarA3StatusTableViewCell *)oneCell{
    if (_oneCell == nil) {
        _oneCell = [[CarA3StatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"oneCell"];
        _oneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [_oneCell setCloseStatus:[self bleConnecting]];
        if ([self bleConnecting]) {
            [_oneCell cancleBrakeStatus:[KUserDefualt_Get(BRAKINGSTATUS) boolValue]];
        }else{
            [_oneCell cancleBrakeStatus:NO];
        }
    }
    return _oneCell;
}

-(CarA3SetTableViewCell *)twoCell{
    if (_twoCell == nil) {
        _twoCell = [[CarA3SetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"twoCell"];
        _twoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [_twoCell setBLEConnectStatus:[self bleConnecting]];   //控制按钮是否可用
        
        //以下都是点击事件的回调 向蓝牙设备发送相关指令
        __weak typeof(self) wself = self;
        // 向设备发送背光进度数据指令
        _twoCell.backLightBlock = ^(int value){
            [wself.bleDataCallBackAPI sendOrderToSetBackLight:value];
        };
        // 一键关机
        _twoCell.closeDeviceBlock = ^{
            AlertManager *alert = [[AlertManager alloc] init];
            [alert showAlertMessage:NSLocalizedString(@"关机前请确保推车处于安全状态！", nil) title:NSLocalizedString(@"提示", nil) cancle:NSLocalizedString(@"取消", nil) confirm:NSLocalizedString(@"确定", nil) others:nil];
            [alert show];
            alert.indexBlock = ^(NSInteger index) {
                if (index == 1) {
                    [wself.bleDataCallBackAPI sendOrderToCloseDevice];
                }
            };
        };
        
        //一键防盗开关
        _twoCell.switchActionBlock = ^(BOOL on) {
            if (on) {
                [wself.view addSubview:wself.lockHUD];
            }else{
                [wself.bleDataCallBackAPI sendOrderToSetCancleDeviceBrake:on];
                wself.twoSectionHeader.lock.hidden = YES;
            }
//            [wself.bleDataCallBackAPI sendOrderToSetCancleDeviceBrake:on];
        };
        //智能刹车开关
        _twoCell.cancleDeviceBrakeActionBlock = ^(UISwitch *switchBtn) {
            if (self.carBattery != nil) {   //推车已连接 并且返回了电量
                //手机电量  这里暂时不考虑手机电量
//                CGFloat iphoneBattery = [UIDevice currentDevice].batteryLevel * 100;
//                iphoneBattery = iphoneBattery > 0 ? iphoneBattery : -iphoneBattery;
                if (wself.carBattery.integerValue >= 5) {
                    [wself.bleDataCallBackAPI sendOrderToSetDeviceBrake:switchBtn.on];
                }else{  //电量过低
                    [MBProgressHUD showToastDown:NSLocalizedString(@"设备电量过低，无法进行操作", nil)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switchBtn.on = !switchBtn.on;
                    });
                }
            }
        };
    }
    return _twoCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [_naviView addSubview:naviBackImage];
        [_naviView addSubview:self.naviLabel];
        
        //设置按钮
        CLImageView *setBtn = [[CLImageView alloc] init];
        setBtn.image = ImageNamed(@"moreSet");
        setBtn.frame = CGRectMake(ScreenWidth-35, 13+statusBarH, 20, 20);
        setBtn.userInteractionEnabled = YES;
        [setBtn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself settting];
        }];
        [_naviView addSubview:setBtn];
    }
    return _naviView;
}

-(UILabel *)naviLabel{
    if (_naviLabel == nil) {
        _naviLabel = [[UILabel alloc] init];
        _naviLabel.textColor = kWhiteColor;
        _naviLabel.text = self.deviceName;
        _naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _naviLabel.textAlignment = NSTextAlignmentCenter;
        _naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
    }
    return _naviLabel;
}

-(UIView *)lockHUD{
    if (_lockHUD == nil) {
        _lockHUD = [[UIView alloc] init];
        _lockHUD.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-bottomSafeH);
        _lockHUD.backgroundColor = [UIColor colorWithMacWholeRed:0 green:0 blue:0 alpha:0.3];
        __weak typeof(_lockHUD) weakLock = _lockHUD;
        
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.frame = CGRectMake(0, 0, RealWidth(330.5), RealWidth(274));
        imageview.image = ImageNamed(@"一键防盗弹框");
        imageview.center = _lockHUD.center;
        imageview.userInteractionEnabled = YES;
        [_lockHUD addSubview:imageview];
        
        UILabel *msg = [[UILabel alloc] init];
        msg.text = @"一键防盗打开后推车将被锁住需解锁才能推行";
        msg.frame = CGRectMake(0, RealWidth(106), RealWidth(250), 100);
        msg.centerX = imageview.width/2;
        msg.numberOfLines = 0;
        msg.textAlignment = NSTextAlignmentCenter;
        msg.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        msg.textColor = [UIColor colorWithHexString:@"#333333"];
        [imageview addSubview:msg];
        
        //按钮
        UILabel *cancle = [[UILabel alloc] init];
        cancle.text = @"取消";
        cancle.textAlignment = NSTextAlignmentCenter;
        cancle.textColor = [UIColor colorWithHexString:@"#333333"];
        cancle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:22];
        cancle.frame = CGRectMake(0, RealWidth(274)-48, imageview.width/2, 48);
        cancle.userInteractionEnabled = YES;
        [imageview addSubview:cancle];
        __weak typeof(self) wself = self;
        [cancle addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakLock removeFromSuperview];
            wself.twoCell.switchBtn.on = NO;
            wself.twoSectionHeader.lock.hidden = YES;
        }];
        
        UILabel *open = [[UILabel alloc] init];
        open.text = @"打开";
        open.textAlignment = NSTextAlignmentCenter;
        open.textColor = [UIColor colorWithHexString:@"#E45A6F"];
        open.font = [UIFont fontWithName:@"PingFangSC-Regular" size:22];
        open.frame = CGRectMake(imageview.width/2, RealWidth(274)-48, imageview.width/2, 48);
        open.userInteractionEnabled = YES;
        [imageview addSubview:open];
        [open addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakLock removeFromSuperview];
            [wself.bleDataCallBackAPI sendOrderToSetCancleDeviceBrake:YES];
            wself.twoSectionHeader.lock.hidden = NO;
        }];
        
        UIView *line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:@"#ECECEC"];
        line1.frame = CGRectMake(0, RealWidth(274)-48, imageview.width, 1);
        [imageview addSubview:line1];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor colorWithHexString:@"#ECECEC"];
        line2.frame = CGRectMake(imageview.width/2, RealWidth(274)-48, 1, 48);
        [imageview addSubview:line2];
    }
    return _lockHUD;
}

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
@end
