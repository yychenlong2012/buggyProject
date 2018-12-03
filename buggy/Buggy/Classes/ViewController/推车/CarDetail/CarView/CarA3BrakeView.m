//
//  CarA3BrakeView.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/1.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3BrakeView.h"
#define   _runStatusImageX 120
#define   _carWheelImageX (70 * _MAIN_RATIO_375)
#define   _brakePadImageX (70 * _MAIN_RATIO_375)
@implementation CarA3BrakeView{
    UIImageView *_bgBrakeImageView;  // 刹车背景图
    UIImageView *_carWheelImage;     // 车轮
    UIImageView *_brakePadImage;     // 刹车片
    UIImageView *_runStatusImage;    // 运行的状态动画
    
    UIImageView *_unconnectedBgImage;// 未连接的图片
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
//    CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375)
    
    _bgBrakeImageView = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"Travel_BrakeBG") onView:self];
    _runStatusImage = [Factory imageViewWithCenter:CGPointMake(120 * _MAIN_RATIO_375, _bgBrakeImageView.height / 2 + 5 * _MAIN_RATIO_375) image:ImageNamed(@"Travel_SpeedStatus") onView:_bgBrakeImageView];
    _carWheelImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 55 * _MAIN_RATIO_375, 55 * _MAIN_RATIO_375) image:ImageNamed(@"Travel_Wheel") onView:_bgBrakeImageView];
    _brakePadImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 38 * _MAIN_RATIO_375, 23 *_MAIN_RATIO_375) image:ImageNamed(@"Travel_BrakePad") onView:_bgBrakeImageView];
    //[self beginBrakePadAnimation];
    
    _unconnectedBgImage = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"unconnected-刹车") onView:self];
    _unconnectedBgImage.backgroundColor = [UIColor whiteColor];
    
    _carWheelImage.center = CGPointMake(_carWheelImageX, _bgBrakeImageView.height/2 + 5 * _MAIN_RATIO_375);
    _brakePadImage.center = CGPointMake(_brakePadImageX, 18 * _MAIN_RATIO_375);
//    BOOL braking = [KUserDefualt_Get(BRAKINGSTATUS) boolValue];
//    [self setBLEConnectStatus:braking];
}

- (void)layoutSubviews{
    [super layoutSubviews];
   
}


#pragma mark -- 轮子动画

- (CAAnimation *)carWheelImageAnimation{
//    CAMediaTimingFunction *media = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue= [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat: 0];
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 1;
//    rotationAnimation.timingFunction =  media;
    return rotationAnimation;
}

/* 只有设备连接之后才能 */
- (void)beginWheelAnimation{
    
 
    CABasicAnimation *base = (CABasicAnimation *)[self carWheelImageAnimation];
    [_carWheelImage.layer addAnimation:base forKey:@"carWheelImageAnimation"];
    if (_brakePadImage.layer.animationKeys.count > 0) {
        [_brakePadImage.layer removeAllAnimations];
    }
}

-(void)beginWheelAnimation2
{
    CABasicAnimation *base = [CABasicAnimation animation];
    base.keyPath = @"transform.rotation.z";
    base.duration = 0.25;
    base.repeatCount = MAXFLOAT;
    base.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    base.toValue = [NSNumber numberWithFloat:22 * M_PI]; // 终止角度
    
    [_carWheelImage.layer addAnimation:base forKey:@"carWheelImageAnimation"];
}

- (void)removeWheelAnimation{
 
    [_carWheelImage.layer removeAllAnimations];
}

- (CAAnimationGroup *)brakepadAniamtion{

    CAKeyframeAnimation *brakepadPosition = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    brakepadPosition.values= @[[NSValue valueWithCGPoint:CGPointMake(70 * _MAIN_RATIO_375, 18 * _MAIN_RATIO_375)],
                               [NSValue valueWithCGPoint:CGPointMake((70 + 21) * _MAIN_RATIO_375, 35 * _MAIN_RATIO_375)]];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue= [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI/4];
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.5;
    group.removedOnCompletion = NO;
    group.autoreverses = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[brakepadPosition,rotationAnimation];
    return group;
    
}

- (void)addStatusImageAnimation{
   
    _runStatusImage.centerX = _runStatusImageX ;
    _carWheelImage.centerX = _carWheelImageX;
    _brakePadImage.centerX = _brakePadImageX;
    [UIView animateWithDuration:1.5 animations:^{ 
        self->_runStatusImage.alpha = 0;
    }];
}

- (void)removeStatusImageAnimation{
    _runStatusImage.centerX = _runStatusImageX -15;
    _carWheelImage.centerX = _carWheelImageX-15;
    _brakePadImage.centerX = _brakePadImageX-15;
    [UIView animateWithDuration:1.5 animations:^{
        self->_runStatusImage.alpha = 1.0;
    }];
}

- (void)beginBrakePadAnimation{
    dispatch_async(dispatch_get_main_queue(), ^{
        CAAnimationGroup *animation = [self brakepadAniamtion];
        [self->_brakePadImage.layer addAnimation:animation forKey:@"brakepadAniamtion"];
        if (self->_carWheelImage.layer.animationKeys.count > 0) {
            [self->_carWheelImage.layer removeAllAnimations];
        }
        [self addStatusImageAnimation];
    });
}

- (void)removeBrakePadAnimation{
    _runStatusImage.centerX = _runStatusImageX ;
    _carWheelImage.centerX = _carWheelImageX;
    _brakePadImage.centerX = _brakePadImageX;

    [_brakePadImage.layer removeAllAnimations];
    [self removeStatusImageAnimation];
}

- (void)setBLEConnectStatus:(BOOL)connect{
    _unconnectedBgImage.hidden = connect;
    _bgBrakeImageView.hidden = !connect;
}

//我的修改
- (void)setBLEConnectStatus2:(BOOL)connect{
    _unconnectedBgImage.hidden = NO;
    _bgBrakeImageView.hidden = YES;
}


@end
