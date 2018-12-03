//
//  CustomCircleView.h
//  贝塞尔曲线02
//
//  Created by 张延深 on 16/1/12.
//  Copyright © 2016年 宜信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCircleView : UIView

@property (nonatomic, assign) CGFloat rate; // 中间显示的数字
@property (nonatomic, strong) UILabel *rateLbl;
@property (nonatomic, strong) NSString *unit;

- (void)startAnimation; // 开始动画

@end
