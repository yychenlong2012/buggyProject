//
//  WaveView.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveView : UIView

/**
 初始化静态播放图标

 @param frame
 @return
 */
- (instancetype)initWithStaticAnimationFrame:(CGRect)frame;

/**
 开始静态动画
 */
- (void)startWaveStaticAnimation;

/**
 关闭静态动画
 */
- (void)stopWaveStaticAnimation;


/**
 开始波纹动画
 */
- (void)startWaveAnimation;

/**
 结束波纹动画
 */
- (void)stopWaveAnimation;

@end
