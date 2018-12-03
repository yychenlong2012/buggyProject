//
//  CostomFactory.m
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "CostomFactory.h"
#import "CButton.h"
#define LoginOutBTHeight 50 // 登录按钮的高度
#define BUTTOM_DISTANCES (75 + _MAIN_TABBAR_HEIGHT) // 距离底部的距离
@implementation CostomFactory

+ (UIButton *)userLoginOutClick:(void(^)(void))click OnView:(UIView *)view{
    UIButton *loginOut = [Factory buttonWithFrame:CGRectMake(0, _MAIN_HEIGHT_64 - BUTTOM_DISTANCES, ScreenWidth - 115 * _MAIN_RATIO_375, LoginOutBTHeight) bgColor:[UIColor whiteColor] title:@"退出当前登录" textColor:[[Theme orangeColor] colorWithAlphaComponent:1] click:click onView:view];
    loginOut.centerX = ScreenWidth/2;
    loginOut.layer.masksToBounds = YES;
    loginOut.layer.borderColor = COLOR_HEXSTRING(@"#FC7472").CGColor;
    loginOut.layer.borderWidth = 1;
    loginOut.layer.cornerRadius = 6;
    return loginOut;
}

+(UIButton *)normalButtonWithFrame:(CGRect)frame title:(NSString *)title inView:(UIView *)view action:(void (^)(void))action
{
    CButton *button = [[CButton alloc] initWithFrame:frame title:title normalColor:[Theme mainNavColor] highlightColor:[UIColor colorWithHexString:@"#EEEEEE"] disabledColor:[UIColor colorWithHexString:@"#919191"] action:action];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 6;
    [view addSubview:button];
    return button;
}

+(UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title normalColor:(UIColor *)normal highlightColor:(UIColor *)highlight disabledColor:(UIColor *)disabled inView:(UIView *)view action:(void (^)(void))action{
    
    CButton *button = [[CButton alloc] initWithFrame:frame title:title normalColor:normal highlightColor:highlight disabledColor:disabled action:action];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:button];
    return button;
}

@end
