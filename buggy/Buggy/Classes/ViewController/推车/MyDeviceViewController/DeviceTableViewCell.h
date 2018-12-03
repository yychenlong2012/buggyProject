//
//  DeviceTableViewCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DeviceTableViewCellHeight 51
typedef void(^BandingDevice)(void);
typedef void(^ComeDeviceInfo)(void);

@interface DeviceTableViewCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *peripheral;
@property (nonatomic ,copy) BandingDevice bandDevice;
@property (nonatomic ,copy) ComeDeviceInfo comeDevice;

- (void)setOrder:(NSInteger)index isBandingDevice:(BOOL)isBanding;
- (void)setSelectbgColor;
- (void)setUnSelectbgColor;

-(void)band;    //新方法
- (void)banding;  //旧方法
- (NSString *)getTitle;
@end
