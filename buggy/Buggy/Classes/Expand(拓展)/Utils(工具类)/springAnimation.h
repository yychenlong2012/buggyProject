//
//  springAnimation.h
//  Buggy
//
//  Created by goat on 2018/12/24.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^CallBackBlockValue)(CGFloat value);
typedef void(^CallBackBlockPoint)(CGPoint point);
@interface springAnimation : NSObject
//单个值的震荡
-(void)animationWithFormValue:(CGFloat)formValue
                      toValue:(CGFloat)toValue
                      damping:(CGFloat)damping
                     velocity:(CGFloat)velocity
                     duration:(CGFloat)duration
                     callback:(CallBackBlockValue)callback;

//点的震荡
-(void)animationWithFormPoint:(CGPoint)formPoint
                      toPoint:(CGPoint)toPoint
                      damping:(CGFloat)damping
                     velocity:(CGFloat)velocity
                     duration:(CGFloat)duration
                     callback:(CallBackBlockPoint)callback;
@end

NS_ASSUME_NONNULL_END
