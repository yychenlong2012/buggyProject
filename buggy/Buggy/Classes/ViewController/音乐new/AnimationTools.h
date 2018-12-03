//
//  AnimationTools.h
//  Buggy
//
//  Created by goat on 2018/6/14.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnimationTools : NSObject
//isBack  是否取消动画回弹
+(CABasicAnimation *)baseAnimationWith:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration repeatCount:(float)repeatCount isBack:(BOOL)isBack;

+(CAKeyframeAnimation *)keyframeAnimationWith:(NSString *)keyPath duration:(CFTimeInterval)duration repeatCount:(float)repeatCount values:(NSArray *)values path:(CGPathRef)path;
@end
