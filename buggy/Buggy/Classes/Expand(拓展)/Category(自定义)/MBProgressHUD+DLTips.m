//
//  MBProgressHUD+DLTips.m
//  Buggy
//
//  Created by 孟德林 on 2016/11/2.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "MBProgressHUD+DLTips.h"

@implementation MBProgressHUD (DLTips)

#pragma mark ------------------------------ 自定义位置的展示  -------------------------------------------------

+ (void)showToast:(NSString *)string
{
    [self setMBProgressHUDyOffset:0 withString:string];
}

+ (void)showToastDown:(NSString *)string
{
    [self setMBProgressHUDyOffset:ScreenHeight / 4 withString:string];
}
+ (void)showToastUp:(NSString *)string
{
    [self setMBProgressHUDyOffset:-ScreenHeight/4 withString:string];
}
+ (void)setMBProgressHUDyOffset:(CGFloat )yOffset withString:(NSString *)string{
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    hud.tintAdjustmentMode = YES;
    hud.margin = 10.f;
    hud.yOffset = yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

#pragma mark --------------------------------- 视图放在self.view上 -------------------------------------------------

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    //    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    /* 快速显示一个提示信息 */
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    /* 设置图片 */
    hud.customView = [[UIImageView alloc] initWithImage:ImageNamed(icon)];
    /* 设置模式 */
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success" view:view];
}
// 自动消失的提示
- (void)autodismissShowSuccess:(NSString *)success
{
    self.detailsLabelText = success;
    self.detailsLabelFont = [UIFont systemFontOfSize:16];
    // 设置图片
    self.customView = [[UIImageView alloc] initWithImage:ImageNamed(@"success")];
    // 再设置模式
    self.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    self.removeFromSuperViewOnHide = YES;
    [self hide:YES afterDelay:1.0];
}

- (void)autodismissShowError:(NSString *)error
{
    self.detailsLabelText = error;
    self.detailsLabelFont = [UIFont systemFontOfSize:16];
    // 设置图片
    self.customView = [[UIImageView alloc] initWithImage:ImageNamed(@"error")];
    // 再设置模式
    self.mode = MBProgressHUDModeCustomView;
    self.removeFromSuperViewOnHide = YES;
    [self hide:YES afterDelay:1.0];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view
{
    //    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    [hud hide:YES afterDelay:1.0];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view delay:(NSTimeInterval)timeInterval
{
    //    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    hud.detailsLabelText = message;
    
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    // 1秒之后再消失
    [hud hide:YES afterDelay:timeInterval];
}

+ (MBProgressHUD *)showLoadingWithMessag:(NSString *)message toView:(UIView *)view {
    //    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    return hud;
}

+ (void)showLoadingTransporterView:(UIView *)view{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.backgroundColor=[UIColor clearColor];
    hud.color=[UIColor clearColor];
    hud.labelFont=[UIFont boldSystemFontOfSize:14];
    hud.animationType=MBProgressHUDAnimationFade;
    
    MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = view;
    indicatorView.numberOfCircles = 5;
    indicatorView.radius = 12;
    indicatorView.internalSpacing = 8;
    
    [indicatorView startAnimating];
    hud.customView=indicatorView;
    hud.labelColor=[UIColor orangeColor];
    hud.labelText = nil;
    hud.yOffset=-44;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
}

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    NSArray*array=@[@"#38d2ec",@"#0ce2c6",@"#da4ceb",@"#ff811b",@"#b3d465",@"#ea6644"];
    
    return [UIColor colorWithMacHexString:array[index]];
}

- (NSString*)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView circleTextAtIndex:(NSUInteger)index
{
    NSArray*array=@[@"拼",@"命",@"加",@"载",@"中"];
    return array[index];
}

+ (void)showLoadingNormaltoView:(UIView *)view{
   MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
   hud.alpha = 0.6;
   [hud hide:YES afterDelay:10];
}

+ (void)dismissLoadingView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark --------------------------------- 视图放在keyWindow上 -------------------------------------------------

+ (void)show:(NSString *)text icon:(NSString *)icon{
    [MBProgressHUD show:text icon:icon view:[MBProgressHUD keyWindow]];
}

+ (void)showError:(NSString *)error{
    [self show:error icon:@"error" view:[MBProgressHUD keyWindow]];
}

+ (void)showSuccess:(NSString *)success
{
    [self show:success icon:@"success" view:[MBProgressHUD keyWindow]];
}

+ (void)showCostomIcon:(NSString *)icon finish:(NSString *)finish{
    [self show:finish icon:icon];
}

+ (void)showMessage:(NSString *)message
{
    [self showMessage:message toView:[MBProgressHUD keyWindow]];
}

+ (void)showMessage:(NSString *)message delay:(NSTimeInterval)timeInterval
{
    [self showMessage:message toView:[MBProgressHUD keyWindow] delay:timeInterval];
}

+ (MBProgressHUD *)showLoadingWithMessag:(NSString *)message{
    return [self showLoadingWithMessag:message toView:[MBProgressHUD keyWindow]];
}

+ (void)showLoadingNormal{
    [MBProgressHUD showLoadingNormaltoView:[MBProgressHUD keyWindow]];
}

+ (void)showLoadingTransporter{
    [MBProgressHUD showLoadingTransporterView:[MBProgressHUD keyWindow]];
}


+ (void)dismissLoading{
    [MBProgressHUD hideHUDForView:[MBProgressHUD keyWindow] animated:YES];
}

+ (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}


@end
