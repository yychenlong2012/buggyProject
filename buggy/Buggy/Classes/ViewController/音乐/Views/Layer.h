//
//  Layer.h
//  SuperWebViewTest
//
//  Created by 孟德林 on 2016/12/7.
//  Copyright © 2016年 DeLin.Meng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface Layer : CALayer

@property (nonatomic ,assign) CGFloat radius;

@property (nonatomic ,assign) NSTimeInterval animationDuration; //动画持续时间

@property (nonatomic ,assign) NSTimeInterval pulseInterval;     //电磁波持续时间

@property (nonatomic ,strong) CAAnimationGroup *animationGroup; //动画集合

@end
