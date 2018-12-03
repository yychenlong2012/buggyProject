//
//  RepairView.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "RepairView.h"
#import "UIButton+Indicator.h"

@implementation RepairView{
    
    UIButton *_repairBT;
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
    UIView *bgView = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, 353 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#F47686") onView:self];
    [Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, 207 * _MAIN_RATIO_375) image:ImageNamed(@"Repair_Image") onView:self];
    
    __block UIButton *button = [Factory buttonWithFrame:CGRectMake(0, 0, 215 * _MAIN_RATIO_375, 50 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#ED6A79") title:NSLocalizedString(@"一键修复", nil) textColor:COLOR_HEXSTRING(@"#FFFFFF") click:^{
        [button showIndicator];
        self.repairBlock(button);
    } onView:self];
    button.center = CGPointMake(ScreenWidth/2, bgView.bottom + 110 * _MAIN_RATIO_375);
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 4;
    _repairBT = button;
}

- (void)repairFinish{
    [_repairBT hideIndicator];
    _repairBT.backgroundColor = COLOR_HEXSTRING(@"#64C888");
    [_repairBT setTitle:NSLocalizedString(@"修复完成", nil) forState:UIControlStateNormal];
    _repairBT.enabled = NO;
}

@end
