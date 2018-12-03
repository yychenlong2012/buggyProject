//
//  CarA3EnergyView.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/1.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarA3EnergyView : UIView

/**
 根绝不同的电量设置不同的渐变颜色和背景图片

 @param percent 电量进度
 */
- (void)setEnergyImageAndEnergyColor:(NSInteger )percent;

/**
 根据蓝牙是否连接设置图片状态
 
 @param connect 刹车状态
 */
- (void)setBLEConnectStatus:(BOOL)connect;

@end
