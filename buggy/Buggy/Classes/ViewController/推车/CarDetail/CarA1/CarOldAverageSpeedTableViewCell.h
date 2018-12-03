//
//  CarOldAverageSpeedTableViewCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CarOldAverageSpeedTableViewCellHeight 150 * _MAIN_RATIO_375

@interface CarOldAverageSpeedTableViewCell : UITableViewCell

- (void)setVerageSpeed:(NSString *)speed;

- (void)setBLEConnectStatus:(BOOL)connect;

@end
