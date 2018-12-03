//
//  bleConnectPromptView.m
//  Buggy
//
//  Created by goat on 2018/6/5.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "bleConnectPromptView.h"
#import "BlueToothManager.h"
@interface bleConnectPromptView()
@property (nonatomic,strong) UIView *BGView;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *redView;

@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UILabel *bottomLabel1;
@property (nonatomic,strong) UILabel *bottomLabel2;
@property (nonatomic,strong) UILabel *bottomLabel3;
@property (nonatomic,strong) UILabel *bottomLabel4;

@property (nonatomic,strong) UILabel *btn;
@property (nonatomic,strong) CAGradientLayer *btnlayer;

//@property (nonatomic,strong)
@end
@implementation bleConnectPromptView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [self addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself removeFromSuperview];
        }];
        
        self.BGView = [[UIView alloc] init];
        self.BGView.backgroundColor = kWhiteColor;
        self.BGView.userInteractionEnabled = YES;
        [self.BGView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
        }];
        [self addSubview:self.BGView];
        
        self.shapeLayer = [CAShapeLayer layer];  //FDF4F5  F8F8F8
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"E55F74"].CGColor;
        self.shapeLayer.lineWidth = 12;
        [self.BGView.layer addSublayer:self.shapeLayer];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = ImageNamed(@"connect2");
        [self.BGView addSubview:self.imageView];
        
        //文字
        self.topLabel = [[UILabel alloc] init];
        self.topLabel.text = NSLocalizedString(@"推车连接失败", nil);
        self.topLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:RealWidth(24)];
        self.topLabel.textColor = [UIColor colorWithHexString:@"2D2D2D"];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        [self.BGView addSubview:self.topLabel];
        
        self.redView = [[UIView alloc] init];
        self.redView.backgroundColor = [UIColor colorWithHexString:@"E04E63"];
        [self.BGView addSubview:self.redView];
        
        self.bottomLabel1 = [[UILabel alloc] init];
        self.bottomLabel1.text = NSLocalizedString(@"连接前请确认", nil);
        self.bottomLabel1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:RealWidth(14)];
        self.bottomLabel1.textColor = [UIColor colorWithHexString:@"E04E63"];
        self.bottomLabel1.textAlignment = NSTextAlignmentLeft;
        [self.BGView addSubview:self.bottomLabel1];
        
        self.bottomLabel2 = [[UILabel alloc] init];
        self.bottomLabel2.text = NSLocalizedString(@"1、推车已经开启，手机蓝牙已开启", nil);
        self.bottomLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(16)];
        self.bottomLabel2.textColor = [UIColor colorWithHexString:@"2D2D2D"];
        self.bottomLabel2.textAlignment = NSTextAlignmentLeft;
        [self.BGView addSubview:self.bottomLabel2];
        
        self.bottomLabel3 = [[UILabel alloc] init];
        self.bottomLabel3.text = NSLocalizedString(@"2、推车处于非休眠状态", nil);
        self.bottomLabel3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(16)];
        self.bottomLabel3.textColor = [UIColor colorWithHexString:@"2D2D2D"];
        self.bottomLabel3.textAlignment = NSTextAlignmentLeft;
        [self.BGView addSubview:self.bottomLabel3];
        
        self.bottomLabel4 = [[UILabel alloc] init];
        self.bottomLabel4.text = NSLocalizedString(@"3、手机距离推车需小于10m", nil);
        self.bottomLabel4.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(16)];
        self.bottomLabel4.textColor = [UIColor colorWithHexString:@"2D2D2D"];
        self.bottomLabel4.textAlignment = NSTextAlignmentLeft;
        [self.BGView addSubview:self.bottomLabel4];
        
        self.btn = [[UILabel alloc] init];
        self.btn.text = NSLocalizedString(@"确定连接", nil);
        self.btn.font = [UIFont fontWithName:@"PingFangSC-Medium" size:RealWidth(20)];
        self.btn.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.btn.textAlignment = NSTextAlignmentCenter;
        [self.BGView addSubview:self.btn];
        self.btn.userInteractionEnabled = YES;
        __weak typeof(self.btn) weakBtn = self.btn;
        [self.btn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([weakBtn.text isEqualToString:NSLocalizedString(@"确定连接", nil)]) {
                weakBtn.text = NSLocalizedString(@"正在连接...", nil);
                //圆圈颜色变化
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
                animation.keyPath = @"strokeColor";
                animation.duration = 3;
                animation.repeatCount = MAXFLOAT;
                animation.values = @[(__bridge id)[UIColor colorWithHexString:@"FDF4F5"].CGColor,
                                     (__bridge id)[UIColor colorWithHexString:@"E66579"].CGColor,
                                     (__bridge id)[UIColor colorWithHexString:@"E66579"].CGColor,
                                     (__bridge id)[UIColor colorWithHexString:@"FDF4F5"].CGColor];
                [wself.shapeLayer addAnimation:animation forKey:nil];
                //文字变化
                [wself labelAnimationOne];
                //连接蓝牙
                [BLEMANAGER stopScanBLE];
                [BLEMANAGER startScanBLEWithTimeout:2.5];
                //2.5秒过后如果还未连接则返回开始连接界面
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (BLEMANAGER.currentPeripheral == nil) {
                        wself.bottomLabel2.textAlignment = NSTextAlignmentLeft;
                        wself.bottomLabel2.text = NSLocalizedString(@"1、推车已经开启，手机蓝牙已开启", nil);
                        wself.topLabel.text = NSLocalizedString(@"推车连接失败", nil);
                        wself.btn.text = NSLocalizedString(@"确定连接", nil);
                        [wself.shapeLayer removeAllAnimations];
                        [wself layoutSubviews];
                    }
                });
            }else if ([weakBtn.text isEqualToString:NSLocalizedString(@"开始体验", nil)]){
                [wself removeFromSuperview];
            }
        }];
        
        self.btnlayer = [CAGradientLayer layer];
        self.btnlayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#F2869C"].CGColor,
                                 (__bridge id)[UIColor colorWithHexString:@"#E04E63"].CGColor];
        self.btnlayer.locations = @[@0,@1];
        self.btnlayer.startPoint = CGPointMake(0, 0);
        self.btnlayer.endPoint = CGPointMake(1, 0);
        [self.btn.layer addSublayer:self.btnlayer];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.BGView.frame = CGRectMake(0, 0, RealWidth(330), RealWidth(400));
    self.BGView.center = self.center;
    self.BGView.layer.cornerRadius = 6;
    
    self.imageView.frame = CGRectMake(0, -RealWidth(57), RealWidth(114), RealWidth(114));
    self.imageView.centerX = self.BGView.width/2;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.imageView.frame];
    self.shapeLayer.path = path.CGPath;
    
    //文字
    self.topLabel.frame = CGRectMake(0, RealWidth(104), RealWidth(330), RealWidth(24));
    self.redView.frame = CGRectMake(0, self.topLabel.bottom + 10, 25, 5);
    self.redView.centerX = self.topLabel.centerX;
    self.bottomLabel1.frame = CGRectMake(RealWidth(50), self.topLabel.bottom+RealWidth(42), RealWidth(330), RealWidth(16));
    self.bottomLabel2.frame = CGRectMake(RealWidth(50), self.bottomLabel1.bottom+RealWidth(18), RealWidth(330), RealWidth(16));
    self.bottomLabel3.frame = CGRectMake(RealWidth(50), self.bottomLabel2.bottom+RealWidth(18), RealWidth(330), RealWidth(16));
    self.bottomLabel4.frame = CGRectMake(RealWidth(50), self.bottomLabel3.bottom+RealWidth(18), RealWidth(330), RealWidth(16));
    
    self.btn.frame = CGRectMake(0, self.BGView.height - RealWidth(55), self.BGView.width, RealWidth(55));
    self.btnlayer.frame = self.btn.bounds;
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:self.btn.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path2.CGPath;
    self.btn.layer.mask = layer;
}

-(void)connectSuccess{
    self.btn.text = NSLocalizedString(@"开始体验", nil);
    //btn颜色渐变
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"colors";
    anim.toValue = @[(__bridge id)[UIColor colorWithHexString:@"#9FF4B8"].CGColor,
                     (__bridge id)[UIColor colorWithHexString:@"#1AB060"].CGColor];
    anim.duration = 1.0;
    anim.removedOnCompletion = NO;          //动画完成时不移除动画
    anim.fillMode = kCAFillModeForwards;    //动画完成时保持最新位置
    [self.btnlayer addAnimation:anim forKey:nil];
    //圆圈颜色变化
    [self.btn.layer removeAllAnimations];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"strokeColor";
    animation.duration = 2;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;          //动画完成时不移除动画
    animation.fillMode = kCAFillModeForwards;
    animation.values = @[(__bridge id)[UIColor colorWithHexString:@"FDF4F5"].CGColor,
                         (__bridge id)[UIColor colorWithHexString:@"58C58E"].CGColor];
    [self.shapeLayer addAnimation:animation forKey:nil];
    //文字
    [self labelAnimationTwo];
}

-(void)labelAnimationOne{
    [UIView animateWithDuration:0.5 animations:^{
        self.topLabel.left -= RealWidth(330);
        self.bottomLabel1.left -= RealWidth(330);
        self.bottomLabel2.left -= RealWidth(330);
        self.bottomLabel3.left -= RealWidth(330);
        self.bottomLabel4.left -= RealWidth(330);
    } completion:^(BOOL finished) {
        self.topLabel.text = NSLocalizedString(@"正在连接推车", nil);
        self.topLabel.left = RealWidth(330);
        self.bottomLabel2.text = NSLocalizedString(@"连接过程应该一闪而过", nil);
        self.bottomLabel2.textAlignment = NSTextAlignmentCenter;
        self.bottomLabel2.left = RealWidth(330);
        [UIView animateWithDuration:0.4 animations:^{
            self.topLabel.left = 0;
            self.bottomLabel2.left = 0;
        }];
    }];
}

-(void)labelAnimationTwo{
    [UIView animateWithDuration:0.5 animations:^{
        self.topLabel.left -= RealWidth(330);
        self.bottomLabel2.left -= RealWidth(330);
    } completion:^(BOOL finished) {
        self.topLabel.text = NSLocalizedString(@"推车连接成功", nil);
        self.topLabel.left = RealWidth(330);
        self.bottomLabel2.text = NSLocalizedString(@"连接成功，快开始体验吧！", nil);
        self.bottomLabel2.left = RealWidth(330);
        [UIView animateWithDuration:0.4 animations:^{
            self.topLabel.left = 0;
            self.bottomLabel2.left = 0;
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
