//
//  Layer.m
//  SuperWebViewTest
//
//  Created by 孟德林 on 2016/12/7.
//  Copyright © 2016年 DeLin.Meng. All rights reserved.
//

#import "Layer.h"

@implementation Layer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.opacity = 0;
        self.radius = 33;
        self.animationDuration = 1;
        self.pulseInterval = 0;
        
        //设置背景
//        self.backgroundColor = [UIColor colorWithRed:0.00f green:0.478f blue:1.000f alpha:1].CGColor;
        self.backgroundColor = COLOR_HEXSTRING(@"#EA779F").CGColor;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setupAnimationGroup];
            // infinity
            if (self.pulseInterval != INFINITY) {
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addAnimation:self.animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return self;
}

- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    CGPoint temPos = self.position; // 位置
    CGFloat diameter = self.radius * 2; // 直径
    self.bounds = CGRectMake(0, 0, diameter, diameter);
    self.cornerRadius = self.radius;
    self.position = temPos;
}

- (void)setupAnimationGroup{
    
    // 创建组合动画
    CAMediaTimingFunction *defaultCurva = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    self.animationGroup = [CAAnimationGroup animation];
    self.animationGroup.duration = self.animationDuration + self.pulseInterval;
//    self.animationGroup.repeatCount = INFINITY;
    self.animationGroup.removedOnCompletion = YES;
    self.animationGroup.timingFunction = defaultCurva;
    
    // 设置伸缩动画
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    basicAnimation.fromValue = @0.0f;
    basicAnimation.toValue = @1.0f;
    basicAnimation.duration = self.animationDuration;
    
    //创建关键帧动画
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    keyframeAnimation.duration = self.animationDuration;
    keyframeAnimation.values = @[@0.1,@0.2,@0.35,@0.45,@0.2];
    keyframeAnimation.keyTimes =  @[@0,@0.2,@0.5,@0.8,@0.9,@1];
    keyframeAnimation.removedOnCompletion = YES;
    NSArray *animationArr = @[basicAnimation,keyframeAnimation];
    self.animationGroup.animations = animationArr;
}

@end
