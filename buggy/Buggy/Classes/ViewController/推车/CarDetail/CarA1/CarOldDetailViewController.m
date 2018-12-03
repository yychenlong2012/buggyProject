//
//  CarA1DetailViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarOldDetailViewController.h"
#import "RepairViewController.h"
#import "CarA3HeaderView.h"
#import "CarOldStatusTableViewCell.h"
#import "CarOldAverageSpeedTableViewCell.h"
#import "AlertManager.h"
#import "BabyModel.h"
#import "BlueToothManager.h"
#import "DeviceViewModel.h"
#import "CarDetailsViewModel.h"
#import "BLEDataParserAPI.h"
#import "BabyStrollerManager.h"
#import "CacheManager.h"
#import "HealthModel.h"
#import "NSDate+travelDate.h"
#import "CLImageView.h"

@interface CarOldDetailViewController ()<UITableViewDelegate,UITableViewDataSource,BlueToothManagerDelegate,BLEDataParserDelegate,UIAlertViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) CarA3HeaderView *carA3HeaderView;
@property (nonatomic ,strong) NSString *babyWeight;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation CarOldDetailViewController{
    
    BLEDataParserAPI *_bleDataParserAPI;
    CarOldStatusTableViewCell *_oldStatusCell;
    CarOldAverageSpeedTableViewCell *_oldASCell;
}

- (void)dealloc{
    NSLog(@"CarOldDetailViewController  dealloc");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BLEMANAGER.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (![self bleConnecting]) {
        //[MBProgressHUD showToastUp:@"当前设备未连接"];
    }else{
       [MainModel model].bluetoothUUID = _peripheralUUID;
    }
}

- (void)connectionBLE:(id)per{
    if (![self bleConnecting]) {   //没有连接
       [BLEMANAGER connectPeripheralDevice:per];
    }
    [MainModel model].bluetoothUUID = _peripheralUUID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    _bleDataParserAPI = [BLEDataParserAPI shareInstance];
    _bleDataParserAPI.delegate = self;
    BLEMANAGER.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.carA3HeaderView;
    __weak typeof(self) weakself = self;
    MJRefreshGifHeader * header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakself requestNetworkDataShowHUD:YES];
    }];
    [self setRefresh:header];
    self.tableView.mj_header = header;
    [self requestNetworkDataShowHUD:YES];
    if ([self bleConnecting]) {
        [BLEMANAGER startReceiveData];
    }
}

- (void)requestNetworkDataShowHUD:(BOOL)ShowHUD{
//    CarKcalModel *model = [[CarKcalModel alloc] init];
//    model.parentsWeight = [NSString stringWithFormat:@"%@",[[AVUser currentUser] objectForKey:@"weight"]];
//
//    AVQuery *query = [AVQuery queryWithClassName:@"UserTravelInfo"];
//    [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//    [query selectKeys:@[@"todayMileage",@"totalMileage",@"todayCalories",@"totalCalories"]];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        [self.tableView.mj_header endRefreshing];
//        if (error == nil && object) {
//            model.parentsTodayKcal = [NSString stringWithFormat:@"%ld",[object[@"todayCalories"] integerValue]];
//            model.parentsTotalKcal = [NSString stringWithFormat:@"%ld",[object[@"totalCalories"] integerValue]];
//            model.todayMilage = [NSString stringWithFormat:@"%0.2f",[object[@"todayMileage"] floatValue]/1000.0];
//            model.totalMilage = [NSString stringWithFormat:@"%ld",[object[@"totalMileage"] integerValue]];
//            [self.carA3HeaderView configUIWith:model];
//        }
//    }];
    
    [NETWorkAPI requestUserTravelInfoCallback:^(id  _Nullable model, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        if (model != nil && [model isKindOfClass:[userTravelInfoModel class]] && error == nil) {
            [self.carA3HeaderView configUIWith:model];
        }
    }];
}

//设置下拉刷新
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

#pragma mark --- 蓝牙 DelegateMethend
-(void)didDiscoverPeripheral:(NSSet *)Peripherals
{   //尝试自动连接推车
    for (CBPeripheral *per in Peripherals) {
        //这里之所以选下标0  因为设备是通过绑定时间排序的，最先绑定的一定是最近的设备
        if ([self.peripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString] && BLEMANAGER.currentPeripheral == nil) {
            [BLEMANAGER connectPeripheralDevice:per];
            break;
        }
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    [BLEMANAGER startReceiveData];  //监听特征值 推车将反馈数据给手机
    [MainModel model].isContectDevice = YES;
    [MainModel model].bluetoothUUID = peripheral.identifier.UUIDString;
    [self.tableView reloadData];
}

- (void)didDisconnectPeripheral:(NSError *)error{
    [MainModel model].isContectDevice = NO;
    [MainModel model].bluetoothUUID = nil;
    [self.tableView reloadData];
}

//接收到数据
- (void)receiveData:(NSString *)data{
    NSLog(@"高景观数据 %@",data);
    //根据数据展示界面
    [_bleDataParserAPI G_parserData:data];
}

#pragma mark --- BLEDataParserDelegate 高景观车的代理方法
//上传总里程数据到后台
- (void)G_postTravel:(NSDictionary *)parm{
//    __weak typeof(self) wself = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parm];
    [dic setObject:[BLEMANAGER.currentPeripheral.identifier UUIDString] forKey:@"bluetoothUUID"];
//    [BabyStrollerManager postA1Travel:dic complete:^(NSDictionary *dic, BOOL success) {
//        [wself requestNetworkDataShowHUD:NO];
//    }];
    
    CGFloat todayMileage = [parm[@"todayMileage"] floatValue];
    CGFloat totalMilage = [parm[@"totalMileage"] floatValue];
    CGFloat todayVelocity = [parm[@"averageSpeed"] floatValue];
    [NETWorkAPI uploadAverageSpeed:todayVelocity todayMileage:todayMileage*1000 totalMileage:totalMilage callback:^(BOOL success, NSError * _Nullable error) {
        
    }];
    
    
//    NSInteger todayMileage = [parm[@"todayMileage"] integerValue];
//    if (todayMileage > 0) {
//        //上传到新表 每日数据
//        AVQuery *query = [AVQuery queryWithClassName:@"TravelDataWithDay"];
//        [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//        [query whereKey:@"travelDate" equalTo:[NSDate getCurrentDate]];
//        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//            if (error == nil && object) {
//                [object setObject:@(todayMileage) forKey:@"mileage"];
//                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                    if (succeeded && error == nil) {
//                        [wself requestNetworkDataShowHUD:NO];
//                    }
//                }];
//            }else{
//                if (error.code == 101) {
//                    AVObject *obj = [AVObject objectWithClassName:@"TravelDataWithDay"];
//                    [obj setObject:[AVUser currentUser] forKey:@"userId"];
//                    [obj setObject:[NSDate getCurrentDate] forKey:@"travelDate"];
//                    [obj setObject:@(todayMileage) forKey:@"mileage"];
//                    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                        if (succeeded && error == nil) {
//                            [wself requestNetworkDataShowHUD:NO];
//                        }
//                    }];
//                }
//            }
//        }];
//    }
    
    //上传总里程 今日里程 速度
//    CarKcalModel *model = [[CarKcalModel alloc] init];
//    model.todayMilage = parm[@"todayMileage"];
//    model.totalMilage = parm[@"totalMileage"];
//    model.todayVelocity = parm[@"averageSpeed"];
//    AVQuery *query = [AVQuery queryWithClassName:@"UserTravelInfo"];
//    [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        if (error == nil && object) {
//            if ([model.todayMilage floatValue] > 0) {
//                [object setObject:@([model.todayMilage floatValue]*1000) forKey:@"todayMileage"];
//            }
//            [object setObject:@([model.todayVelocity floatValue]) forKey:@"averageSpeed"];
//            [object setObject:@([parm[@"totalMileage"] floatValue]) forKey:@"totalMileage"];
//            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    //获取卡路里
//                    model.parentsWeight = [NSString stringWithFormat:@"%@",[[AVUser currentUser] objectForKey:@"weight"]];
//                    AVQuery *query = [AVQuery queryWithClassName:@"UserTravelInfo"];
//                    [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//                    [query selectKeys:@[@"todayCalories",@"totalCalories"]];
//                    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//                        if (error == nil && object) {
//                            model.parentsTodayKcal = [NSString stringWithFormat:@"%ld",[object[@"todayCalories"] integerValue]];
//                            model.parentsTotalKcal = [NSString stringWithFormat:@"%ld",[object[@"totalCalories"] integerValue]];
//                            [self.carA3HeaderView configUIWith:model];
//                        }else{
//                            [self.carA3HeaderView configUIWith:model];
//                        }
//                    }];
//                });
//            }];
//        }else{
//            model.parentsWeight = [NSString stringWithFormat:@"%@",[[AVUser currentUser] objectForKey:@"weight"]];
//            [self.carA3HeaderView configUIWith:model];
//        }
//    }];
}

//电量和温度
-(void)updateTemperatureAndBattery{
    [self.tableView reloadData];
}

-(void)updateAverageSpeed{
    NSString *averageSpeed = KUserDefualt_Get(@"A1_averageSpeed");
    [_oldASCell setVerageSpeed:averageSpeed];
}

//里程
-(void)updateTodayMileageTotalMileageAverageSpeed:(NSMutableDictionary *)data{
    [self.tableView reloadData];
}

//同步时间
-(void)G_sendDataToBLEDevice:(NSString *)time{
    [BLEMANAGER A1_sendDataToDevice:time];
}

//上传体重信息
-(void)G_refreshBabyWeight:(NSString *)babyWeight{
//    NSString *text = [NSString stringWithFormat:@"%@%@kg,%@",NSLocalizedString(@"当前接收的体重是", nil),babyWeight,NSLocalizedString(@"确认要保存么", nil)];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:text preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [HealthModel postWeight:babyWeight date:[CalendarHelper getDate] complete:^(NSString *weight, NSString *date) {
//            //            _homeView.weight = [NSString stringWithFormat:@"%@",weight];
//        }];
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark --- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CarOldStatusTableViewCellHeight;
    }
    return CarOldAverageSpeedTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CarA3SectionViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [[CarA3SectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,CarA3SectionViewHeight ) withName:NSLocalizedString(@"推车状态", nil)];
    }
    if (section == 1) {
        return [[CarA3SectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,CarA3SectionViewHeight ) withName:NSLocalizedString(@"今日平均时速", nil)];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"CarOldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (indexPath.section == 0) {
        if (!cell) {
            cell = [[CarOldStatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        _oldStatusCell = (CarOldStatusTableViewCell *)cell;
        [_oldStatusCell setBLEConnectStatus:[self bleConnecting]];
        NSString *battery = KUserDefualt_Get(@"A1_battery");
        NSString *temperature = KUserDefualt_Get(@"A1_temperature");
        [_oldStatusCell setupEnergy:battery tem:temperature];
    }else{
        if (!cell) {
            cell = [[CarOldAverageSpeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        _oldASCell = (CarOldAverageSpeedTableViewCell *)cell;
        [_oldASCell setBLEConnectStatus:[self bleConnecting]];
        NSString *averageSpeed = KUserDefualt_Get(@"A1_averageSpeed");
        [_oldASCell setVerageSpeed:averageSpeed];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)settting{
    AlertManager *alert = [[AlertManager alloc] init];
    __weak typeof(self) wself = self;
    NSString *version = KUserDefualt_Get(@"A1_Version");
    if (version == nil)
        version = @"1.0.1";

    [alert showFunctionList:@[@"修改蓝牙名称",@"icon_固件版本",@"Travel_Unbind"] titleList:@[NSLocalizedString(@"修改设备名称", nil), [NSString stringWithFormat:@"%@: v%@",NSLocalizedString(@"固件版本", nil),version],NSLocalizedString(@"解除绑定", nil)] IndexBlock:^(NSInteger index) {
        //修改设备名
        if (index == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备新名称", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            UITextField *nameField = [alertView textFieldAtIndex:0];
            nameField.placeholder = NSLocalizedString(@"设备新名称", nil);
            nameField.keyboardType = UIKeyboardTypeDefault;
            [alertView show];
        }
        // 固件版本
        if (index == 1) {
           
        }
        // 解除绑定
        if (index == 2) {
            AlertManager *alert = [[AlertManager alloc] init];
            [alert showAlertMessage:NSLocalizedString(@"您将解除手机与设备的绑定，将清空本次绑定记录", nil) title:NSLocalizedString(@"提示", nil) cancle:NSLocalizedString(@"取消", nil) confirm:NSLocalizedString(@"解除绑定", nil) others:nil];
            [alert show];
            alert.indexBlock = ^(NSInteger index) {
                if (index == 1){
//                    [[BabyModel manager] updateItemInBabyInfo:@"" key:@"bluetoothUUID" complete:^(NSString *item) {
//                        [MainModel model].bluetoothUUID = @"";
//                        [MainModel model].blueToothName = @"3POMELOS_L";
//                        [MainModel model].isContectDevice = NO;
//                        [BLEMANAGER cancelConnect];
//                    }];
                    
//                    [DeviceViewModel deleteSelectedDeviceUUID:wself.peripheralUUID finish:^(BOOL success, NSError *error) {
//                        if (success) {
//                            [MBProgressHUD showToast:NSLocalizedString(@"解除绑定成功", nil)];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kACCESSESEQUIPMENTLIST object:nil];
//                            [wself.navigationController popToRootViewControllerAnimated:YES];
//                        }else{
//                            [MBProgressHUD showError:NSLocalizedString(@"解绑失败", nil)];
//                        }
//                    }];
                    [NETWorkAPI deleteDeviceWithId:self.deviceModel.objectid callback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            [BLEMANAGER cancelConnect];
                            [MBProgressHUD showToast:NSLocalizedString(@"解除绑定成功", nil)];
                            [wself.navigationController popToRootViewControllerAnimated:YES];
                        }else{
                            [MBProgressHUD showError:NSLocalizedString(@"解绑失败", nil)];
                        }
                    }];
                }
            };
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
    if (BLEMANAGER.currentPeripheral == nil) {
        return NO;
    }else{
        if (![BLEMANAGER.currentPeripheral.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
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

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}

@end
