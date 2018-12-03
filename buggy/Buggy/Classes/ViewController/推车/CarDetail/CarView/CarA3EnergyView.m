//
//  CarA3EnergyView.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/1.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3EnergyView.h"

static const NSInteger  EnergyZero = 0;
static const NSInteger  EnergyWarn = 20;
static const NSInteger  EnergyNormal = 60;
static const NSInteger  EnergyFull = 100;


@implementation CarA3EnergyView{

    UIImageView *_bgEnergyImageView;   // 电量背景图
    UIImageView *_energyMaskImageView; // 电量反光图片
    CAGradientLayer *_gradientLayer;   // 能量渐变色
    
    UIImageView *_unconnectedBgImage;  // 未连接的状态的图片
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
    _bgEnergyImageView = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"Travel_BlueBG") onView:self];
    _gradientLayer = [CAGradientLayer layer];
    _energyMaskImageView = [Factory imageViewWithFrame:CGRectMake(0, 0, 27.5 * _MAIN_RATIO_375, 41.5 * _MAIN_RATIO_375) image:ImageNamed(@"Travel_blink") onView:nil];
    [_bgEnergyImageView.layer insertSublayer:_energyMaskImageView.layer above:_gradientLayer];
    
    _unconnectedBgImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375) image:ImageNamed(@"unconnected-电量") onView:self];
    _unconnectedBgImage.backgroundColor = [UIColor whiteColor];
    _unconnectedBgImage.hidden = YES;
}

- (void)setEnergyImageAndEnergyColor:(NSInteger )percent{
    
    float total = 100;
    float unit = 41.50 / 100.00;
    float top = 30;
    
    if (percent >= EnergyZero && percent <= EnergyWarn) { //   20 => x >0
        [_bgEnergyImageView setImage:ImageNamed(@"Travel_RedBG")];
        _gradientLayer.colors = @[(__bridge id)COLOR_HEXSTRING(@"#ED487A").CGColor,(__bridge id)COLOR_HEXSTRING(@"#B33647").CGColor];
        _gradientLayer.frame = CGRectMake(65 * _MAIN_RATIO_375, (top + (total - percent) * unit) * _MAIN_RATIO_375, 25 * _MAIN_RATIO_375, (percent * unit) * _MAIN_RATIO_375);
        
    }else if (percent > EnergyWarn && percent <= EnergyNormal){ //   60 > x >20
        
        [_bgEnergyImageView setImage:ImageNamed(@"Travel_OrangeBG")];
        _gradientLayer.colors = @[(__bridge id)COLOR_HEXSTRING(@"#FCCA6D").CGColor,(__bridge id)COLOR_HEXSTRING(@"#CE6435").CGColor];
        _gradientLayer.frame = CGRectMake(65 * _MAIN_RATIO_375, (top + (total - percent) * unit -6) * _MAIN_RATIO_375, 25 * _MAIN_RATIO_375, (percent * unit +5) * _MAIN_RATIO_375);
        
    }else if (percent > EnergyNormal && percent <= EnergyFull){ //   100 => x >=60
        
        [_bgEnergyImageView setImage:ImageNamed(@"Travel_BlueBG")];
        _gradientLayer.colors = @[(__bridge id)COLOR_HEXSTRING(@"#4EE77A").CGColor,(__bridge id)COLOR_HEXSTRING(@"#117E47").CGColor];
        _gradientLayer.frame = CGRectMake(65 * _MAIN_RATIO_375, (top + (total - percent) * unit -6) * _MAIN_RATIO_375, 25 * _MAIN_RATIO_375, (percent * unit +5) * _MAIN_RATIO_375);
    }
    
    _gradientLayer.startPoint = CGPointMake(0.0,0.0);
    _gradientLayer.endPoint = CGPointMake(0.0,1.0);
    [_bgEnergyImageView.layer addSublayer:_gradientLayer];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _energyMaskImageView.top = 30 * _MAIN_RATIO_375;
    _energyMaskImageView.left = 65 * _MAIN_RATIO_375;
}

- (void)setBLEConnectStatus:(BOOL)connect{
    _unconnectedBgImage.hidden = connect;    //未连接的状态图片
    _bgEnergyImageView.hidden = !connect;    //电量背景
}




@end
