//
//  WChart.m
//  WChartView
//
//  Created by wangsen on 15/12/24.
//  Copyright © 2015年 wangsen. All rights reserved.
//

#import "SNChart.h"
#import "SNChartLine.h"
#import "SNChartBar.h"
@interface SNChart ()<ChartLineDelegate,chartBarDelegate>
@property (nonatomic, strong) UIScrollView * myScrollView;
@property (nonatomic, strong) SNChartLine * chartLine;
@property (nonatomic, strong) SNChartBar * chartBar;

@end
@implementation SNChart

- (instancetype)initWithFrame:(CGRect)frame withDataSource:(id<SNChartDataSource>)dataSource andChatStyle:(SNChartStyle)chartStyle {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = dataSource;
        self.chartStyle = chartStyle;
        self.curve = NO;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.dataSource = _dataSource;
    self.chartStyle = _chartStyle;
    self.curve = NO;
}

- (void)startDraw {
    
    if (_chartStyle == SNChartStyleLine) {
        [self.chartLine removeFromSuperview];
        self.myScrollView.frame = self.bounds;
        self.chartLine = [[SNChartLine alloc] initWithFrame:self.bounds];
        self.chartLine.delegate = self;
        [self.myScrollView addSubview:self.chartLine];
        
        NSMutableArray * yArray = [NSMutableArray arrayWithArray:[self.dataSource chatConfigYValue:self]];
        NSArray * xArray = [self.dataSource chatConfigXValue:self];
        NSInteger count = xArray.count - yArray.count;
        if (count > 0) {
            
            for (NSInteger i = 0; i < count; i++) {
                [yArray addObject:@(0).stringValue];

            }
        }
        
        NSArray * sourtArray = [yArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            return [obj2 floatValue] > [obj1 floatValue];
        }];
        
        self.chartLine.yMax = [sourtArray.firstObject floatValue];
        self.chartLine.curve = self.curve;
        [self.chartLine setXValues:xArray];
        [self.chartLine setYValues:yArray];
        
        [self.chartLine startDrawLines];
        
        self.myScrollView.contentSize = CGSizeMake(chartLineTheXAxisSpan * xArray.count + chartLineStartX, 0);
        CGRect frame = self.chartLine.frame;
        frame.size.width = chartLineStartX + xArray.count * chartLineTheXAxisSpan;
        self.chartLine.frame = frame;
        
    } else {
        [self.chartBar removeFromSuperview];
        self.myScrollView.frame = self.bounds;
        self.chartBar = [[SNChartBar alloc] initWithFrame:self.bounds];
        [self.myScrollView addSubview:self.chartBar];
        self.chartBar.delegate = self;
        
        NSMutableArray * yArray = [NSMutableArray arrayWithArray:[self.dataSource chatConfigYValue:self]];
        NSArray * xArray = [self.dataSource chatConfigXValue:self];
        NSInteger count = xArray.count - yArray.count;
        if (count > 0) {
            
            for (NSInteger i = 0; i < count; i++) {
                [yArray addObject:@(0).stringValue];
                
            }
        }
        
        NSArray * sourtArray = [yArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            return [obj2 floatValue] > [obj1 floatValue];
        }];
        
        self.chartBar.yMax = [sourtArray.firstObject floatValue];
        [self.chartBar setXValues:xArray];
        [self.chartBar setYValues:yArray];
        
        [self.chartBar startDrawBars];
        
        self.myScrollView.contentSize = CGSizeMake(chartBarTheXAxisSpan * (xArray.count +1) + chartBarStartX, 0);
        CGRect frame = self.chartBar.frame;
        frame.size.width = chartBarStartX + xArray.count * chartBarTheXAxisSpan;
        self.chartBar.frame = frame;

    }
    CGFloat x = self.myScrollView.contentSize.width - self.myScrollView.frame.size.width;
    x = x > 0? x:0;
    [self.myScrollView setContentOffset:CGPointMake(x , 0)];
}

- (void)showInView:(UIView *)view {
    [self startDraw];
    if (view) {
        [view addSubview:self];
    }
}

- (void)doubleClickItem:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(mutiClickItem:chart:)]) {
        [self.delegate mutiClickItem:index chart:self];
    }
}

- (UIScrollView *)myScrollView {
    if (!_myScrollView) {
        _myScrollView = [[UIScrollView alloc] init];
        [self addSubview:_myScrollView];
    }
    return _myScrollView;
}
@end
