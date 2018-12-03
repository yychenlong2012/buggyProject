//
//  DeviceHeaderView.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DeviceHeaderViewHeight  290 * _MAIN_RATIO_375
@interface DeviceHeaderView : UIView

- (void)addSearchAnimation;

- (void)removeSearchAnimation;

@end


#define DeviceSectionViewHeight 43 * _MAIN_RATIO_375
@interface DeviceSectionView : UIView


@end
