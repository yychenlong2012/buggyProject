//
//  WatermarkView.m
//  Buggy
//
//  Created by 孟德林 on 2017/7/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "WatermarkView.h"

@implementation WatermarkView{
    
    UIView *_markView;
    UIView *_controlView;
    NSArray *_titleArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _titleArray = @[NSLocalizedString(@"赞赞赞", nil),NSLocalizedString(@"好可耐", nil),NSLocalizedString(@"妈妈棒", nil),NSLocalizedString(@"自定义", nil)];
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.backgroundColor = COLOR_HEXSTRING(@"#312525");
    
    UIView *markView = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, 43 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#1F1F1F") onView:self];
    _markView = markView;
    
    UIView *controlView = [Factory viewWithFrame:CGRectMake(0, markView.height, ScreenWidth, 45 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#312525") onView:self];
    _controlView = controlView;
    
    CGFloat width = (ScreenWidth - 60 * _MAIN_RATIO_375) / 4;
    for (NSInteger i = 0; i < 4; i ++) {
        UIButton *dot = [Factory buttonEmptyWithFrame:CGRectMake(30 * _MAIN_RATIO_375 + i * width, 0 , width , 16 * _MAIN_RATIO_375) click:nil onView:_markView];
        dot.centerY = _markView.height / 2;
        dot.backgroundColor = [UIColor clearColor];
        dot.tag = i;
        [dot setTitleColor:i == 3 ? COLOR_HEXSTRING(@"#f47686") : [UIColor whiteColor] forState:UIControlStateNormal];
        [dot addTarget:self action:@selector(selectMark:) forControlEvents:UIControlEventTouchUpInside];
        dot.titleLabel.textAlignment = NSTextAlignmentCenter;
        dot.titleLabel.font = FONT_DEFAULT_Light(14);
        [dot setTitle:_titleArray[i] forState:UIControlStateNormal];
    }
    
    for (NSInteger i = 0; i < 2; i ++) {
        UIButton *button = [Factory buttonWithCenter:CGPointMake((i == 0 ? 125 * _MAIN_RATIO_375 : ScreenWidth - 125 * _MAIN_RATIO_375), _controlView.height/ 2) withImage:i == 0 ? ImageNamed(@"icon-宝宝信息-未按下") :ImageNamed(@"icon-标签-按下") click:^{} onView:_controlView];
        [button addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        button.selected = NO;
        [_controlView addSubview:button];
    }
}

- (void)selectMark:(UIButton *)sender{
    
    if (self.waterblockBack) {
        self.waterblockBack(sender.tag);
    }
}

- (void)selectMode:(UIButton *)sender{
    UIButton *button = sender;
    [button setImage:button.tag == 0 ? ImageNamed(@"icon-宝宝信息-按下") :ImageNamed(@"icon-标签-按下") forState:UIControlStateNormal];
    if (button.tag == 1) {
        if (button.selected) {
            _markView.hidden = NO;
            [button setImage:ImageNamed(@"icon-标签-按下") forState:UIControlStateNormal];
        }else{
            _markView.hidden = YES;
            [button setImage:ImageNamed(@"icon-标签-未按下") forState:UIControlStateNormal];
        }
        button.selected = !button.selected;
    }
    
    if (button.tag == 0) {  //宝宝信息
        self.babyInfoBlock(button.selected);
        if (button.selected) {
            [button setImage:ImageNamed(@"icon-宝宝信息-按下") forState:UIControlStateNormal];
        }else{
            [button setImage:ImageNamed(@"icon-宝宝信息-未按下") forState:UIControlStateNormal];
        }
        button.selected = !button.selected;
    }
}
@end
