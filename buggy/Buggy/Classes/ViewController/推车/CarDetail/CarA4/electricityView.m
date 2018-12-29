//
//  electricityView.m
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "electricityView.h"
//#import "animationTools.h"
#import "springAnimation.h"

@interface electricityView()
@property (nonatomic,strong) UILabel *label1;
@property (nonatomic,strong) UILabel *label2;

@property (nonatomic,strong) CAShapeLayer *leftBGLayer;
@property (nonatomic,strong) CAShapeLayer *rightBGLayer;
@end
@implementation electricityView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.leftlabel = [[UILabel alloc] init];
        self.leftlabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:19];
        self.leftlabel.textColor = [UIColor colorWithHexString:@"#222222"];
        self.leftlabel.textAlignment = NSTextAlignmentCenter;
//        self.leftlabel.text = @"80%";
        [self addSubview:self.leftlabel];
        
        self.rightLabel = [[UILabel alloc] init];
        self.rightLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:19];
        self.rightLabel.textColor = [UIColor colorWithHexString:@"#222222"];
        self.rightLabel.textAlignment = NSTextAlignmentCenter;
//        self.rightLabel.text = @"50%";
        [self addSubview:self.rightLabel];
        
        self.leftBGLayer = [CAShapeLayer layer];
        self.leftBGLayer.fillColor = kClearColor.CGColor;
        self.leftBGLayer.strokeColor = [UIColor colorWithHexString:@"#EEEEEE"].CGColor;
        self.leftBGLayer.lineWidth = 8;
        [self.layer addSublayer:self.leftBGLayer];
        
        self.rightBGLayer = [CAShapeLayer layer];
        self.rightBGLayer.fillColor = kClearColor.CGColor;
        self.rightBGLayer.strokeColor = [UIColor colorWithHexString:@"#EEEEEE"].CGColor;
        self.rightBGLayer.lineWidth = 8;
        [self.layer addSublayer:self.rightBGLayer];
        
        self.leftLayer = [CAShapeLayer layer];
        self.leftLayer.fillColor = kClearColor.CGColor;
        self.leftLayer.strokeColor = [UIColor colorWithHexString:@"#E04E63"].CGColor;
        self.leftLayer.lineWidth = 8;
        self.leftLayer.lineCap = @"round";
        self.leftLayer.strokeStart = 0;
        self.leftLayer.strokeEnd = 0;
        [self.layer addSublayer:self.leftLayer];
        
        self.rightLayer = [CAShapeLayer layer];
        self.rightLayer.fillColor = kClearColor.CGColor;
        self.rightLayer.strokeColor = [UIColor colorWithHexString:@"#E04E63"].CGColor;
        self.rightLayer.lineWidth = 8;
        self.rightLayer.lineCap = @"round";
        self.rightLayer.strokeStart = 0;
        self.rightLayer.strokeEnd = 0;
        [self.layer addSublayer:self.rightLayer];
        
        self.label1 = [[UILabel alloc] init];
        self.label1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        self.label1.textColor = [UIColor colorWithHexString:@"#101010"];
        self.label1.textAlignment = NSTextAlignmentCenter;
        self.label1.text = NSLocalizedString(@"刹车组电量", nil);
        [self addSubview:self.label1];
        
        self.label2 = [[UILabel alloc] init];
        self.label2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        self.label2.textColor = [UIColor colorWithHexString:@"#101010"];
        self.label2.textAlignment = NSTextAlignmentCenter;
        self.label2.text = NSLocalizedString(@"手把组电量", nil);
        [self addSubview:self.label2];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(59+RealWidth(95)/2, 19)];
    [path addArcWithCenter:CGPointMake(59+RealWidth(95)/2, 19+RealWidth(95)/2) radius:RealWidth(95)/2 startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    self.leftBGLayer.path = path.CGPath;
    self.leftLayer.path = path.CGPath;
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(ScreenWidth-59-RealWidth(95)/2, 19)];
    [path2 addArcWithCenter:CGPointMake(ScreenWidth-59-RealWidth(95)/2, 19+RealWidth(95)/2) radius:RealWidth(95)/2 startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    self.rightBGLayer.path = path2.CGPath;
    self.rightLayer.path = path2.CGPath;
    
    self.leftlabel.frame = CGRectMake(59, 19+(RealWidth(95)-19)/2, RealWidth(95), 19);
    self.rightLabel.frame = CGRectMake(ScreenWidth-59-RealWidth(95), 19+(RealWidth(95)-19)/2, RealWidth(95), 19);
    
    self.label1.frame = CGRectMake(0, self.height-36, 120, 16);
    self.label1.centerX = 59+RealWidth(95)/2;
    
    self.label2.frame = CGRectMake(0, self.height-36, 120, 16);
    self.label2.centerX = ScreenWidth-59-RealWidth(95)/2;
}

-(void)setLeftValue:(CGFloat)leftValue{
    //动画
    springAnimation *tools = [[springAnimation alloc] init];
    __weak typeof(self) wself = self;
    [tools animationWithFormValue:0.0 toValue:leftValue damping:3 velocity:10 duration:1.5 callback:^(CGFloat value) {
        wself.leftLayer.strokeEnd = value;
    }];
}

-(void)setRightValue:(CGFloat)rightValue{
    //动画
    springAnimation *tools = [[springAnimation alloc] init];
    __weak typeof(self) wself = self;
    [tools animationWithFormValue:0.0 toValue:rightValue damping:3 velocity:10 duration:1.5 callback:^(CGFloat value) {
        wself.rightLayer.strokeEnd = value;
    }];
}

//关机状态
-(void)closeBattery{
    self.leftlabel.text = @"";
    self.rightLabel.text = @"";
    self.leftLayer.strokeEnd = 0;
    self.rightLayer.strokeEnd = 0;
}

@end
