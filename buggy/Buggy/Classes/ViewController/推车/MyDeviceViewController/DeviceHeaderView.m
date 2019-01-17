//
//  DeviceHeaderView.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceHeaderView.h"
#import "UIImageView+Gif.h"

@interface DeviceHeaderView()
@property (nonatomic,strong) CAReplicatorLayer *replicator;
@end

@implementation DeviceHeaderView{
    
    UIImageView *_handleImage;
    UIImageView *_instructionImage;
    
    UILabel *_cartLB;
    UILabel *_openiPhoneBluetoothLB;

    UIImageView *_gifImage;
}

- (void)dealloc{
 
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

-(CAReplicatorLayer *)replicator{
    if (_replicator == nil) {
        //创建复制图层容器
        _replicator= [CAReplicatorLayer layer];
        _replicator.instanceCount = 7;
        _replicator.instanceDelay = 0.2;
        //放大动画
        CABasicAnimation *anim = [CABasicAnimation animation];
        anim.keyPath = @"transform.scale";
        anim.fromValue = @1;
        anim.toValue = @18;
        //透明度动画
        CABasicAnimation *anim2 = [CABasicAnimation animation];
        anim2.keyPath = @"opacity";
        anim2.toValue = @0.0;
        anim2.fromValue = @0.8;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[anim,anim2];
        group.duration = 1.4;
        group.repeatCount = 100;
        //创建子图层
        CALayer *layer = [CALayer layer];
        [layer addAnimation:group forKey:nil];
        layer.bounds = CGRectMake(0, 0, 8, 8);
        layer.cornerRadius = 4;
        layer.backgroundColor = COLOR_HEXSTRING(@"#EA779F").CGColor;
        [_replicator addSublayer:layer];
    }
    return _replicator;
}

- (void)addSearchAnimation{
    self.replicator.position = CGPointMake(ScreenWidth - 110 * _MAIN_RATIO_375,172 *_MAIN_RATIO_375);
    [self.layer insertSublayer:self.replicator below:_instructionImage.layer];
}

- (void)removeSearchAnimation{
    [self.replicator removeFromSuperlayer];
    self.replicator = nil;
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


