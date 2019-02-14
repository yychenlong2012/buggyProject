//
//  CarA3SetTableViewCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/31.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CarA3SetTableViewCellHeight 340 * _MAIN_RATIO_375

typedef void(^BackLightSetBlock)(int value);
typedef void(^CloseDeviceBlock)(void);
typedef void(^SwitchActionBlock)(BOOL on );
typedef void(^CancleDeviceBrakeAction)(UISwitch *switchBtn);

@interface CarA3SetTableViewCell : UITableViewCell

@property (nonatomic ,copy) BackLightSetBlock backLightBlock;
@property (nonatomic ,copy) CloseDeviceBlock closeDeviceBlock;
@property (nonatomic ,copy) SwitchActionBlock switchActionBlock;
@property (nonatomic ,copy) CancleDeviceBrakeAction cancleDeviceBrakeActionBlock; //智能刹车

@property (nonatomic,strong) UISwitch *switchBtn;     //一键防盗按钮
@property (nonatomic,strong) UISwitch *autoBrakeBtn;   //智能刹车开关

- (void)setBackLightProgress:(float)value;

//- (void)setSwitchStatus:(BOOL)status;

/**
 根据蓝牙是否连接设置图片状态
 @param connect 刹车状态
 */
- (void)setBLEConnectStatus:(BOOL)connect;
//打开或者关闭
- (void)closeOrOpenLight:(BOOL)flag;
//设置控件是否能够点击
- (void)close;
//设置控件是否能够点击
- (void)open;

- (void)isON:(BOOL)flag;
@end
