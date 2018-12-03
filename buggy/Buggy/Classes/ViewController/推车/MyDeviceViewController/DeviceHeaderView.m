//
//  DeviceHeaderView.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceHeaderView.h"
#import "Layer.h"
#import "UIImageView+Gif.h"

@implementation DeviceHeaderView{
    
    UIImageView *_handleImage;
    UIImageView *_instructionImage;
    
    UILabel *_cartLB;
    UILabel *_openiPhoneBluetoothLB;
    
    NSTimer *_timer;
    UIImageView *_gifImage;
}

- (void)dealloc{
 
    [_timer invalidate];
    _timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.backgroundColor = COLOR_HEXSTRING(@"#EEEEEE");
    // 车子开启提示
    _cartLB = [Factory labelWithFrame:CGRectMake(0, 0, 85 * _MAIN_RATIO_375, 40 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(14) text:NSLocalizedString(@"长按电源键\n启动设备", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self textAlignment:NSTextAlignmentCenter];
    _cartLB.adjustsFontSizeToFitWidth = YES;
    
    // 打开手机蓝牙提示
    _openiPhoneBluetoothLB = [Factory labelWithFrame:CGRectMake(0, 0, 85 * _MAIN_RATIO_375, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(14) text:NSLocalizedString(@"打开手机蓝牙", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self textAlignment:NSTextAlignmentCenter];
    _openiPhoneBluetoothLB.adjustsFontSizeToFitWidth = YES;
    
    // 车把手图片
    _handleImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 150 * _MAIN_RATIO_375, 50 * _MAIN_RATIO_375) image:ImageNamed(@"Device_CartHandle") onView:self];
    
    
    // 手机蓝牙打开图片
    _instructionImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 108 * _MAIN_RATIO_375, 118 * _MAIN_RATIO_375) image:ImageNamed(@"Device_Instructions") onView:self];
    
//    _instructionImage.alpha = 0.5;
    
    // gif 图片
    _gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"gif6.gif" ofType:nil];
    [_gifImage gif_setImage:[NSURL fileURLWithPath:path]];
    [self addSubview:_gifImage];
    
}

- (void)addSearchAnimation{
    
    __weak typeof(self) wself = self;
    
    if ([AYDeviceManager currentVersion]>10) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            Layer *layer = [Layer layer];
            layer.radius = 60;
            layer.animationDuration = 2;
            layer.position = CGPointMake(ScreenWidth - 110 * _MAIN_RATIO_375,172 *_MAIN_RATIO_375);
            [wself.layer insertSublayer:layer below:self->_instructionImage.layer];
        }];
    }else{
       _timer = [ NSTimer  scheduledTimerWithTimeInterval:2 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    }
}
- (void)animation{
    Layer *layer = [Layer layer];
    layer.radius = 60;
    layer.animationDuration = 2;
    layer.position = CGPointMake(ScreenWidth - 110 * _MAIN_RATIO_375,172 *_MAIN_RATIO_375);
    [self.layer insertSublayer:layer below:_instructionImage.layer];
}
- (void)removeSearchAnimation{
    
    [_timer invalidate];
    _timer = nil;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    _cartLB.top = 53 * _MAIN_RATIO_375;
    _cartLB.left = 68 * _MAIN_RATIO_375;
    
    _openiPhoneBluetoothLB.top = _cartLB.bottom + 100 * _MAIN_RATIO_375;
    _openiPhoneBluetoothLB.centerX = _cartLB.centerX;
    
    _handleImage.centerY = _cartLB.centerY;
    _handleImage.right = ScreenWidth - 35 * _MAIN_RATIO_375;
    
    _instructionImage.centerX = _handleImage.centerX;
    _instructionImage.bottom = DeviceHeaderViewHeight;
    
    _gifImage.center = _handleImage.center;
}

@end


@implementation DeviceSectionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    UILabel *label = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth, 24) font:FONT_DEFAULT_Light(17) text:NSLocalizedString(@"搜索到的设备", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self textAlignment:NSTextAlignmentLeft];
    label.left = 20 * _MAIN_RATIO_375;
    label.top = 18 * _MAIN_RATIO_375;
}

@end


