//
//  CarA4DetailViewController.m
//  Buggy
//
//  Created by goat on 2018/5/8.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "CarA4DetailViewController.h"
#import "BlueToothManager.h"
#import "CarA3HeaderView.h"
#import "electricityView.h"
#import "brakeView.h"
#import "promptView.h"
#import "moreOperationsView.h"
#import "lightView.h"
#import "MainModel.h"
#import "BLEA4API.h"
#import "CarA4PushDataModel.h"
#import "pushDataAPI.h"
#import "NetWorkStatus.h"
#import "DeviceModel.h"
#import "CalendarHelper.h"
#import "LanguageChangeViewController.h"
#import "CLImageView.h"

#define scanTime 10  //蓝牙扫描时间

@interface CarA4DetailViewController ()<BlueToothManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) CarA3HeaderView *tableHeaderView;
@property (nonatomic,strong) electricityView *electricityView;  //电量view
@property (nonatomic,strong) brakeView *brakeview;    //刹车
@property (nonatomic,strong) UIView *brakeSensitivity;  //智能刹车灵敏度
@property (nonatomic,strong) UIView *safeView;        //安全
@property (nonatomic,strong) UISwitch *safeSwitch;    //一键防盗开关
@property (nonatomic,strong) promptView *promptview;  //提示音
@property (nonatomic,strong) moreOperationsView *moreOperation;  //更多操作
@property (nonatomic,strong) lightView *carLight;     //车灯
@property (nonatomic,strong) UIView *shutDown;       //关机
@property (nonatomic,strong) NSTimer *timer;         //定时器 蓝牙断开时定时搜索蓝牙
@property (nonatomic,strong) userTravelInfoModel *kcalModel;  //里程卡路里信息模型
@property (nonatomic,assign) NSInteger brakeSen;   //刹车灵敏度
@property (nonatomic,strong) UIImageView *lockImageView;   //防盗锁图片
@property (nonatomic,strong) UIView *lockHUD;      //一键防盗提示
@property (nonatomic,assign) BOOL isSafeOpen;      //一键防盗状态

@property (nonatomic,strong) UIView *naviView;    //自定义导航栏背景view
@property (nonatomic,assign) BOOL isShowHUD;      //是否显示HUD
@property (nonatomic,strong) NSString *version;   //固件版本号
@property (nonatomic,assign) BOOL havePushData;   //是否有推行数据
@property (nonatomic,strong) NSMutableArray *onceDataArray;     //分段里程数据
@end
@implementation CarA4DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isShowHUD = NO;
    self.havePushData = NO;
    [self.view addSubview:self.naviView];
    BLEMANAGER.delegate = self;
    self.onceDataArray = [NSMutableArray array];
    [self.view addSubview:self.tableview];
    self.tableview.tableHeaderView = self.tableHeaderView;
    __weak typeof(self) weakself = self;
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself requestHeaherData];
    }];
    [self requestHeaherData];
    if (BLEMANAGER.currentPeripheral == nil) {  //蓝牙未连接时获取后台里程数据
        [self.tableview.mj_header beginRefreshing];
    }
    if ([NetWorkStatus isNetworkEnvironment]) {  //上传本地推行记录
       [[pushDataAPI sharedInstance] uploadLocalData];
    }
    //连接蓝牙 请求数据
    if ([self isBLEConnected]) {
        [BLEMANAGER writeValueForPeripheral:[BLEA4API synchronizationTime]];  //时间同步
    }else{
        if (self.timer == nil) {
            self.timer = [NSTimer timerWithTimeInterval:scanTime target:self selector:@selector(time) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BLEMANAGER.delegate = self;
    self.fd_interactivePopDisabled = YES;  //取消全屏右划返回功能
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.fd_interactivePopDisabled = NO;   //开启右划返回
    //关闭定时器
    [self.timer invalidate];
    self.timer = nil;
}

-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - action
-(void)requestHeaherData{
    [NETWorkAPI requestUserTravelInfoCallback:^(id  _Nullable model, NSError * _Nullable error) {
        [self.tableview.mj_header endRefreshing];
        if (model != nil && [model isKindOfClass:[userTravelInfoModel class]] && error == nil) {
            self.kcalModel = model;
            [self.tableHeaderView configUIWith:model];
        }
    }];
}

//解除绑定
-(void)deviceUnBound{
    [NETWorkAPI deleteDeviceWithId:self.deviceModel.objectid callback:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //解绑的是当前连接的设备 则断开连接
            if ([self.deviceModel.bluetoothuuid isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
                [BLEMANAGER cancelConnect];
            }
            [AYMessage show:NSLocalizedString(@"解除绑定成功", nil) onView:self.view autoHidden:YES];
        }else{
            [MBProgressHUD showError:NSLocalizedString(@"解绑失败", nil)];
        }
    }];
}

//获取数据表中最新的一条记录的日期
-(void)getTheLatestDate:(void(^)(NSDate *date))block withTimeout:(NSInteger)timeout{
    [NETWorkAPI requestNewestMileageDataCallback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        if (error) {
            block([NSDate date]);
            return ;
        }

        if ([msg isKindOfClass:[NSString class]]) {
            NSDateFormatter *forma = [[NSDateFormatter alloc] init];
            forma.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            block([NSDate dateWithTimeInterval:5 sinceDate:[forma dateFromString:msg]]);
        }else{
            block([NSDate dateWithTimeInterval:-30*24*60*60 sinceDate:[NSDate date]]);
        }
    }];
}

//每隔一段时间搜索一次蓝牙设备
-(void)time{
    [BLEMANAGER startScanBLEWithTimeout:3];
}

#pragma mark - BLEdelegate
//连接蓝牙
- (void)connectionBLE:(CBPeripheral *)per{
    //手机是否开启蓝牙
    if (BLEMANAGER.centralManager.state != CBManagerStatePoweredOn) {
        [self showAlertMessage:NSLocalizedString(@"请开启手机蓝牙", nil)];
    }else{
        [BLEMANAGER connectPeripheralDevice:per];
        BLEMANAGER.delegate = self;
        [MainModel model].bluetoothUUID = _peripheralUUID;
    }
}

//指定蓝牙是否已连接
- (BOOL)isBLEConnected{
    if (BLEMANAGER.currentPeripheral == nil) {    //连接的状态未连接
        return NO;
    }else{
        if ([[BLEMANAGER.currentPeripheral.identifier UUIDString] isEqualToString:self.peripheralUUID]) {
            return YES;
        }else{
            //到这里说明蓝牙已连接 但不是所选的设备
            [BLEMANAGER cancelConnect];
            return NO;
        }
    }
}

#pragma mark - BlueToothManagerDelegate
//蓝牙断开连接
- (void)didDisconnectPeripheral:(NSError *)error{
    [MainModel model].bluetoothUUID = nil;
    //部分功能和界面变化
    [self.electricityView closeBattery];
    [self.brakeview closeBrake];
    //蓝牙断开时要开启定时器 定时搜索蓝牙
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:scanTime target:self selector:@selector(time) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    //防盗锁图标
    self.lockImageView.hidden = YES;
}

//已经连接到蓝牙
-(void)didConnectPeripheral:(CBPeripheral *)peripheral{
    //停止定时器
    [self.timer invalidate];
    self.timer = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [BLEMANAGER writeValueForPeripheral:[BLEA4API synchronizationTime]];  //时间同步
    });
}

//已经发现周边设备
- (void)didDiscoverPeripheral:(NSSet *)Peripherals{
    //判断扫描到的蓝牙里面有没有同名的
    for (CBPeripheral *per in Peripherals) {
        if ([per.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
            [BLEMANAGER connectPeripheralDevice:per];
        }
    }
}

//接收到蓝牙数据
-(void)getValueForPeripheral{
    NSArray *dataArray = BLEMANAGER.deviceCallBack;
    if (dataArray == nil || dataArray.count == 0){
        return;
    }
    NSData *data = [dataArray firstObject];
    Byte *byte = (Byte *)[data bytes];
    if (byte[3] == 0x8b && byte[4] == 0x01) { // 获取里程和速度
        int i = (byte[5] << 8) | byte[6];   //平均速度
        int j = (byte[7] << 8) | byte[8];   //今日里程
        int k = (byte[9] << 8) | byte[10];  //总里程
        //转换后的单位都是km千米级别的
        self.kcalModel.todayvelocity = [NSString stringWithFormat:@"%0.2f",i/10.0];
        self.kcalModel.todaymileage = [NSString stringWithFormat:@"%0.2f",j/100.0];
        self.kcalModel.totalmileage = [NSString stringWithFormat:@"%0.2f",k/10.0];

        [self.tableHeaderView configUIWith:self.kcalModel];

        //上传今日里程 速度 总里程
        [NETWorkAPI uploadAverageSpeed:i/10.0 todayMileage:j*10 totalMileage:k/10.0 callback:^(BOOL success, NSError * _Nullable error) {
            //上传成功 重新请求数据
            if (success) {
                [self requestHeaherData];
            }
        }];
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x07){   //电量获取
        if (byte[5] == 0xFF) {
//            NSLog(@"主控板电量无效");
        }else{
            int i = byte[5];
            self.electricityView.leftlabel.text = [NSString stringWithFormat:@"%d%%",i];
            self.electricityView.leftValue = i/100.0;
        }
        if (byte[6] == 0xFF) {
            NSLog(@"手把组电量无效");
        }else{
            int j = byte[6];
            self.electricityView.rightLabel.text = [NSString stringWithFormat:@"%d%%",j];
            self.electricityView.rightValue = j/100.0;
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x11){    //温度  界面暂时用不上
//        if (byte[5] == 0x7F && byte[6] == 0xFF) {
//            NSLog(@"温度无效");
//        }else{
//            int i = byte[5] << 8 | byte[6];
//            CGFloat temperature = i/100.0;
//            NSLog(@"%f",temperature);
//        }
    }else if (byte[3] == 0x8b && byte[4] == 0x06){   //一键防盗关闭
        self.safeSwitch.on = NO;
        self.lockImageView.hidden = YES;
        self.isSafeOpen = NO;
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x05){   //一键防盗开启
        self.safeSwitch.on = YES;
        self.lockImageView.hidden = NO;
        self.isSafeOpen = YES;
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x0F){   //刹车模式
        if (byte[5] == 0x00) {
            [self.brakeview closeBrake];
        }else if (byte[5] == 0x01){
            [self.brakeview autoBrakeMode];
        }else if (byte[5] == 0x02){
            [self.brakeview smartBrakeMode];
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x12){    //提示音状态  <55aa018b 12 02 60>
        Byte code = byte[5] >> 6;   //取出7-8位二进制 表示提示音开关
        //1.设置提示音开关
        if (code == 0x2) {
            self.promptview.switchBtn.on = YES;
            self.promptview.isBellsOpen = YES;
        }else{
            self.promptview.switchBtn.on = NO;
            self.promptview.isBellsOpen = NO;
        }
        //2.铃声种类
        int num = byte[5] & 0xF;
        self.promptview.bellsNum = num;
        if (num == 0) {
            self.promptview.bells.text = NSLocalizedString(@"语音提示", nil);
        }else if (num == 1){
            self.promptview.bells.text = NSLocalizedString(@"滴答声", nil);
        }else if (num == 2){
            self.promptview.bells.text = NSLocalizedString(@"无", nil);
        }else if (num == 3){
            self.promptview.bells.text = NSLocalizedString(@"无", nil);
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x16){   //刹车灵敏度
        int i = byte[5];
        self.brakeSen = i;
        [pushDataAPI uploadBrakeSensitivity:i];
    }else if (byte[3] == 0x8b && byte[4] == 0x13){    //提示音量
        int i = byte[5];
        self.promptview.slider.value = i;
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x30){    //车灯模式
        NSLog(@"%@",BLEMANAGER.deviceCallBack);
        int isOpen = byte[5] >> 7;
        if(isOpen == 0){  //关闭
            [self.carLight closeMode];          //<55aa018b 300044>
        }else{  //打开
            int mode = byte[5] & 0x01;
            if(mode == 1){  //呼吸灯             //<55aa018b 30ff45>
                [self.carLight breathingLampMode];
            }else{  //常亮
                [self.carLight normalOnMode];   //<55aa018b 3080c4>
            }
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x15){    //系统语言
        if (byte[5] == 0x00) {
            self.promptview.systemLanguage = @"中文";
            self.promptview.language.text = NSLocalizedString(@"中文", nil);
        }else if(byte[5] == 0x01){
            self.promptview.systemLanguage = @"英文";
            self.promptview.language.text = NSLocalizedString(@"英文", nil);
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x0A){    //时间同步成功后 请求数据
        [BLEMANAGER writeValueForPeripheral:[BLEA4API getDeviceVersion]];  //获取固件版本号
        __weak typeof(self) wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getTheLatestDate:^(NSDate *date) {
                if ([wself.version integerValue] >= 102) {
                    [BLEMANAGER writeValueForPeripheral:[BLEA4API getPushDataOnce:date]];   //逐条获取推行数据
                }else{
                    [BLEMANAGER writeValueForPeripheral:[BLEA4API getPushData:date]];   //全部获取
                    [MBProgressHUD showLoadingWithMessag:@"正在同步数据"];
                }
            } withTimeout:5];
        });
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x10){    //推行数据     <55aa008b 1065>
//        NSLog(@"打印数据 %@",BLEMANAGER.deviceCallBack);
        if (byte[2] == 0x00) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.havePushData == NO) {   //有推行数据那么HUD会通过最后一条数据的标识而隐藏，没有推行数据则手动隐藏
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    [BLEMANAGER writeValueForPeripheral:[BLEA4API notifySuccess]];  //请求界面数据
                }
            });
        }
        
        //<55aa0d8b 10ff  4832f1ea 4832f215 0029 0020 3a>
        if (data.length == 19) {
            self.havePushData = YES;
//            int num = byte[5];  //推行编号
            long time1   = (byte[6]<<24) + (byte[7]<<16) + (byte[8]<<8) + byte[9];    //开始推行时间
            long time2   = (byte[10]<<24) + (byte[11]<<16) + (byte[12]<<8) + byte[13];    //结束推行时间
            int distance = (byte[14]<<8) + byte[15];           //距离
            int pushTime = (byte[16]<<8) + byte[17];           //消耗时间

            NSDateFormatter *forme = [[NSDateFormatter alloc] init];
            forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            NSDate *baseDate = [forme dateFromString:@"1980 01 02 00 00 00"];
            NSDate *beginTime = [NSDate dateWithTimeInterval:time1 sinceDate:baseDate];
            NSDate *endTime = [NSDate dateWithTimeInterval:time2 sinceDate:baseDate];
//            forme.dateFormat = @"YYYY-MM-dd HH:mm:";
//            NSString *beginStr = [NSString stringWithFormat:@"%@00",[forme stringFromDate:beginTime]];
            forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//            [forme setLocale:[NSLocale currentLocale]];
//            beginTime = [forme dateFromString:beginStr];
//            CarA4PushDataModel *model = [[CarA4PushDataModel alloc] initWithStartTime:beginTime endTime:endTime mileage:distance useTime:pushTime];
//            NSLog(@"推行编号%d 开始时间%@ 结束时间%@ 距离%d",num,[forme stringFromDate:beginTime],[forme stringFromDate:endTime],distance);

            NSLog(@"start = %@\nend = %@\n",[forme stringFromDate:beginTime],[forme stringFromDate:endTime]);
            
            if (distance > 0) {
                [self.onceDataArray addObject:@{    @"mileage":@(distance),
                                                  @"useTime":@(pushTime),
                                                  @"startTime":[forme stringFromDate:beginTime],
                                                  @"endTime":[forme stringFromDate:endTime],
                                                  @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString  }];
            }
            
            if ([NetWorkStatus isNetworkEnvironment]) {
//                [[pushDataAPI sharedInstance].pushDateArray addObject:model];
                [[pushDataAPI sharedInstance] startUploadPushData]; //开始上传数据
            }
            
            if (byte[5] == 0xFF) {   //表示为最后一条数据
                //上传数据
                if ([NetWorkStatus isNetworkEnvironment] && [self.onceDataArray isKindOfClass:[NSMutableArray class]]) {
                    [self.onceDataArray removeObjectAtIndex:0];   //最新一条数据不上传
                    if (self.onceDataArray.count > 0) {
                        NSDictionary *dict = @{ @"data":self.onceDataArray };
                        [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
                            
                        }];
                    }
                }
                //
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [BLEMANAGER writeValueForPeripheral:[BLEA4API notifySuccess]];  //请求界面数据
            }
        }
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0x0B){    //固件版本
        self.version = [NSString stringWithFormat:@"%hhu%hhu%hhu",byte[5],byte[6],byte[7]];
        NSString *version = [NSString stringWithFormat:@"V %hhu.%hhu.%hhu",byte[5],byte[6],byte[7]];
        self.moreOperation.versionLabel.text = version;
        return;
    }else if (byte[3] == 0x8b && byte[4] == 0xAA){    //一键关机
        [self.electricityView closeBattery];
        [self.brakeview closeBrake];
    }else if (byte[3] == 0x8b && byte[4] == 0x20){    //推行数据
//        NSLog(@"分段数据%@\n",BLEMANAGER.deviceCallBack);
        if (byte[2] == 0x00) {         //数据域为0 表示开始获取推行数据的回调
            [BLEMANAGER writeValueForPeripheral:[BLEA4API getSurplusPushData]];  //获取一条数据
        }else if (byte[2] == 0x01){    //数据域为1 表示底层没有数据
            //上传数据
            if ([NetWorkStatus isNetworkEnvironment] && [self.onceDataArray isKindOfClass:[NSMutableArray class]] && self.onceDataArray.count > 0) {
                [self.onceDataArray removeObjectAtIndex:0];   //最新一条数据不上传
                if (self.onceDataArray.count > 0) {
                    NSDictionary *dict = @{ @"data":self.onceDataArray };
                    [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }
            }
            
            //
            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [BLEMANAGER writeValueForPeripheral:[BLEA4API notifySuccess]];  //请求界面数据
        }else if (byte[2] == 0x0E){    //数据域为14 表示有推行数据
            if (self.isShowHUD == NO) {
                [MBProgressHUD showLoadingWithMessag:@"正在同步数据"];
                self.isShowHUD = YES;
            }
            //处理推行数据
            long time1   = (byte[7]<<24) + (byte[8]<<16) + (byte[9]<<8) + byte[10];    //开始推行时间
            long time2   = (byte[11]<<24) + (byte[12]<<16) + (byte[13]<<8) + byte[14];    //结束推行时间
            int distance = (byte[15]<<8) + byte[16];
            int pushTime = (byte[17]<<8) + byte[18];
            
            NSDateFormatter *forme = [[NSDateFormatter alloc] init];
            forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            NSDate *baseDate = [forme dateFromString:@"1980 01 02 00 00 00"];
            NSDate *beginTime = [NSDate dateWithTimeInterval:time1 sinceDate:baseDate];
            NSDate *endTime = [NSDate dateWithTimeInterval:time2 sinceDate:baseDate];
//            forme.dateFormat = @"YYYY-MM-dd HH:mm:";
//            NSString *beginStr = [NSString stringWithFormat:@"%@00",[forme stringFromDate:beginTime]];
            forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//            beginTime = [forme dateFromString:beginStr];
//            CarA4PushDataModel *model = [[CarA4PushDataModel alloc] initWithStartTime:beginTime endTime:endTime mileage:distance useTime:pushTime];
            NSLog(@"start = %@\nend = %@\n",[forme stringFromDate:beginTime],[forme stringFromDate:endTime]);
            
            if(distance > 0){
                [self.onceDataArray addObject:@{  @"mileage":@(distance),
                                                  @"useTime":@(pushTime),
                                                  @"startTime":[forme stringFromDate:beginTime],
                                                  @"endTime":[forme stringFromDate:endTime],
                                                  @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString  }];
            }
            
//            [[pushDataAPI sharedInstance].pushDateArray addObject:model];
//            [[pushDataAPI sharedInstance] startUploadPushData]; //开始上传数据
            
            [BLEMANAGER writeValueForPeripheral:[BLEA4API getSurplusPushData]];  //请求下一条
        }
        return;
    }
}

-(CGFloat)getBatteryLevelWithInt:(int)number{
    switch (number) {
        case 80:
            return 1.0;  //电量等级
        case 40:
            return 0.6;
        case 15:
            return 0.2;
        case 5:
            return 0.1;
        default:
            return 0.0;
    }
}

#pragma mark - tableviewdelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 8;}    //8
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{return 1;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return RealWidth(95) + 87;       //电量
    }else if (indexPath.section == 1){   //刹车
        if (self.fuctionType == 2) {
            return 179;
        }else{
            return 133;
        }
    }else if (indexPath.section == 2){
        return 40;                      //灵敏度
    }else if (indexPath.section == 3){
        return self.fuctionType == 3 ? 157 : 0.0001;  //灯光
    }else if (indexPath.section == 4){
        return 80;                         //防盗锁
    }else if (indexPath.section == 5){
        return 244;                        //提示音
    }else if (indexPath.section == 6){
        return 245;                        //更多操作
    }else if (indexPath.section == 7){
        return RealWidth(69) + 79;          //关机
    }
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 47;
    }else if (section == 7 || section == 2){
        return 0.0001;
    }else if (section == 3){
        return self.fuctionType == 3 ? 40 : 0.00001;
    }
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = kWhiteColor;
    header.frame = CGRectMake(0, 0, ScreenWidth, 40);
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
    label.frame = CGRectMake(20, 20, 200, 20);
    [header addSubview:label];
    
    if (section == 0) {
        header.frame = CGRectMake(0, 0, ScreenWidth, 47);
        label.frame = CGRectMake(20, 27, 100, 20);
        label.text = NSLocalizedString(@"电量", nil);
    }else if (section == 1){
        label.text = NSLocalizedString(@"刹车", nil);
    }else if (section == 3){
        if (self.fuctionType == 3) {
            label.text = NSLocalizedString(@"灯光", nil);
        }
    }else if (section == 4){
        label.text = NSLocalizedString(@"防盗锁", nil);
        if (BLEMANAGER.currentPeripheral == nil) {
            self.lockImageView.hidden = YES;
        }
        [header addSubview:self.lockImageView];
    }else if (section == 5){
        label.text = NSLocalizedString(@"提示音", nil);
    }else if (section == 6){
        label.text = NSLocalizedString(@"更多操作", nil);
    }
    return header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0.00001;
    }else if (section == 3){
        return self.fuctionType == 3 ? 7 : 0.000001;
    }
    return 7;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
    footer.frame = CGRectMake(0, 0, ScreenWidth, 7);
    if (section == 1) {
        footer.frame = CGRectMake(0, 0, ScreenWidth, 0);
    }else if (section == 3){
        if (self.fuctionType == 3) {
            footer.frame = CGRectMake(0, 0, ScreenWidth, 0);
        }
    }
    return footer;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView removeAllSubviews];
    
    if (indexPath.section == 0) {
        [cell.contentView addSubview:self.electricityView];
        return cell;
    }else if (indexPath.section == 1){
        [cell.contentView addSubview:self.brakeview];
        return cell;
    }else if (indexPath.section == 2){
        [cell.contentView addSubview:self.brakeSensitivity];
    }else if (indexPath.section == 3){
        if (self.fuctionType == 3) {
            [cell.contentView addSubview:self.carLight];
        }
    }else if (indexPath.section == 4){
        [cell.contentView addSubview:self.safeView];
        self.safeSwitch.on = self.isSafeOpen;
        return cell;
    }else if (indexPath.section == 5){
        [cell.contentView addSubview:self.promptview];
        return cell;
    }else if (indexPath.section == 6){
        [cell.contentView addSubview:self.moreOperation];
        return cell;
    }else if (indexPath.section == 7){
        [cell.contentView addSubview:self.shutDown];
        return cell;
    }
    return cell;
}
#pragma mark - lazy
-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"];
    }
    return _tableview;
}

-(CarA3HeaderView *)tableHeaderView{
    if (_tableHeaderView == nil) {
        _tableHeaderView = [[CarA3HeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CarA3HeaderViewHeight)];
    }
    return _tableHeaderView;
}

-(UIImageView *)lockImageView{
    if (_lockImageView == nil) {
        _lockImageView = [[UIImageView alloc] init];
        _lockImageView.image = ImageNamed(@"Artboard");
        _lockImageView.frame = CGRectMake(ScreenWidth-30-22, 17, 22, 27);
    }
    return _lockImageView;
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
            wself.safeSwitch.on = NO;
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
            [BLEMANAGER writeValueForPeripheral:[BLEA4API openSafety]];
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

-(electricityView *)electricityView{
    if (_electricityView == nil) {
        _electricityView = [[electricityView alloc] init];
        _electricityView.backgroundColor = kWhiteColor;
        _electricityView.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(95)+87);
    }
    return _electricityView;
}
-(brakeView *)brakeview{
    if (_brakeview == nil) {
        _brakeview = [[[NSBundle mainBundle] loadNibNamed:@"brakeView" owner:nil options:nil] firstObject];
        if (self.fuctionType == 2) {
            _brakeview.frame = CGRectMake(0, 0, ScreenWidth, 178);
        }else{
            _brakeview.frame = CGRectMake(0, 0, ScreenWidth, 132);
            [_brakeview hiddenAutoBrake];
        }
    }
    return _brakeview;
}

-(UIView *)brakeSensitivity{
    if (_brakeSensitivity == nil) {
        _brakeSensitivity = [[UIView alloc] init];
        _brakeSensitivity.backgroundColor = kWhiteColor;
        _brakeSensitivity.frame = CGRectMake(0, 0, ScreenWidth, 40);    //85
        __weak typeof(self) wself = self;
        [_brakeSensitivity addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            LanguageChangeViewController *language = [[LanguageChangeViewController alloc] init];
            language.vctype = brakeSenVC;
            language.brakeSen = wself.brakeSen;
            [wself.navigationController pushViewController:language animated:YES];
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor colorWithHexString:@"101010"];
        label.text = NSLocalizedString(@"智能刹车灵敏度调节", nil);
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        label.frame = CGRectMake(20, 5, 200, 16);
        [_brakeSensitivity addSubview:label];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.frame = CGRectMake(ScreenWidth-27, 0, 7, 12);
        arrow.centerY = label.centerY;
        arrow.image = ImageNamed(@"更多内容icon");
        [_brakeSensitivity addSubview:arrow];
    }
    return _brakeSensitivity;
}

-(UIView *)safeView{
    if (_safeView == nil) {
        _safeView = [[UIView alloc] init];
        _safeView.backgroundColor = kWhiteColor;
        _safeView.frame = CGRectMake(0, 0, ScreenWidth, 80);
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        label1.text = NSLocalizedString(@"一键防盗", nil);
        label1.textColor = [UIColor colorWithHexString:@"#101010"];
        label1.frame = CGRectMake(20, 25, 100, 16);
        [_safeView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        label2.text = NSLocalizedString(@"开启后推车将被锁住", nil);
        label2.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
        label2.frame = CGRectMake(20, label1.bottom+7, 200, 12);
        [_safeView addSubview:label2];
        
        self.safeSwitch = [[UISwitch alloc] init];
        self.safeSwitch.onTintColor = [UIColor colorWithHexString:@"#E04E63"];
        self.safeSwitch.frame = CGRectMake(ScreenWidth-67, 0, 47, 31);
        self.safeSwitch.centerY = label1.centerY;
        self.safeSwitch.on = NO;
        [_safeView addSubview:self.safeSwitch];
        [self.safeSwitch addTarget:self action:@selector(safeSwitchValueChange) forControlEvents:UIControlEventValueChanged];
    }
    return _safeView;
}

-(void)safeSwitchValueChange{
    if (self.safeSwitch.on == NO) {
        [BLEMANAGER writeValueForPeripheral:[BLEA4API closeSafety]];
    }else{
        [self.view addSubview:self.lockHUD];   //提示框 二次确认
    }
}

-(promptView *)promptview{
    if (_promptview == nil) {
        _promptview = [[[NSBundle mainBundle] loadNibNamed:@"promptView" owner:nil options:nil] firstObject];
        _promptview.frame = CGRectMake(0, 0, ScreenWidth, 255);
    }
    return _promptview;
}

-(moreOperationsView *)moreOperation{
    if (_moreOperation == nil) {
        _moreOperation = [[[NSBundle mainBundle] loadNibNamed:@"moreOperationsView" owner:nil options:nil] firstObject];
        _moreOperation.frame = CGRectMake(0, 0, ScreenWidth, 245);
        _moreOperation.deviceName.text = self.deviceName;
        _moreOperation.device = self.deviceModel;
    }
    return _moreOperation;
}

-(lightView *)carLight{
    if (_carLight == nil) {
        _carLight = [[[NSBundle mainBundle] loadNibNamed:@"lightView" owner:nil options:nil] firstObject];
        _carLight.frame = CGRectMake(0, 0, ScreenWidth, 157);
    }
    return _carLight;
}

-(UIView *)shutDown{
    if (_shutDown == nil) {
        _shutDown = [[UIView alloc] init];
        _shutDown.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
        _shutDown.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(69) + 79);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = ImageNamed(@"button_关机");
        imageView.frame = CGRectMake(0, 32, RealWidth(67), RealWidth(69));
        imageView.centerX = _shutDown.centerX;
        [_shutDown addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        [imageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"是否关机？", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [BLEMANAGER writeValueForPeripheral:[BLEA4API closeDevice]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        label.text = NSLocalizedString(@"关机", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(0, imageView.bottom, 50, 15);
        label.centerX = _shutDown.centerX;
        label.textColor = [UIColor colorWithHexString:@"#333333"];
        [_shutDown addSubview:label];
    }
    return _shutDown;
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
@end
