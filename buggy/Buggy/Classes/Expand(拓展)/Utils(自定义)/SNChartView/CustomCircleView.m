//
//  CustomCircleView.m
//  贝塞尔曲线02
//
//  Created by 张延深 on 16/1/12.
//  Copyright © 2016年 宜信. All rights reserved.
//

#import "CustomCircleView.h"

#define LineWidth 16

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface CustomCircleView ()
{
    CGFloat _startAngle; // 开始的角度
    NSInteger _startRate;
}
@property (nonatomic, assign) CGFloat vWidth;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIBezierPath *bPath;

@end

@implementation CustomCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _startAngle = -90; // 从圆的最顶部开始
        _startRate = 0;
        _vWidth = frame.size.width;
        _bPath = [UIBezierPath bezierPath];
        // label
        [self configLbl];
        // 先画一个底部的圆
        [self configBgCircle];
        // 配置CAShapeLayer
        [self configShapeLayer];
        // 配置CADisplayLink
        [self configDisplayLink];
    }
    return self;
}

#pragma mark - event response

- (void)drawCircle {
    if (_startRate >= _rate * 4 || _startRate >= 100) {    //控制范围   取rate * 4 和 100 两个数之间的最小值作为startRate的上限
        _bPath = [UIBezierPath bezierPath];
        _bPath.lineCapStyle = kCGLineCapRound;
        _displayLink.paused = YES;
        _rateLbl.text = [NSString stringWithFormat:@"%.1lf %@", _rate,self.unit];
        return;
    }
    _startRate ++;
    NSInteger total = _rate*4 >= 100 ? 100 : _rate*4;
    NSInteger a = _rate*_startRate/total;
    _rateLbl.text = [NSString stringWithFormat:@"%1ld %@",(long)a,self.unit];
    [_bPath addArcWithCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_vWidth * 0.45 startAngle:(M_PI / 180.0) * _startAngle - DEGREES_TO_RADIANS(135) endAngle:(M_PI / 180.0) * (_startAngle + 3.6) - DEGREES_TO_RADIANS(135) clockwise:YES];
    _shapeLayer.path = _bPath.CGPath;
//    _shapeLayer.lineCap      = kCALineCapRound;
    _startAngle += 2.7;
}

#pragma mark - public methods

- (void)startAnimation {
    if (_displayLink.paused == YES) {
        _startAngle = -90;
        _startRate = 0;
        _displayLink.paused = NO;
    }
}

#pragma mark - private methods

#pragma mark 中间显示数字的Label
- (void)configLbl {
    CGFloat rateLblX = 10;
    CGFloat rateLblW = self.frame.size.width - 2 * rateLblX;
    CGFloat rateLblH = 40;
    CGFloat rateLblY = (self.frame.size.height - rateLblH) * 0.5 - 30;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(rateLblX, rateLblY, rateLblW, rateLblH)];
    lbl.font = [UIFont systemFontOfSize:22];
    lbl.textColor = [UIColor whiteColor];
    _rateLbl = lbl;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"---";
    [self addSubview:lbl];
}

#pragma mark 底下灰色的圆
- (void)configBgCircle {
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_vWidth * 0.45 startAngle:DEGREES_TO_RADIANS(135) endAngle:DEGREES_TO_RADIANS(45) clockwise:YES];
    bPath.lineCapStyle = kCGLineCapRound;
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
//    shaperLayer.lineCap      = kCALineCapRound;
    shaperLayer.fillColor = [UIColor clearColor].CGColor;
    shaperLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    shaperLayer.lineWidth = LineWidth;
    shaperLayer.path = bPath.CGPath;
    [self.layer addSublayer:shaperLayer];
    [self configBoundgCircle];
}

- (void)configBoundgCircle {
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_vWidth * 0.55 startAngle:DEGREES_TO_RADIANS(135) endAngle:DEGREES_TO_RADIANS(45) clockwise:YES];
    bPath.lineCapStyle = kCGLineCapRound;
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    //    shaperLayer.lineCap      = kCALineCapRound;
    shaperLayer.fillColor = [UIColor clearColor].CGColor;
    shaperLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    shaperLayer.lineWidth = 2;
    shaperLayer.path = bPath.CGPath;
    [self.layer addSublayer:shaperLayer];
}

#pragma mark 配置CAShaperLayer
- (void)configShapeLayer {
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = LineWidth;
    [self.layer addSublayer:_shapeLayer];
}

#pragma mark 配置CADisplayLink
- (void)configDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawCircle)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES; // 默认暂停
}

#pragma mark - getter/setter
- (void)setRate:(CGFloat)rate {
    
    if (rate <= 0 || rate > 100) {
        rate = 100;
    } else {
        _rate = rate;
    }
}

@end
