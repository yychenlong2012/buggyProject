//
//  WaveView.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "WaveView.h"

@implementation WaveView{
    CAShapeLayer *_waveUpShareLyer;
    CAShapeLayer *_waveDownShareLayer;
    CAShapeLayer *_waveCenterShareLayer;
    CADisplayLink *_displayLink;
    
    CGFloat _offsetX;      // x轴的偏移量
    CGFloat _offsetX_N;    // 第二条x轴波纹
    CGFloat _offsetX_T;    // 第三条x轴波纹
    CGFloat _waveSpeed;    // 移动速率
    CGFloat _waveWidth;    // 波纹的宽度
    CGFloat _waveHeight;   // 波纹的高度
    CGFloat _waveAmplitude;// 振幅
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _waveSpeed = 4;
        _waveWidth = self.frame.size.width;
        _waveHeight = self.frame.size.height/2;
        _waveAmplitude = 11;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithStaticAnimationFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStaticUI];
    }
    return self;
}

- (void)setupStaticUI{
    [Factory imageViewWithCenter:self.center image:ImageNamed(@"正在播放") onView:self];
}

- (void)setupUI{
    
    self.backgroundColor = COLOR_HEXSTRING(@"#F47686");
    
    _waveUpShareLyer = [CAShapeLayer layer];
    _waveUpShareLyer.fillColor = COLOR_HEXSTRING(@"#A34350").CGColor;
    [self.layer addSublayer:_waveUpShareLyer];
    
    _waveCenterShareLayer = [CAShapeLayer layer];
    _waveCenterShareLayer.fillColor = COLOR_HEXSTRING(@"#F7B6BF").CGColor;
        [self.layer addSublayer:_waveCenterShareLayer];
    
    _waveDownShareLayer = [CAShapeLayer layer];
    _waveDownShareLayer.fillColor = COLOR_HEXSTRING(@"#FFFFFF").CGColor;
    [self.layer addSublayer:_waveDownShareLayer];
}

- (void)startWaveAnimation{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave)];
        //_displayLink.preferredFramesPerSecond = 40; //此处有bug
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)stopWaveAnimation{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)getCurrentWave{
    
    // 第一条波纹
    _offsetX += _waveSpeed;
    CGMutablePathRef uppath = CGPathCreateMutable();
    CGPathMoveToPoint(uppath, nil, 0, _waveHeight + 15);
    CGFloat y = 0;
    for (float x= 0; x<= _waveWidth; x++) {
        y = _waveAmplitude/4 * sinf((800 / _waveWidth) * (x * M_PI / 180) - _offsetX * M_PI / 270) + _waveHeight;
        CGPathAddLineToPoint(uppath, nil, x, y - 15);
    }
    CGPathAddLineToPoint(uppath, nil,_waveWidth, self.frame.size.height);
    CGPathAddLineToPoint(uppath, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(uppath);
    _waveUpShareLyer.path = uppath;
    CGPathRelease(uppath);
    
    
    // 第二条波纹
    _offsetX_T += _waveSpeed;
    CGMutablePathRef centerPath = CGPathCreateMutable();
    CGPathMoveToPoint(centerPath, nil, 0, _waveHeight + 2);
    CGFloat yc = 0;
    for (float x= 0.0f; x<= _waveWidth; x++) {
        yc = _waveAmplitude * sinf((500/_waveWidth)*(x*M_PI/180)-_offsetX_N*M_PI/230) + _waveHeight;
        CGPathAddLineToPoint(centerPath, nil, x, yc -2);
    }
    CGPathAddLineToPoint(centerPath, nil, _waveWidth, self.frame.size.height);
    CGPathAddLineToPoint(centerPath, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(centerPath);
    _waveCenterShareLayer.path = centerPath;
    CGPathRelease(centerPath);
    
    
    // 第三条波纹
    _offsetX_N +=_waveSpeed;
    CGMutablePathRef downPath = CGPathCreateMutable();
    CGPathMoveToPoint(downPath, nil, 0, _waveHeight);
    CGFloat yt = 0;
    for (float x= 0.0f; x<= _waveWidth; x++) {
        
        yt = _waveAmplitude* 0.9 * sinf((300/_waveWidth)*(x*M_PI/180)-_offsetX_N*M_PI/200) + _waveHeight;
        CGPathAddLineToPoint(downPath, nil, x, yt);
    }
    CGPathAddLineToPoint(downPath, nil, _waveWidth, self.frame.size.height);
    CGPathAddLineToPoint(downPath, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(downPath);
    _waveDownShareLayer.path = downPath;
    CGPathRelease(downPath);
    
}

- (void)startWaveStaticAnimation{
    
    
    
    
    
}

/**
 关闭静态动画
 */
- (void)stopWaveStaticAnimation{
    
    
    
    
    
    
}





@end
