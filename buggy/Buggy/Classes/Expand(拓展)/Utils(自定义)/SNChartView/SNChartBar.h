//
//  WChartBar.h
//  WChartView
//
//  Created by wangsen on 15/12/24.
//  Copyright © 2015年 wangsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chartBarDelegate <NSObject>

- (void)doubleClickItem:(NSInteger)index;

@end

static const CGFloat chartBarStartX = 0.f;
static const CGFloat chartBarTheXAxisSpan = 40.f;
static const CGFloat chartBarTheYAxisSpan = 40.f;

@interface SNChartBar : UIView

@property (nonatomic, weak) id<chartBarDelegate>delegate;    //assign
@property (nonatomic, strong) NSArray * xValues;
@property (nonatomic, strong) NSArray * yValues;

@property (nonatomic, assign) CGFloat yMax;

/**
 *  @author sen, 15-12-24 10:12:59
 *
 *  开始绘制图表
 */
- (void)startDrawBars;

@end
