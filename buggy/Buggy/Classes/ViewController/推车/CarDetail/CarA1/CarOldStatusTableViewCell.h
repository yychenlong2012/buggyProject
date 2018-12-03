//
//  CarOldStatusTableViewCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CarOldStatusTableViewCellHeight 165 * _MAIN_RATIO_375

@interface CarOldStatusTableViewCell : UITableViewCell

- (void)setupEnergy:(NSString *)energy tem:(NSString *)tem;

- (void)setBLEConnectStatus:(BOOL)connect;

@end
