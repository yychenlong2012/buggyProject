//
//  DeviceViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/3/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceViewController.h"
#import "BlueToothManager.h"
#import "DeviceTableViewCell.h"
#import "CarA3DetailsViewController.h"
#import "DeviceHeaderView.h"
#import "CarOldDetailViewController.h"
#import "DeviceModel.h"
#import "BLEDataParserAPI.h"
#import "CarA4DetailViewController.h"
#import "CLImageView.h"
#import "NetWorkStatus.h"
#import "DryFootViewController.h"

@interface DeviceViewController ()<UITableViewDataSource,UITableViewDelegate,BlueToothManagerDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) DeviceHeaderView *headerView;
@property (nonatomic ,assign) NSInteger index;
@property (nonatomic ,strong) NSArray *deviceTypeList;      //设备类型列表
@property (nonatomic ,strong) BLEDataParserAPI *bleDataParserAPI;
@property (nonatomic ,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic ,strong) UIButton *refreshBtn;         //刷新按钮
@property (nonatomic ,strong) UIActivityIndicatorView *indicator;
@end

@implementation DeviceViewController{
    NSMutableArray *_dataSource;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BLEMANAGER.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviView];
    _dataSource = [NSMutableArray array];
    if (BLEMANAGER.currentPeripheral != nil) {   //已经连接的蓝牙是搜索不到的 所以主动加入
        [_dataSource addObject:[self getDictionaryFormPeripheral:BLEMANAGER.currentPeripheral]];
    }
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.refreshBtn];
    [self.tableView setTableHeaderView:self.headerView];
    self.bleDataParserAPI = [BLEDataParserAPI shareInstance];
    BLEMANAGER.delegate = self;
    _index = -1;
    __weak typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself refrensh];
    }];
    [self refrensh];
    self.navigationItem.title = NSLocalizedString(@"搜索设备", nil);
    self.navigationItem.leftBarButtonItem = [Factory costomBackBarWithTitle:@"" click:^{
        [weakself.navigationController popViewControllerAnimated:YES];
    } isback:YES];
    //获得设备类型列表用于筛选蓝牙
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"deviceTypeList.plist"];
    self.deviceTypeList = [NSArray arrayWithContentsOfFile:filePath];
    
    
}

- (void)dealloc{
    [BLEMANAGER stopScanBLE];
    [self.headerView removeSearchAnimation]; //移除辐射动画
}

//扫描新设备
- (void)refrensh {
    switch (BLEMANAGER.centralManager.state) {
        case CBManagerStateUnknown:
            [MBProgressHUD showToastDown:@"未知的原因"];
            break;
        case CBManagerStateUnsupported:
            [MBProgressHUD showToastDown:@"当前设备不支持蓝牙连接"];
            break;
        case CBManagerStateUnauthorized:
            [MBProgressHUD showToastDown:@"您没有授权蓝牙连接"];
            break;
        case CBManagerStatePoweredOff:
            [MBProgressHUD showToastDown:@"您的手机蓝牙没有打开"];
            break;
        default:{
            [self.headerView removeSearchAnimation]; //移除辐射动画
            [self.headerView addSearchAnimation];    //手机蓝牙辐射动画
//            [BLEMANAGER stopScan];                   //停止扫描
            [BLEMANAGER startScanBLEWithTimeout:5];            //开始扫描设备
        }
    }
    [_tableView.mj_header endRefreshing];
}

#pragma mark --- 蓝牙 DelegateMethend
//接收到数据
- (void)receiveData:(NSString *)data{
    //根据数据展示界面
    [_bleDataParserAPI G_parserData:data];
}

- (void)didDiscoverPeripheral:(NSSet *)Peripherals{
    //这里获得的设备列表 已经是蓝牙核心模块筛选过后保留下来的设备
    self.peripherals = [NSMutableArray arrayWithArray:[Peripherals allObjects]];
    [_dataSource removeAllObjects];
    //正在连接的设备是无法扫描到的 需手动加入
    if (BLEMANAGER.currentPeripheral != nil && BLEMANAGER.currentPeripheral.state == CBPeripheralStateConnected) {
        //有些蓝牙连接之后还是能搜索到需要去除
        BOOL isIn = NO;
        for (CBPeripheral *peripheral in Peripherals) {
            if ([peripheral.identifier.UUIDString isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
                isIn = YES;
            }
        }
        if (isIn == NO) {
            [self.peripherals insertObject:BLEMANAGER.currentPeripheral atIndex:0];
        }
        
    }
    for (CBPeripheral *peripheral in self.peripherals) {       //将设备转换成模型数据
        [_dataSource addObject:[self getDictionaryFormPeripheral:peripheral]];
    }
    [self.tableView reloadData];
}

//扫描完毕
-(void)stopScanDevices{
    [self.indicator stopAnimating];
    [self.refreshBtn setTitle:@"点击搜索蓝牙" forState:UIControlStateNormal];
    self.refreshBtn.enabled = YES;
    [self.headerView removeSearchAnimation]; //移除辐射动画
}

//将设备信息转成字典数据
-(NSDictionary *)getDictionaryFormPeripheral:(CBPeripheral *)peripheral{
    NSString *deviceType = @"";
    //判断设备类型
    for (NSDictionary *dict in self.deviceTypeList) {
        if ([dict[@"bluetoothName"] isEqualToString:peripheral.name]) {
//            deviceType = dict[@"deviceIdentifier"];
            deviceType = dict[@"fuctionType"];
        }
    }
    
    //未通过上面的判断  则根据uuid和已绑定的设备进行判断
    if ([deviceType isEqualToString:@""]) {
        for (DeviceModel *model in NETWorkAPI.deviceArray) {
            if ([model.bluetoothuuid isEqualToString:peripheral.identifier.UUIDString]) {
//                deviceType = model.deviceIdentifier;
                deviceType = model.fuctiontype;
            }
        }
    }
    
    //根据绑定的设备列表改名
    NSString *name = @"";
    for (DeviceModel *deviceModel in NETWorkAPI.deviceArray) {
        if ([deviceModel.bluetoothuuid isEqualToString:peripheral.identifier.UUIDString]) {
            if (deviceModel.bluetoothname != nil && ![deviceModel.bluetoothname isEqualToString:@""]) {
                name = deviceModel.bluetoothname;
            }
        }
    }
    if ([name isEqualToString:@""]) {
        name = peripheral.name?peripheral.name:@"未知设备";
    }
    
    NSDictionary *dic = @{ @"name":name,
                           @"UUID":[peripheral.identifier UUIDString],
                           @"state":@(peripheral.state),
                           @"deviceType":deviceType
                           };
    return dic;
}


- (void)stopScanBLEThenUpdateDevices{
    [_tableView.mj_header endRefreshing];
    [self.headerView removeSearchAnimation];
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    [BLEMANAGER startReceiveData];   //高景观的获取数据命令
    [MainModel model].isContectDevice = YES;
    [MainModel model].bluetoothUUID = peripheral.identifier.UUIDString;
}

#pragma mark -- UITableViewDelegate and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return DeviceTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return DeviceSectionViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DeviceSectionView *view = [[DeviceSectionView alloc] init];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = [NSString stringWithFormat:@"MyDeviceCell%ld",(long)indexPath.row];
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    //判断是否为正在连接的蓝牙
    BOOL isBand = NO;
    for (DeviceModel *model in NETWorkAPI.deviceArray) {
        if ([model.bluetoothuuid isEqualToString:_dataSource[indexPath.row][@"UUID"]]) {
            isBand = YES;
        }
    }
    [cell setOrder:(indexPath.row + 1) isBandingDevice:isBand];
//    if (BLEMANAGER.startModel == MODEL_CONECTED && BLEMANAGER.currentPeripheral) {
//        if ([_dataSource[indexPath.row][@"UUID"] isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
//            [cell setOrder:(indexPath.row + 1) isBandingDevice:YES];
//        }else{
//            [cell setOrder:(indexPath.row + 1) isBandingDevice:NO];
//        }
//    }else{
//        [cell setOrder:(indexPath.row + 1) isBandingDevice:NO];
//    }
//    if ([_dataSource[indexPath.row][@"UUID"] isEqualToString:[MainModel model].bluetoothUUID] &&  BLEMANAGER.startModel == MODEL_CONECTED) {
//        [cell setOrder:(indexPath.row + 1) isBandingDevice:YES];
//    }else{
//        [cell setOrder:(indexPath.row + 1) isBandingDevice:NO];
//    }
    cell.peripheral = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ((_index == indexPath.row && cell.tag == 1) || [[cell getTitle] isEqualToString:@"查看设备"]) {    //选择了已连接的蓝牙
        if (BLEMANAGER.currentPeripheral) { //如果点击了不是正在连接的设备 则先断开蓝牙
            if (![_dataSource[indexPath.row][@"UUID"] isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
                [BLEMANAGER cancelConnect];
            }
        }
        
        NSInteger deviceType = [_dataSource[indexPath.row][@"deviceType"] integerValue];    //推车类型
        //根据车型进入相应的界面
        if (deviceType == 0) {                                                        //高景观老车 Pomelos_G
            CarOldDetailViewController *device = [[CarOldDetailViewController alloc] init];
//            device.peripheral = _dataSource[indexPath.row][@"UUID"];
            device.peripheralUUID = _dataSource[indexPath.row][@"UUID"];
            device.peripheral = self.peripherals[indexPath.row];
            device.deviceName = _dataSource[indexPath.row][@"name"];
            [self.navigationController pushViewController:device animated:YES];
            return;
        }
        
        if (deviceType == 1) {                                                        //A3新车 Pomelos_A3
            CarA3DetailsViewController *device = [[CarA3DetailsViewController alloc] init];
            NSDictionary *dict = _dataSource[indexPath.row];
            device.peripheralUUID = dict[@"UUID"];
            device.deviceName = _dataSource[indexPath.row][@"name"];
            [device connectionBLE:self.peripherals[indexPath.row]];      //10月18号加
            [self.navigationController pushViewController:device animated:YES];
            return;
        }
        
        if (deviceType == 2 || deviceType == 3 || deviceType == 4) {                  //8101_APP_BLE Pomelos_8101 3POMELOS_A6 3POMELOS_A6
            CarA4DetailViewController *car = [[CarA4DetailViewController alloc] init];
            car.fuctionType = [_dataSource[indexPath.row][@"deviceType"] integerValue];
            car.deviceName = _dataSource[indexPath.row][@"name"];
            car.peripheralUUID = _dataSource[indexPath.row][@"UUID"];
            [self.navigationController pushViewController:car animated:YES];
            return;
        }
        
        if (deviceType == 5) {     //干脚器
            DryFootViewController *dry = [[DryFootViewController alloc] init];
            dry.deviceName = _dataSource[indexPath.row][@"name"];
            dry.peripheralUUID = _dataSource[indexPath.row][@"UUID"];
            [self.navigationController pushViewController:dry animated:YES];
            return;
        }
        
    }else{                                                                      //选择了未连接的蓝牙
        //  判断有无网络，有网络则将绑定信息上传
        if ([MainModel model].isHaveNetWork) {  //判断网络
            CBPeripheral *peri = self.peripherals[indexPath.row];
            [BLEMANAGER cancelConnect];
            [BLEMANAGER connectPeripheralDevice:peri];  //试图连接所选的蓝牙
//            [cell banding];                   //绑定新蓝牙
            [cell band];
        }else{
            [self showAlertMessage:@"未连接网络 无法绑定"];
        }
    }
    _index = indexPath.row;
}

#pragma mark --- Setter and Getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

-(DeviceHeaderView *)headerView{
    if (_headerView == nil) {
        _headerView = [[DeviceHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, DeviceHeaderViewHeight)];
    }
    return _headerView;
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
        
        UILabel *naviLabel = [[UILabel alloc] init];
        naviLabel.textColor = kWhiteColor;
        naviLabel.text = NSLocalizedString(@"搜索设备", nil);
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
    }
    return _naviView;
}

-(UIButton *)refreshBtn{   //语音提示 滴答声
    if (_refreshBtn == nil) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.frame = CGRectMake((ScreenWidth-200)/2, ScreenHeight-64-bottomSafeH, 200, 50);
        [_refreshBtn setTitle:@"点击搜索蓝牙" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        _refreshBtn.backgroundColor = [UIColor colorWithHexString:@"#EEEEEE"];
        _refreshBtn.layer.cornerRadius = 15;
        
        [_refreshBtn addSubview:self.indicator];
        
        __weak typeof(self) wself = self;
        [_refreshBtn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.refreshBtn setTitle:@"正在搜索..." forState:UIControlStateNormal];
            wself.indicator.centerY = wself.refreshBtn.titleLabel.centerY;
            wself.indicator.right = wself.refreshBtn.titleLabel.left;
            [wself refrensh];
            [wself.indicator startAnimating];
            wself.refreshBtn.enabled = NO;
        }];
    }
    return _refreshBtn;
}

-(UIActivityIndicatorView *)indicator{
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.frame = CGRectMake(0, 0, 40, 40);
    }
    return _indicator;
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
