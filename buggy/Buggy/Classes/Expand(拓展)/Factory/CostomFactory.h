//
//  CostomFactory.h
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BOTTOM_SIDE 70

#define FactoryRectButtonDefault(y) CGRectMake((ScreenWidth - (324*_MAIN_RATIO_375))/2, y, (324*_MAIN_RATIO_375), 45*_MAIN_RATIO_375)

@interface CostomFactory : NSObject

/**
 *  获取登录按钮（统一样式）弧形边角
 *
 *  @param click 点击退出
 *  @param view
 *
 *  @return 
 */
+ (UIButton *)userLoginOutClick:(void(^)(void))click OnView:(UIView *)view;

/**
 *  正常的OK按钮（统一样式）弧形边角
 *
 *  @param frame
 *  @param title
 *  @param view
 *  @param action
 *
 *  @return
 */
+(UIButton *)normalButtonWithFrame:(CGRect)frame title:(NSString *)title
                            inView:(UIView *)view action:(void (^)(void))action;

/**
 *  带有高亮状态的按钮   
 *
 *  @param frame     尺寸
 *  @param title     标题
 *  @param normal    正常的颜色
 *  @param highlight 高亮的颜色
 *  @param disabled  残疾的颜色
 *  @param view      view
 *  @param action    action
 *
 *  @return
 */
+(UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title normalColor:(UIColor *)normal
              highlightColor:(UIColor *)highlight disabledColor:(UIColor *)disabled
                      inView:(UIView *)view action:(void (^)(void))action;



@end
