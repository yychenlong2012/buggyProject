//
//  CLView.m
//  Buggy
//
//  Created by goat on 2018/6/20.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "CLView.h"
#define extraWidth 20
@implementation CLView

//增加按钮额外点击区域
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    point = CGPointMake(point.x + self.frame.origin.x, point.y + self.frame.origin.y);
    CGRect rect = CGRectMake(self.frame.origin.x - extraWidth, self.frame.origin.y - extraWidth, self.bounds.size.width + extraWidth *2, self.bounds.size.height + extraWidth *2);
    //圆形区域在按钮外部
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    return [path containsPoint:point];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
