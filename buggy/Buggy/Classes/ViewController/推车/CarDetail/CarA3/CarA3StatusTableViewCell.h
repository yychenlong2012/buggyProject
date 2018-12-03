//
//  CarA3TableViewCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CarA3StatusTableViewCellHeight 165 * _MAIN_RATIO_375

@interface CarA3StatusTableViewCell : UITableViewCell

/**
 刹车状态

 @param braking 刹车状态
 */
- (void)setBrakeStatus:(BOOL )braking;


/**
 设置电池状态

 @param battery 电池状态
 */
- (void)setBattery:(NSString *)battery;

/**
 根据蓝牙是否连接设置图片状态
 
 @param connect 刹车状态
 */
- (void)setBLEConnectStatus:(BOOL)connect;

/**
 是否取消刹车状态

 @param connect 取消 ： 状态置灰  不取消 ： 状态正常
 */
- (void)cancleBrakeStatus:(BOOL)connect;
/**
 设置关机图片
 */
- (void)setCloseStatus:(BOOL)connect;


/**
 是否将刹车状态置为黑白
 
 @param connect 取消 ： 状态置灰  不取消 ： 状态正常
 */
- (void)BrakeStatus:(BOOL)connect;

//智能刹车是否开启
-(void)isSmartBrakeOpen:(BOOL)isOpen;
@end
