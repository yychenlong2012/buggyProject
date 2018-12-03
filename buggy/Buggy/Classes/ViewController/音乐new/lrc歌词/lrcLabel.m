//
//  lrcLabel.m
//  Buggy
//
//  Created by goat on 2018/6/13.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "lrcLabel.h"

@implementation lrcLabel
- (void)setProgress:(CGFloat)progress{
    _progress = progress;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 1.获取需要画的区域
    CGRect fillRect = CGRectMake(0, 0, self.width * self.progress, self.height);

    // 2.设置颜色
    [[UIColor redColor] set];

    // 3.添加区域
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}


@end
