//
//  CarOldAverageSpeedTableViewCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarOldAverageSpeedTableViewCell.h"

@implementation CarOldAverageSpeedTableViewCell{
    
    UIImageView *_bgImageView;
    UIImageView *_whoolImageView;
    UILabel *_verageSpeedLB;
    UILabel *_unitSpeedLB;
    UIImageView *_unconnectedBgImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _bgImageView = [Factory imageViewWithFrame:CGRectMake(0, 0, 330 * _MAIN_RATIO_375, 108 * _MAIN_RATIO_375) image:ImageNamed(@"时速背景") onView:self.contentView];
    
    _verageSpeedLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/ 3, 40 * _MAIN_RATIO_375) font:nil text:nil textColor:nil onView:_bgImageView textAlignment:NSTextAlignmentLeft];
    
    if ([UIDevice currentDevice].systemVersion.boolValue >= 10.0) {
        _verageSpeedLB.attributedText = [self configureFontsAndColorsWithStr:@"0" unitStr:@"km/h"];
    }else{
        _verageSpeedLB.text = @"0km/h";
        _verageSpeedLB.textColor = kWhiteColor;
    }
    
    _whoolImageView = [Factory imageViewWithCenter:CGPointMake(0, 0) image:ImageNamed(@"pic_时速") onView:_bgImageView];
    
    _unconnectedBgImage = [Factory imageViewWithFrame:CGRectZero image:ImageNamed(@"unconnected-平均时速") onView:self];
    _unconnectedBgImage.hidden = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat centerY = _bgImageView.height/2 - 10 * _MAIN_RATIO_375;
    
    _bgImageView.centerX = ScreenWidth / 2;
    _bgImageView.top = 30 * _MAIN_RATIO_375;
    
    _unconnectedBgImage.frame = _bgImageView.frame;
    
    _verageSpeedLB.left = 40 * _MAIN_RATIO_375;
    _verageSpeedLB.centerY = centerY;
    
    _whoolImageView.centerY = centerY;
    _whoolImageView.right = _bgImageView.width - 30 * _MAIN_RATIO_375;
}

- (void)setVerageSpeed:(NSString *)speed {
    if (speed == nil) {
        speed = @" ";
    }
    NSString *string = [NSString stringWithFormat:@"%@",speed];
    
    if ([UIDevice currentDevice].systemVersion.boolValue >= 10.0) {
        _verageSpeedLB.attributedText = [self configureFontsAndColorsWithStr:string == nil ? @"0" : string unitStr:@"km/h"];
    }else{
        _verageSpeedLB.text = [NSString stringWithFormat:@"%@km/h",string == nil ? @"0" : string];
        _verageSpeedLB.textColor = kWhiteColor;
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
    _bgImageView.hidden = !connect;
}

@end
