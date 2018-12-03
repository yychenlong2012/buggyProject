//
//  AnimationTools.m
//  Buggy
//
//  Created by goat on 2018/6/14.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "AnimationTools.h"

@implementation AnimationTools
/*
 keyPath取值
 transform.scale = 比例轉換 transform.scale.x transform.scale.y
 transform.rotation.z = 平面圖的旋轉
 opacity = 透明度
 margin
 zPosition
 backgroundColor 背景颜色
 cornerRadius 圆角
 borderWidth
 bounds
 contents
 contentsRect
 cornerRadius
 frame
 hidden
 mask
 masksToBounds
 opacity
 position
 shadowColor
 shadowOffset
 shadowOpacity
 shadowRadius
 */
//isBack  是否取消动画回弹
+(CABasicAnimation *)baseAnimationWith:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration repeatCount:(float)repeatCount isBack:(BOOL)isBack{
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    if (isBack == NO) {
        animation.removedOnCompletion = NO;          //动画完成时不移除动画
        animation.fillMode = kCAFillModeForwards;    //动画完成时保持最新位置
    }
    return animation;
}

//path路径可以自己创建
//@[@(angle1(-5)), @(angle1(5)), @(angle1(-5))]
//@[(__bridge id)[UIColor redColor].CGColor]
+(CAKeyframeAnimation *)keyframeAnimationWith:(NSString *)keyPath duration:(CFTimeInterval)duration repeatCount:(float)repeatCount values:(NSArray *)values path:(CGPathRef)path{
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = keyPath;
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    animation.values = values;
    if (path) {
        animation.path = path;
    }
    return animation;
}

@end
