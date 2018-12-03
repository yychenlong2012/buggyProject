//
//  BabyInfoMarkView.m
//  Buggy
//
//  Created by 孟德林 on 2017/7/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BabyInfoMarkView.h"

@implementation BabyInfoMarkView{
    UILabel *_babyDayLB;
    UILabel *_babyHeightLB;
    UILabel *_babyWeightLB;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    UIImageView *imageView = [Factory imageViewWithFrame:self.frame image:ImageNamed(@"icon-数据表") onView:self];
    
    _babyDayLB = [Factory labelWithFrame:CGRectMake(0, 0, BabyInfoMarkViewWeight, 35 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(16) text:nil textColor:nil onView:imageView textAlignment:NSTextAlignmentCenter];
    
    CGFloat left = 22 * _MAIN_RATIO_375;
    _babyHeightLB = [Factory labelWithFrame:CGRectMake(left, 0, BabyInfoMarkViewWeight - left, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) text:nil textColor:nil onView:imageView textAlignment:NSTextAlignmentLeft];
    
    _babyWeightLB  = [Factory labelWithFrame:CGRectMake(left, 0, BabyInfoMarkViewWeight - left, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) text:nil textColor:nil onView:imageView textAlignment:NSTextAlignmentLeft];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _babyDayLB.top = 16 * _MAIN_RATIO_375;
    _babyHeightLB.top = _babyDayLB.bottom;
    _babyWeightLB.top = _babyHeightLB.bottom + 10;
}

- (void)setbabyDay:(NSString *)day height:(NSString *)height weight:(NSString *)weight{
    _babyHeightLB.attributedText = [self configureFontsAndColorsWithStr:[NSString stringWithFormat:@"%@:",NSLocalizedString(@"身高", nil)] unitStr:[NSString stringWithFormat:@"%@",height]];
    _babyWeightLB.attributedText = [self configureFontsAndColorsWithStr:[NSString stringWithFormat:@"%@:",NSLocalizedString(@"体重", nil)] unitStr:[NSString stringWithFormat:@"%@",weight]];
    _babyDayLB.attributedText = [self configureColorsWithDay:day];
    
}

- (NSMutableAttributedString *)configureColorsWithDay:(NSString *)day {
    
    NSString *deatilStr = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"宝宝", nil),(day == nil ? @"0" : day),NSLocalizedString(@"天啦", nil)];
    NSMutableAttributedString *todayMileageStr = [[NSMutableAttributedString alloc] initWithString:deatilStr];
    
    NSRange rangeUnit;
    if ([deatilStr containsString:@"baby"]) {
        rangeUnit = NSMakeRange(4, day.length);
    }else{
        rangeUnit = NSMakeRange(2, day.length);
    }

    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:[Theme mainNavColor] range:rangeUnit];
    return todayMileageStr;
}


- (NSMutableAttributedString *)configureFontsAndColorsWithStr:(NSString *)str unitStr:(NSString *)unitStr{
    NSString *deatilStr = [NSString stringWithFormat:@"%@  %@",str,unitStr];
    NSMutableAttributedString *todayMileageStr = [[NSMutableAttributedString alloc] initWithString:deatilStr];
    NSRange rangeNum = NSMakeRange(0, str.length);
    NSRange rangeUnit = NSMakeRange(str.length, unitStr.length + 2);
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:COLOR_HEXSTRING(@"#666666") range:rangeNum];
    [todayMileageStr addAttribute:NSFontAttributeName value:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) range:rangeNum];
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:[Theme mainNavColor] range:rangeUnit];
    [todayMileageStr addAttribute:NSFontAttributeName value:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) range:rangeUnit];
    return todayMileageStr;
}

@end
