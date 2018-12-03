//
//  TripAndMusicViewController.m
//  Buggy
//
//  Created by goat on 2018/3/14.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "TripAndMusicViewController.h"
#import "TripPlanViewController.h"
#import "MYLabel.h"
#import "tripTotalModel.h"
#import "WNJsonModel.h"
#import "CLButton.h"
#import "HmacSha1Tool.h"
#import "rankingListController.h"
#import "tripAndMusicOneCellView.h"
#import "tripAndMusicTwoCellView.h"
#import "BLEDataParserAPI.h"
#import "BlueToothManager.h"
#import "tripAndMusicTools.h"
#import "DeviceModel.h"
#import "bleConnectPromptView.h"
#import "DeviceViewController.h"
#import "MainViewController.h"
#import "UIButton+Indicator.h"
#import "BLEA4API.h"
#import "NetWorkStatus.h"
#import "pushDataAPI.h"
#import "NSString+AVLoader.h"
#import <Photos/Photos.h>

@interface TripAndMusicViewController()<UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,BLEDataParserDelegate,BlueToothManagerDelegate,tripAndMusicOneCellViewDelegate>
@property (nonatomic,strong) UITableView *tripTableView;      //出行界面
@property (nonatomic,strong) UIView *topBgView;    //顶部背景view
@property (nonatomic,strong) tripAndMusicOneCellView *oneCell;
@property (nonatomic,strong) tripAndMusicTwoCellView *twoCell;
@property (nonatomic,strong) tripTotalModel *dataModel;    //界面数据
@property (nonatomic,strong) bleConnectPromptView *promptView;    //连接蓝牙提示view

@end
@implementation TripAndMusicViewController{
    BLEDataParserAPI *_bleDataParserAPI;    //高景观数据处理
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //根据当前网络状态设置缓存策略
    if ([NetWorkStatus isNetworkEnvironment]) {
        NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }else{
        NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    if (@available(iOS 11.0, *)) {
        self.tripTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.topBgView];
    [self.view addSubview:self.tripTableView];
    _bleDataParserAPI = [BLEDataParserAPI shareInstance];
    _bleDataParserAPI.delegate = self;
    BLEMANAGER.delegate = self;
    //新手引导
    [self guideView];
    //检测版本
    [tripAndMusicTools checkVersion];
    //上传离线操作数据
    [tripAndMusicTools UploadOfflineOperationData];
    //请求绑定的设备列表
    [tripAndMusicTools requestBoundedDeviceList:^(NSArray<DeviceModel *> *deviceArray) {
        NETWorkAPI.deviceArray = [NSMutableArray arrayWithArray:deviceArray];
        if (BLEMANAGER.currentPeripheral.state != CBPeripheralStateConnected) {
            [BLEMANAGER stopScanBLE];
            [BLEMANAGER startScanBLEWithTimeout:4];
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //上传本地推行记录
        if ([NetWorkStatus isNetworkEnvironment]) {
            [[pushDataAPI sharedInstance] uploadLocalData];
        }
        //下载设备类型列表
        [tripAndMusicTools downloadDeviceTypeList];
    });
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _bleDataParserAPI.delegate = self;
    BLEMANAGER.delegate = self;
    //请求上传天气数据
    [self requestAndUploadWeatherData];
    //开始天气动画
    [self.oneCell.animation play];
    if (BLEMANAGER.currentPeripheral == nil) {  //蓝牙未连接
        self.oneCell.connectBtn.hidden = NO;
        self.oneCell.onlineLabel.text = NSLocalizedString(@"连接推车后打卡", nil);
        self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
    }else{
        self.oneCell.connectBtn.hidden = YES;
        self.oneCell.onlineLabel.text = NSLocalizedString(@"推车已连接", nil);
        self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
    }
}


//请求上传天气数据
-(void)requestAndUploadWeatherData{
    [WeatherManager getLocationWeatherWith:^(NSString *temperature, NSString *air,NSString *weather) {
        if (temperature != nil) {
            self.oneCell.temperature.text = [NSString stringWithFormat:@"%@℃",temperature];
            self.oneCell.air.text = air;
            [self.oneCell showWeatherAnimtionWithCode:weather];  //天气动画
        }
    } success:^{
        //上传天气成功，请求首页数据
        [NETWorkAPI requestHomeData:^(homeDataModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                DLog(@"请求失败");
                return ;
            }
            if (model != nil && [model isKindOfClass:[homeDataModel class]]) {
                self.twoCell.todayMileage.text = model.todayMileage;
                self.twoCell.weekFrequency.text = [NSString stringWithFormat:@"%ld",(long)model.frequencyWeek];
                self.oneCell.tipsLabel.text = model.recommendedContent;
                self.oneCell.recommendedDate = model.recommendedDate;
                self.oneCell.numLabel.text = [NSString stringWithFormat:@"%ld",model.punchCount];
                //先重置头像
//                    for (UIImageView *imgV in imageArray) {
//                        imgV.image = ImageNamed(@"home_default");
//                    }
                NSMutableArray *imageArray = [NSMutableArray arrayWithArray:self.oneCell.imageviewArray];
                for (punchHeaderImage *object in model.headerUrl) {
                    UIImageView *imageView = imageArray.lastObject;
                    if (object.headerurl != nil && [object.headerurl isKindOfClass:[NSString class]]) {
                        NSURL *url = [NSURL URLWithString:object.headerurl];
                        if (url) {
                            [imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"home_default")];
                        }
                        [imageArray removeLastObject];
                    }
                }
                [imageArray removeAllObjects];
            }else{
                DLog(@"暂无数据");
            }
        }];
    }];
}

-(void)updateTodayMileage:(NSInteger)todayMileage{
    self.twoCell.todayMileage.text = [NSString stringWithFormat:@"%ld",todayMileage];
}

//新手引导
-(void)guideView{
    if (![KUserDefualt_Get(@"isFirstLaunchTrip") isEqualToString:@"1"]) {
        UIImageView *imageView= [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-bottomSafeH);
        if (ScreenHeight == 812) {  //X
            imageView.image = ImageNamed(@"1125");
        }else{
            imageView.image = ImageNamed(@"750");
        }
        imageView.userInteractionEnabled = YES;
        __weak typeof(imageView) weakImage = imageView;
        [imageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakImage removeFromSuperview];
            KUserDefualt_Set(@"1", @"isFirstLaunchTrip");
        }];
        MainViewController *main = (MainViewController *)[UIViewController presentingVC];
        [main.view addSubview:imageView];
    }
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{return 2;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return statusBarH + 126 + RealWidth(408);
    }else if(indexPath.row == 1){
        return RealWidth(104) + 60;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        [cell.contentView addSubview:self.oneCell];

        __weak typeof(cell) weakCell = cell;
        [cell.contentView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            CGPoint point = [gestureRecoginzer locationInView:weakCell.contentView];
            //点击了日历
            if (CGRectContainsPoint(CGRectMake(15, self.oneCell.tripManage.top+40, self.oneCell.tripManage.width, self.oneCell.tripManage.height-40), point)) {
                TripPlanViewController *vc = [[TripPlanViewController alloc] init];
                vc.view.backgroundColor = kWhiteColor;
                [self presentViewController:vc animated:YES completion:nil];
            }
            //点击排行榜
            if (CGRectContainsPoint(CGRectMake(15, self.oneCell.tripManage.top, self.oneCell.tripManage.width, 40), point)) {
                rankingListController *vc = [[rankingListController alloc] init];
                vc.view.backgroundColor = kWhiteColor;
                [self.navigationController pushViewController:vc animated:YES];
            }
            //点击现在连接
            if (CGRectContainsPoint(self.oneCell.connectBtn.frame, point)) {
                if (self.oneCell.connectBtn.hidden == NO) {
                    if (self.oneCell.connectBtn.enabled == NO) {  //正在菊花转
                        return ;
                    }
                    if (NETWorkAPI.deviceArray.count > 0) {
                        [self.oneCell.connectBtn showIndicator];  //菊花转
                        self.oneCell.onlineLabel.text = NSLocalizedString(@"正在连接...", nil);
                        [BLEMANAGER stopScanBLE];
                        [BLEMANAGER startScanBLEWithTimeout:2.5];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.oneCell.connectBtn hideIndicator];  //关闭菊花转
                            //2.5秒过后还没有连接则弹出提示框
                            if (BLEMANAGER.currentPeripheral == nil) {
                                [self connectionFail];
                                self.oneCell.onlineLabel.text = NSLocalizedString(@"连接推车后打卡", nil);
                                self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
                            }else{
                                self.oneCell.onlineLabel.text = NSLocalizedString(@"推车已连接", nil);
                                self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
                            }
                        });
                    }else{  //没有已绑定设备
                        DeviceViewController *device = [[DeviceViewController alloc] init];
//                        device.bandPeripherals = self.deviceArray;
                        [self.navigationController pushViewController:device animated:YES];
                    }
                }
            }
        }];
    }else if (indexPath.row == 1){
        [cell.contentView addSubview:self.twoCell];
    }
    return cell;
}

#pragma mark - 蓝牙 DelegateMethend
//已经发现周边设备
- (void)didDiscoverPeripheral:(NSSet *)Peripherals{
    if (BLEMANAGER.currentPeripheral) {
        return;   //已连接蓝牙则退出
    }
    DeviceModel *model = [NETWorkAPI.deviceArray firstObject];
    //判断扫描到的蓝牙里面有没有已经绑定的  有就连接
    for (CBPeripheral *per in Peripherals) {
        if ([model.bluetoothuuid isEqualToString:per.identifier.UUIDString]) {
            [BLEMANAGER connectPeripheralDevice:per];
            return;
        }
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    [BLEMANAGER startReceiveData];
    [MainModel model].isContectDevice = YES;
    [MainModel model].bluetoothUUID = peripheral.identifier.UUIDString;
    
    self.oneCell.onlineLabel.text = NSLocalizedString(@"推车已连接", nil);
    self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
    self.oneCell.connectBtn.hidden = YES;
    if (self.promptView) {
        [self.promptView connectSuccess];
    }
}

- (void)didDisconnectPeripheral:(NSError *)error{
    [MainModel model].isContectDevice = NO;
    [MainModel model].bluetoothUUID = nil;
    
    self.oneCell.connectBtn.hidden = NO;
    self.oneCell.onlineLabel.text = NSLocalizedString(@"连接推车后打卡", nil);
    self.oneCell.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
}

//连接失败
-(void)connectionFail{
    self.promptView = [[bleConnectPromptView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.tabBarController.view addSubview:self.promptView];
}

- (void)receiveData:(NSString *)data{
    [_bleDataParserAPI G_parserData:data];
}
#pragma mark - BLEDataParserDelegate 高景观车的代理方法
- (void)G_postTravel:(NSDictionary *)parm{
//    __weak typeof(self) wself = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parm];
    [dic setObject:[BLEMANAGER.currentPeripheral.identifier UUIDString] forKey:@"bluetoothUUID"];
    //上传里程
//    [BabyStrollerManager postA1Travel:dic complete:^(NSDictionary *dic, BOOL success) {
//        [wself requestNetWorkData];
//    }];
}

- (void)G_refreshBabyWeight:(NSString *)babyWeight{
    NSString *text = [NSString stringWithFormat:@"%@%@kg,%@",NSLocalizedString(@"当前接收的体重是", nil),babyWeight,NSLocalizedString(@"确认要保存么", nil)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:text preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [HealthModel postWeight:babyWeight date:[CalendarHelper getDate] complete:^(NSString *weight, NSString *date) {
//            _homeView.weight = [NSString stringWithFormat:@"%@",weight];
//        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)G_sendDataToBLEDevice:(NSString *)time{
    [BLEMANAGER A1_sendDataToDevice:time];
}

#pragma mark - tripAndMusicOneCellViewDelegate
-(void)backgroundColorChange:(UIColor *)color{
    self.topBgView.backgroundColor = color;
}

#pragma mark - lazy
-(UIView *)topBgView{
    if (_topBgView == nil) {
        _topBgView = [[UIView alloc] init];
        _topBgView.backgroundColor = [UIColor colorWithHexString:@"#4B8FF0"];
        _topBgView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight/2);
    }
    return _topBgView;
}

-(UITableView *)tripTableView{
    if (_tripTableView == nil) {
        _tripTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-tabbarH) style:UITableViewStylePlain];
        _tripTableView.delegate = self;
        _tripTableView.dataSource = self;
        _tripTableView.showsVerticalScrollIndicator = NO;
        _tripTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tripTableView.backgroundColor = kClearColor;
    }
    return _tripTableView;
}

-(tripAndMusicOneCellView *)oneCell{
    if (_oneCell == nil) {
        _oneCell = [[tripAndMusicOneCellView alloc] init];
        _oneCell.backgroundColor = kWhiteColor;
        _oneCell.frame = CGRectMake(0, 0, ScreenWidth, 300);
        _oneCell.delegate = self;
    }
    return _oneCell;
}

-(tripAndMusicTwoCellView *)twoCell{
    if (_twoCell == nil) {
        _twoCell = [[tripAndMusicTwoCellView alloc] init];
        _twoCell.backgroundColor = kWhiteColor;
        _twoCell.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(104) + 60);
    }
    return _twoCell;
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

//隐藏状态栏
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
@end
