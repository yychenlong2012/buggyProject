//
//  Dry1ViewController.m
//  Buggy
//
//  Created by goat on 2019/2/22.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import "Dry1ViewController.h"
#import "BlueToothManager.h"
#import "DryFootApi.h"
#import "CLImageView.h"
#import "MainModel.h"

#define scanTime 10  //蓝牙扫描时间

@interface Dry1ViewController ()<BlueToothManagerDelegate>
@property (nonatomic,strong) NSTimer *timer;     //开启定时器搜索连接蓝牙
@property (nonatomic,strong) UIView *naviView;    //自定义导航栏背景view
@property (nonatomic,strong) UILabel *naviLabel;
@end

@implementation Dry1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.naviView];
    BLEMANAGER.delegate = self;

    //连接蓝牙 请求数据
    if ([self isBLEConnected]) {
        [BLEMANAGER writeValueForPeripheral:[DryFootApi getDeviceData]];  //时间同步
    }else{
        if (self.timer == nil) {
            self.timer = [NSTimer timerWithTimeInterval:scanTime target:self selector:@selector(time) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
}

//每隔一段时间搜索一次蓝牙
-(void)time{
    [BLEMANAGER startScanBLEWithTimeout:3];
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

#pragma mark - bleDelegate
//已经发现蓝牙设备
-(void)didDiscoverPeripheral:(NSMutableArray<CBPeripheral *>*)peripherals{
    //判断扫描到的蓝牙里面有没有同名的
    for (CBPeripheral *per in peripherals) {
        if ([per.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
            [BLEMANAGER connectPeripheralDevice:per];
        }
    }
}

//已经连接到蓝牙设备
-(void)didConnectPeripheral:(CBPeripheral*)peripherial{
    //停止定时器
    [self.timer invalidate];
    self.timer = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [BLEMANAGER writeValueForPeripheral:[BLEA4API synchronizationTime]];  //时间同步
    });
}


//已经断开蓝牙外设
-(void)didDisconnectPeripheral:(CBPeripheral*)peripheral{
    [MainModel model].bluetoothUUID = nil;
    //部分功能和界面变化

    //蓝牙断开时要开启定时器 定时搜索蓝牙
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:scanTime target:self selector:@selector(time) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

//接收到蓝牙数据A3
-(void)getValueForPeripheral{
    NSArray *dataArray = BLEMANAGER.deviceCallBack;
    if (dataArray == nil || dataArray.count == 0){
        return;
    }
    NSData *data = [dataArray firstObject];
    Byte *byte = (Byte *)[data bytes];
    if (byte[3] == 0x8D && byte[4] == 0x01) {        //蓝牙数据
        
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x02){   //体重体脂
        
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x03){   //体重单位
        
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x04){   //档位
        
    }
}

#pragma mark - lazy
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
