//
//  CarA1TemperatureView.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarA1TemperatureView : UIView


/**
 设置温度

 @param tem 温度数目
 */

- (void)setTemperture:(CGFloat )tem;

/**
 根据蓝牙是否连接设置图片状态
 
 @param connect 刹车状态
 */
- (void)setBLEConnectStatus:(BOOL)connect;

@end
