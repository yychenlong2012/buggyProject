//
//  YFMessage.h
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYView.h"
#import "MBProgressHUD.h"

typedef void(^AlertButtonClickedBlock)(NSInteger buttonIndex);
typedef void(^ViewClick)();
typedef void(^AlertButtonClickedTextBlock)(NSInteger buttonIndex, NSString *text);
/**< 消息提示 */
@interface AYMessage : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hudView;
@property (nonatomic, strong) UIView *noContentTipView;
@property (nonatomic, copy) AlertButtonClickedBlock block;

@property (nonatomic, copy) AlertButtonClickedTextBlock textBolck;
@property (nonatomic, copy) ViewClick                   viewblock;
+ (AYMessage *)shareMessage;

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
+ (void)alert:(NSString *)massage;

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
+ (void)show:(id)message;

/**
 *  提示框
 *
 *  @param message 提示的内容
 *  @param title 标题
 */
+ (void)show:(NSString *)massage title:(NSString *)title;

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
- (void)show:(id)message okTitle:(NSString *)title Clicked:(AlertButtonClickedBlock)block;

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
- (void)show:(id)message tipTitle:(NSString *)tipTitle okTitle:(NSString *)okTitle Clicked:(AlertButtonClickedBlock)block;
- (void)show:(id)message tipTitle:(NSString *)tipTitle oneTitle:(NSString *)okTitle Clicked:(AlertButtonClickedBlock)block;

/**
 *  提示框
 *
 *  @param message 提示的内容
 *  @param title  确定按钮现实的文字
 */
+ (void)show:(id)message okTitle:(NSString *)title Clicked:(AlertButtonClickedBlock)block;

/**
 *  提示框
 *
 *  @param tipTitle 提示的标题
 *  @param message  提示的内容
 *  @param okTitle  确定按钮现实的文字
 */
+ (void)show:(id)message
    tipTitle:(NSString *)tipTitle
     okTitle:(NSString *)okTitle
     Clicked:(AlertButtonClickedBlock)block;

/**
 *  可以自动隐藏的提示
 *
 *  @param message 提示的内容
 *  @param view    提示视图要显示在的视图
 *  @param flag    是否自动隐藏
 */
+ (void)show:(id)message onView:(UIView *)view autoHidden:(BOOL)flag;

/**
 *  创建并显示小菊花
 */
+ (void)showActiveViewOnView:(UIView *)view;
+ (void)showActiveViewWithTipString:(NSString *)tipString
                             onView:(UIView *)view;
/**
 *  小菊花-无超时限制
 */
+ (void)showActiveViewMessage:(NSString *)tipString
                onView:(UIView *)view;
/**
 *  隐藏小菊花
 */
+ (void)hideActiveView;

/**
 *  显示无内容提示
 *
 *  @param message 提示的文字
 *  @param image   显示的图片
 *  @param view    显示所在的视图
 */
+ (UIView *)showNoContentTip:(NSString *)message
                   image:(NSString *)image
                  onView:(UIView *)view
                   viewClick:(ViewClick)viewClick;

- (void)tapsClick:(UIGestureRecognizer *)get;

/**
 *  隐藏无内容提示视图
 */
+ (void)hideNoContentTipView;

/**
 *  显示HUD提示
 *
 *  @param message        提示的文字
 *  @param image          提示的image
 *  @param viewController delegate
 *  @param autoHidden     是否自动隐藏
 */
+ (void)show:(id)message
       image:(UIImage *)image
    delegate:(__kindof UIViewController *)viewController
  autoHidden:(BOOL)autoHidden;

/**
 *  显示带文本框的AlertView
 */
+ (UIAlertView *)showEditViewWithTitle:(NSString *)title
                               message:(NSString *)msg
                         okButtonTitle:(NSString *)okTitle
                         ClickedButton:(AlertButtonClickedTextBlock)block;

@end
