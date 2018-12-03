//
//  CLButton.m
//  Buggy
//
//  Created by goat on 2017/11/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CLButton.h"
//#define extraWidth 20   //额外向外扩展的距离
@implementation CLButton

//增加按钮额外点击区域
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    point = CGPointMake(point.x + self.frame.origin.x, point.y + self.frame.origin.y);
    
    CGRect rect = CGRectMake(self.frame.origin.x - self.extraWidth, self.frame.origin.y - self.extraWidth, self.bounds.size.width + self.extraWidth *2, self.bounds.size.height + self.extraWidth *2);
    
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
