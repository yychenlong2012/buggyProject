//
//  CarA1TemperatureView.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA1TemperatureView.h"

@implementation CarA1TemperatureView{
    
    UIImageView *_bgTemperatureImageView;
    UILabel *_temperatureLB;
    UIImageView *_unconnectedBgImage;
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _bgTemperatureImageView = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"车内温度背景") onView:self];
    _temperatureLB = [Factory labelWithFrame:CGRectMake(0, 0, self.width/2, 30 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(30) text:nil textColor:nil onView:self textAlignment:NSTextAlignmentCenter];
    [self setTemperture:0];
    _temperatureLB.center = self.center;
    
    _unconnectedBgImage = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"unconnected-温度") onView:self];
    _unconnectedBgImage.hidden = YES;
}

- (void)setTemperture:(CGFloat )tem {
    NSString *string = [NSString stringWithFormat:@"%0.0f",tem];
    if ([UIDevice currentDevice].systemVersion.boolValue >= 10.0) {
        _temperatureLB.attributedText = [self configureFontsAndColorsWithStr:string unitStr:@"℃"];
    }else{
        _temperatureLB.text = [NSString stringWithFormat:@"%@℃",string];
        _temperatureLB.textColor = kWhiteColor;
    }
}

- (NSMutableAttributedString *)configureFontsAndColorsWithStr:(NSString *)str unitStr:(NSString *)unitStr{
    NSString *deatilStr = [NSString stringWithFormat:@"%@ %@",str,unitStr];
    NSMutableAttributedString *todayMileageStr = [[NSMutableAttributedString alloc] initWithString:deatilStr];
    NSRange rangeNum = NSMakeRange(0, str.length);
    NSRange rangeUnit = NSMakeRange(str.length, unitStr.length + 1);
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:COLOR_HEXSTRING(@"#FFFFFF") range:rangeNum];
    [todayMileageStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Light" size:35 * _MAIN_RATIO_375] range:rangeNum];
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:COLOR_HEXSTRING(@"#FFFFFF") range:rangeUnit];
    [todayMileageStr addAttribute:NSFontAttributeName value:FONT_DEFAULT_Light(20) range:rangeUnit];
    return todayMileageStr;
}

- (void)setBLEConnectStatus:(BOOL)connect{
    _unconnectedBgImage.hidden = connect;
    _bgTemperatureImageView.hidden = !connect;
}
@end
