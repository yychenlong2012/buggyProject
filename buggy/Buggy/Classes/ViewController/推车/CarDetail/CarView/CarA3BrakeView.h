//
//  CarA3BrakeView.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/1.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarA3BrakeView : UIView


/**
 开始轮子动画
 */
- (void)beginWheelAnimation;
- (void)beginWheelAnimation2;

/**
 移除轮子动画
 */
- (void)removeWheelAnimation;


/**
 开始刹车片动画
 */
- (void)beginBrakePadAnimation;


/**
 移除刹车片动画
 */
- (void)removeBrakePadAnimation;


/**
 根据蓝牙是否连接设置图片状态

 @param connect 刹车状态
 */
- (void)setBLEConnectStatus:(BOOL)connect;
- (void)setBLEConnectStatus2:(BOOL)connect;

@end
