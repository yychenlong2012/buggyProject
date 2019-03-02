//
//  DryFootViewController.m
//  Buggy
//
//  Created by goat on 2019/2/25.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import "DryFootViewController.h"
#import "BlueToothManager.h"
#import "DryFootApi.h"
#import "CLImageView.h"
#import "MainModel.h"
#import "MYLabel.h"
#import "weightDataLineView.h"

#define scanTime 10  //蓝牙扫描时间

@interface DryFootViewController ()<BlueToothManagerDelegate>
@property (nonatomic,strong) NSTimer *timer;     //开启定时器搜索连接蓝牙
@property (nonatomic,strong) UIView *naviView;    //自定义导航栏背景view
@property (nonatomic,strong) UILabel *naviLabel;

@property (weak, nonatomic) IBOutlet UIButton *KgBtn;
@property (weak, nonatomic) IBOutlet UIButton *jinBtn;
@property (weak, nonatomic) IBOutlet UIButton *bangBtn;
@property (weak, nonatomic) IBOutlet UISlider *windLevel;
@property (weak, nonatomic) IBOutlet UIView *weightDataView;

@property (weak, nonatomic) IBOutlet UILabel *weight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;

@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) weightDataLineView *dataView;

@end

@implementation DryFootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviView];
    BLEMANAGER.delegate = self;

    //连接蓝牙 请求数据
    if ([self isBLEConnected]) {
        [BLEMANAGER writeValueForPeripheral:[DryFootApi getDeviceData]];  //获取数据
    }else{
        if (self.timer == nil) {
            self.timer = [NSTimer timerWithTimeInterval:scanTime target:self selector:@selector(time) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
    
    if (@available(iOS 11.0, *)) {
        self.scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
}
/*
 function createCode($user_id) {
 static $source_string = 'E5FCDG3HQA4B1NOPIJ2RSTUV67MWX89KLYZ';
 $num = $user_id;
 $code = '';
 while ( $num > 0) {
 $mod = $num % 35;
 $num = ($num - $mod) / 35;
 $code = $source_string[$mod].$code;
 }
 if(empty($code[3]))
 $code = str_pad($code,4,'0',STR_PAD_LEFT);
 return $code;
 }
 */
//
//-(NSString *)creatCodeWithID:(NSInteger)idNum{
//    static NSString *source_string = @"E5FCDG3HQA4B1NOPIJ2RSTUV67MWX89KLYZ";
//    NSString *code = @"";
//    while (idNum > 0) {
//        NSInteger mod = idNum % 35;
//        idNum = (idNum - mod) / 35;
//        NSString *str = [source_string substringWithRange:NSMakeRange(mod, 1)];
//        code = [str stringByAppendingString:code];
//    }
//
//    return code;
//}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.topMargin.constant = navigationH + 25;
    
    [self setLineUI];
    [self refreshData];
}

//设置曲线UI
-(void)setLineUI{
    self.scrollview = [[UIScrollView alloc] init];
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator = YES;
    self.scrollview.frame = self.weightDataView.bounds;
    self.scrollview.backgroundColor = kWhiteColor;
    self.scrollview.layer.borderWidth = 0.5;
    [self.weightDataView addSubview:self.scrollview];
    self.weightDataView.clipsToBounds = NO;
    
    //最上层的画线view
    self.dataView = [[weightDataLineView alloc] init];
    self.dataView.backgroundColor = kWhiteColor;
    [self.scrollview addSubview:self.dataView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"单位：斤";
    label.textColor = kBlackColor;
    label.font = [UIFont systemFontOfSize:10];
    label.frame = CGRectMake(10, 10, 50, 10);
    [self.weightDataView addSubview:label];
    
    //刻度
    CGFloat rowHeight = self.scrollview.size.height / NumberOfRow;   //每行的高度
    
    for (int i = 0; i<NumberOfRow; i++) {
        MYLabel *label = [[MYLabel alloc] init];
        label.text = [NSString stringWithFormat:@"%d",(NumberOfRow-1-i)*50];
        label.frame = CGRectMake(-25, i*rowHeight - 0.5, 25, rowHeight);
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = kBlackColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.verticalAlignment = VerticalAlignmentBottom;
        
        //label底部横线
        CALayer *line = [CALayer layer];
        line.backgroundColor = kBlackColor.CGColor;
        line.frame = CGRectMake(0, label.size.height, label.size.width, 0.5);
        [label.layer addSublayer:line];
        [self.weightDataView addSubview:label];
        
        //scrollview底部横线
        CALayer *scaleLine = [CALayer layer];
        scaleLine.backgroundColor = kRGBAColor(0, 0, 0, 0.3).CGColor;
        scaleLine.frame = CGRectMake(0, i*rowHeight - 0.5, self.scrollview.size.width, 0.5);
        [self.weightDataView.layer addSublayer:scaleLine];
    }
}

//加载数据
-(void)refreshData{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"weightData.plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    if (array && array.count > 0) {
        self.scrollview.contentSize = CGSizeMake(LandScape*(array.count+2), 1);
        self.dataView.frame = CGRectMake(0, 0, LandScape*(array.count+2), self.scrollview.bounds.size.height);
        self.dataView.pointArray = array;
        //移动到最右边
        if ((self.scrollview.size.width/LandScape) < (array.count + 1)) {   //数据过少时没必要移动
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.scrollview setContentOffset:CGPointMake(LandScape*(array.count+2) - self.scrollview.size.width, 0) animated:YES];
            });
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


//风力等级
- (IBAction)windLevelChange:(UISlider *)sender {
    float levelNumber = floorf(sender.value);
    sender.value = levelNumber;
    NSLog(@"%f",sender.value);
    [BLEMANAGER writeValueForPeripheral:[DryFootApi setWindLevel:levelNumber]];
}


//单位切换
- (IBAction)kgBtnClick:(id)sender {
    [self setUintBtn:1];
    [BLEMANAGER writeValueForPeripheral:[DryFootApi setWeightUnit:1]];
}
- (IBAction)jinBtnClick:(id)sender {
    [self setUintBtn:2];
    [BLEMANAGER writeValueForPeripheral:[DryFootApi setWeightUnit:2]];
}
- (IBAction)bangBtnClick:(id)sender {
    [self setUintBtn:3];
    [BLEMANAGER writeValueForPeripheral:[DryFootApi setWeightUnit:3]];
}

//设置btn
- (void)setUintBtn:(NSInteger)num{
    [self.KgBtn setBackgroundImage:[UIImage imageNamed:@"unit_unselect"] forState:UIControlStateNormal];
    [self.jinBtn setBackgroundImage:[UIImage imageNamed:@"unit_unselect"] forState:UIControlStateNormal];
    [self.bangBtn setBackgroundImage:[UIImage imageNamed:@"unit_unselect"] forState:UIControlStateNormal];
    switch (num) {
        case 1:
            [self.KgBtn setBackgroundImage:[UIImage imageNamed:@"unit_selected"] forState:UIControlStateNormal];
            break;
        case 2:
            [self.jinBtn setBackgroundImage:[UIImage imageNamed:@"unit_selected"] forState:UIControlStateNormal];
            break;
        case 3:
            [self.bangBtn setBackgroundImage:[UIImage imageNamed:@"unit_selected"] forState:UIControlStateNormal];
            break;
        default:
            break;
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
    [MBProgressHUD showToast:@"蓝牙已连接"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [BLEMANAGER writeValueForPeripheral:[DryFootApi getDeviceData]];  //获取数据
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

//接收到蓝牙数据
-(void)getValueForPeripheral{
    NSArray *dataArray = BLEMANAGER.deviceCallBack;
    NSLog(@"蓝牙数据 %@",dataArray);
    if (dataArray == nil || dataArray.count == 0){
        return;
    }
    NSData *data = [dataArray firstObject];
    Byte *byte = (Byte *)[data bytes];
    if (byte[3] == 0x8D && byte[4] == 0x01) {        //蓝牙数据
        switch (byte[5]) {
            case 0x00:   //Kg
                [self setUintBtn:1];
                break;
            case 0x40:   //斤
                [self setUintBtn:2];
                break;
            case 0x80:   //磅
                [self setUintBtn:3];
                break;
            default:
                break;
        }
        
        if (byte[6] == 0x00) {   //无风无温档
            NSLog(@"无风无温档");
            self.windLevel.value = 0;
        }else if (byte[6] == 0xff){  //高档位
            NSLog(@"高档位");
            self.windLevel.value = 11;
        }else{    //中档位
            NSLog(@"中档位");
            self.windLevel.value = byte[6];
        }
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x02){   //体重体脂    <55aa080d 02100200 02000000 0000dd>
        [BLEMANAGER writeValueForPeripheral:[DryFootApi getWeightAndFatData]];   //停止底部发送
        int hight = byte[5]==0x10?0:byte[5];
        int middle = byte[6];
        int low = byte[7];
        int pot = byte[8];
        CGFloat weight = (hight*1000 + middle*100 + low*10 + pot) / 10.0;
        NSString *weightUint = @"Kg";
        switch (byte[13]) {
            case 0x00:   //Kg
                weightUint = @"Kg";
                break;
            case 0x40:   //斤
                weightUint = @"斤";
                break;
            case 0x80:   //磅
                weightUint = @"磅";
                break;
            default:
                break;
        }
        self.weight.text = [NSString stringWithFormat:@"%0.1f %@",weight,weightUint];

        //写入数据
        [self saveDataWithWeight:weight weightUint:weightUint];
        [self refreshData];
        
        NSLog(@"体重信息 %0.2f",weight);
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x03){   //体重单位
        switch (byte[5]) {
            case 0x00:   //Kg
                [self setUintBtn:1];
                break;
            case 0x40:   //斤
                [self setUintBtn:2];
                break;
            case 0x80:   //磅
                [self setUintBtn:3];
                break;
            default:
                break;
        }
        return;
    }else if (byte[3] == 0x8D && byte[4] == 0x04){   //档位
        self.windLevel.value = byte[5];
//        if (byte[5] == 0x00) {   //无风无温档
//            NSLog(@"无风无温档");
//        }else if (byte[5] == 0xff){  //高档位
//            NSLog(@"高档位 %d",byte[5]);
//        }else{    //中档位
//            NSLog(@"中档位");
//        }
    }
}

//存入数据
-(void)saveDataWithWeight:(CGFloat)weight weightUint:(NSString *)weightUint{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"weightData.plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
    CGFloat realWeight = weight;
    //将单位转成斤存入
    if ([weightUint isEqualToString:@"Kg"]) {
        realWeight = 2 * weight;
    }else if ([weightUint isEqualToString:@"磅"]) {
        realWeight = 0.9071848 * weight;
    }
    [mArray addObject:[NSString stringWithFormat:@"%0.1f",realWeight]];
    [mArray writeToFile:path atomically:YES];
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
