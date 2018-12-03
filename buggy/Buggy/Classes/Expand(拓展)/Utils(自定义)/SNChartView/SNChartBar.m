//
//  WChartBar.m
//  WChartView
//
//  Created by wangsen on 15/12/24.
//  Copyright © 2015年 wangsen. All rights reserved.
//

#import "SNChartBar.h"
#define kBtnTag 100
#define kBarLineColor [UIColor colorWithRed:1.000f green:1.000f blue:1.000f alpha:0.500f]
#define kCirCleColor [UIColor colorWithRed:1.000f green:1.000f blue:1.000f alpha:0.500f]
#define kHVLineColor [UIColor colorWithRed:0.918f green:0.929f blue:0.949f alpha:1.00f]
#define kBulldesFont [UIFont systemFontOfSize:10]

static const NSInteger kYEqualPaths = 4;//y轴为5等份
static const CGFloat kTopSpace = 22.0f; //距离顶部y值
static const CGFloat kBarWidth = 35.f;  //柱状的宽度

@interface SNChartBar ()
@property (nonatomic, strong) CAShapeLayer * shapeLayer;
@property (nonatomic, strong) NSMutableArray * pointXArray;
@property (nonatomic, strong) NSMutableArray * pointYArray;
@property (nonatomic, strong) NSMutableArray * points;

@end
@implementation SNChartBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (NSMutableArray *)pointYArray {
    if (!_pointYArray) {
        _pointYArray = [NSMutableArray array];
    }
    return _pointYArray;
}

- (NSMutableArray *)points {
    if (!_points) {
        _points = [NSMutableArray array];
    }
    return _points;
}

- (NSMutableArray *)pointXArray {
    if (!_pointXArray) {
        _pointXArray = [NSMutableArray array];
    }
    return _pointXArray;
}

- (void)setYMax:(CGFloat)yMax {
    _yMax = yMax;
}

- (void)setYValues:(NSArray *)yValues {
    _yValues = yValues;
    [self drawHorizontal];
}

- (void)setXValues:(NSArray *)xValues {
    _xValues = xValues;
    [self drawVertical];
}
//画横线
- (void)drawHorizontal {
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    
    NSInteger i = kYEqualPaths;
    [path moveToPoint:CGPointMake(chartBarStartX, chartBarTheYAxisSpan * i + kTopSpace)];
    [path addLineToPoint:CGPointMake(chartBarStartX + (_xValues.count) * 50, chartBarTheYAxisSpan * i + kTopSpace)];
    [path closePath];
    shapeLayer.path = path.CGPath;
    //        shapeLayer.strokeColor = kHVLineColor.CGColor;
//    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = 0.3f;
    [self.layer addSublayer:shapeLayer];
//    for (NSInteger i = 0; i <= kYEqualPaths; i++) {
//        
//        [path moveToPoint:CGPointMake(chartBarStartX, chartBarTheYAxisSpan * i + kTopSpace)];
//        [path addLineToPoint:CGPointMake(chartBarStartX + (_xValues.count) * 50, chartBarTheYAxisSpan * i + kTopSpace)];
//        [path closePath];
//        shapeLayer.path = path.CGPath;
////        shapeLayer.strokeColor = kHVLineColor.CGColor;
//        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
//        shapeLayer.lineWidth = 0.3f;
//        [self.layer addSublayer:shapeLayer];
//    }
    
}
//画竖线
- (void)drawVertical {
    
//    UIBezierPath * path = [UIBezierPath bezierPath];
//    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
//    
//    for (NSInteger i = 0; i < 2; i++) {
//        NSInteger location = 0;
//        if (i == 0) {
//            location = 0;
//        } else {
//            location = _xValues.count;
//        }
//        
//        [path moveToPoint:CGPointMake(chartBarStartX+ chartBarTheXAxisSpan * location,kTopSpace)];
//        [path addLineToPoint:CGPointMake(chartBarStartX + chartBarTheXAxisSpan * location,chartBarTheYAxisSpan * kYEqualPaths + kTopSpace)];
//        [path closePath];
//        shapeLayer.path = path.CGPath;
//        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
//        shapeLayer.lineWidth = 0.3f;
//        [self.layer addSublayer:shapeLayer];
//
//    }

//    for (NSInteger i = 0; i < _xValues.count; i++) {
//        
//        [path moveToPoint:CGPointMake(chartBarStartX+ chartBarTheXAxisSpan*i,kTopSpace)];
//        [path addLineToPoint:CGPointMake(chartBarStartX + chartBarTheXAxisSpan * i,chartBarTheYAxisSpan * kYEqualPaths + kTopSpace)];
//        [path closePath];
//        shapeLayer.path = path.CGPath;
//        shapeLayer.strokeColor = kHVLineColor.CGColor;
//        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
//        shapeLayer.lineWidth = 0.3f;
//        [self.layer addSublayer:shapeLayer];
//    }
}

- (void)startDrawBars {
    //设置x轴
    for (NSInteger i = 0; i < _xValues.count; i++) {
        [self.pointXArray addObject:@(chartBarStartX + chartBarTheXAxisSpan * i)];
    }
    //设置y轴
    for (NSInteger i = 0; i < _xValues.count; i++) {
        [self.pointYArray addObject:@(chartBarTheYAxisSpan * kYEqualPaths - ([_yValues[i] floatValue] == 0 ?0.00001:[_yValues[i] floatValue])/_yMax * chartBarTheYAxisSpan * kYEqualPaths + kTopSpace) ];
    }
    
    for (NSInteger i = 0; i < self.pointXArray.count; i++) {
        CGPoint point = CGPointMake([self.pointXArray[i] floatValue], [self.pointYArray[i] floatValue]);
        //        NSValue * value = [NSValue valueWithBytes:&point objCType:@encode(CGPoint)];
        NSValue * value = [NSValue valueWithCGPoint:point];
        
        [self.points addObject:value];
    }
    //划线
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.lineCap = kCALineCapButt;//线端点样式
//    _shapeLayer.lineJoin = kCALineJoinMiter;//线的连接点样式
    _shapeLayer.lineWidth = kBarWidth;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.strokeEnd = 0.f;
//    _shapeLayer.strokeColor = kBarLineColor.CGColor;
    
    _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:_shapeLayer];
    UIBezierPath * bezierLine = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < self.points.count; i++) {
        CGPoint point = [self.points[i] CGPointValue];
        [bezierLine moveToPoint:CGPointMake(point.x + kBarWidth/2 + 10, kTopSpace + kYEqualPaths * chartBarTheYAxisSpan)];
        [bezierLine addLineToPoint:CGPointMake(point.x + kBarWidth/2 + 10, point.y)];
        [self addBatTitle:CGPointMake(point.x + kBarWidth/2 + 10, point.y) andIndex:i];
        [self addXLabel:point andIndex:i];
    }
    [self addYLabel];
    _shapeLayer.path = bezierLine.CGPath;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.points.count * 0.3f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [_shapeLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    _shapeLayer.strokeEnd = 1.0f;
}

//标记x轴label
- (void)addXLabel:(CGPoint)point andIndex:(NSInteger)index {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, chartBarTheXAxisSpan, 20)];
    label.center = CGPointMake(point.x + kBarWidth/2 + 10, chartBarTheYAxisSpan * kYEqualPaths + kTopSpace + 20);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _xValues[index];
    [self addSubview:label];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, chartBarTheXAxisSpan, self.frame.size.height - 30)];
    button.center = CGPointMake(point.x + kBarWidth/2 + 10, (self.frame.size.height - 30)/2.0);
    button.tag = index;
    [self addSubview:button];
    [button addTarget:self action:@selector(doubleClick:) forControlEvents:UIControlEventTouchDownRepeat];
}


- (void)doubleClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(doubleClickItem:)]) {
        [self.delegate doubleClickItem:btn.tag];
    }
}

//标记y轴label
- (void)addYLabel {
//    for (NSInteger i = 0; i <= kYEqualPaths; i++) {
//        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, chartBarTheYAxisSpan * i + kTopSpace, chartBarStartX - 5, 10)];
//        label.textColor = [UIColor lightGrayColor];
//        label.font = [UIFont systemFontOfSize:10.f];
//        label.textAlignment = NSTextAlignmentRight;
//        [self addSubview:label];
//        if (i == kYEqualPaths) {
//            label.text = @"0";
//        } else {
//            label.text = [NSString stringWithFormat:@"%.2f",_yMax - _yMax/5.f * i];
//        }
//    }
}
//柱状图标题
- (void)addBatTitle:(CGPoint)point andIndex:(NSInteger)index {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kBarWidth, 10)];
    label.center = CGPointMake(point.x, point.y - 10.f);
    label.font = [UIFont systemFontOfSize:10.f];
    label.text = _yValues[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
}


@end
