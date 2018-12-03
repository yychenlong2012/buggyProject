//
//  MBProgressHUD+DLTips.h
//  Buggy
//
//  Created by 孟德林 on 2016/11/2.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "MONActivityIndicatorView.h"
@interface MBProgressHUD (DLTips)<MONActivityIndicatorViewDelegate>
#pragma mark -------- 自定义位置的展示
/**
 *  展示提示信息(在中间)
 *
 *  @param string 提示的信息
 */
+ (void)showToast:(NSString *)string;

/**
 *  展示提示信息（在底部）
 *
 *  @param string 提示的信息
 */
+ (void)showToastDown:(NSString *)string;

/**
 *  展示提示信息（在顶部）
 *
 *  @param string 提示的信息
 */
+ (void)showToastUp:(NSString *)string;

#pragma mark -------- 展示在keyWindow(提倡使用)

/**
 展示错误信息 + 错误的icon + 1s自动消失
 
 @param error
 */
+ (void)showError:(NSString *)error;


/**
 展示成功信息 + 成功的icon + 1s自动消失
 
 @param success
 */
+ (void)showSuccess:(NSString *)success;


/**
 展示自定义提示 + 对应的icon + 1s 自动消失
 
 @param icon
 @param finish
 */
+ (void)showCostomIcon:(NSString *)icon finish:(NSString *)finish;



/**
 展示提示 + 延迟
 
 @param message      提示信息
 @param timeInterval 延迟时间
 */
+ (void)showMessage:(NSString *)message delay:(NSTimeInterval)timeInterval;

#pragma mark --- 动画
/**
 正在登陆Loading + 下部提示语
 
 @param message 消息
 
 @return 提示的视图
 */
+ (MBProgressHUD *)showLoadingWithMessag:(NSString *)message;


/**
       菊花loading
 */
+ (void)showLoadingNormal;


/**
 玩命加载中
 */
+ (void)showLoadingTransporter;


/**
       菊花消失
 */
+ (void)dismissLoading;

#pragma mark -------- 直接展示在当前视图上(慎重使用)
/**
 错误的提示，带图标
 
 @param error 错误的text
 @param view  view必须存在
 */

+ (void)showError:(NSString *)error toView:(UIView *)view;


/**
 成功的提示
 
 @param success 成功text
 @param view    view必须存在
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

/**
 延迟 正常的提示
 
 @param message      提示的消息
 @param view         view 必须存在
 @param timeInterval 延迟的时间（s）
 */
+ (void)showMessage:(NSString *)message toView:(UIView *)view delay:(NSTimeInterval)timeInterval;


/**
 正在Loading + 下部提示语
 
 @param message 信息
 @param view    view必须存在
 
 @return
 */
+ (MBProgressHUD *)showLoadingWithMessag:(NSString *)message toView:(UIView *)view;


/**
 错误提示（不带旋转动画）(文字 + 图片)
 
 @param error 错误的信息
 */
- (void)autodismissShowError:(NSString *)error;


/**
 成功的提示（不带旋转动画）（文字 + 图片）
 
 @param success 提示的信息
 */
- (void)autodismissShowSuccess:(NSString *)success;


/**
 菊花在当前视图旋转

 @param view 当前视图
 */
+ (void)showLoadingNormaltoView:(UIView *)view;


/**
 玩命加载中动画

 @param view 当前视图
 */
+ (void)showLoadingTransporterView:(UIView *)view;

/**
 菊花从当前视图消失

 @param view 当前视图
 */
+ (void)dismissLoadingView:(UIView *)view;

@end
