//
//  histogramCollectionViewCell.m
//  Buggy
//
//  Created by goat on 2018/3/24.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "histogramCollectionViewCell.h"
@interface histogramCollectionViewCell()

@end
@implementation histogramCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.lineHeight = 0;
        self.contentView.clipsToBounds = NO;
//        self.contentView.layer.borderWidth = 1;
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.strokeColor = kClearColor.CGColor;
        self.shapeLayer.lineWidth = 30;
//        self.shapeLayer.lineCap = @"round";
        [self.contentView.layer addSublayer:self.shapeLayer];
        
        self.topLayer = [CAShapeLayer layer];
        self.topLayer.strokeColor = kRandomColor.CGColor;
        self.topLayer.lineCap = @"round";
        self.topLayer.lineWidth = 4;
        [self.contentView.layer addSublayer:self.topLayer];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
        [self.contentView addSubview:self.dateLabel];
        
        self.lastDateLabel = [[UILabel alloc] init];
        self.lastDateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.lastDateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lastDateLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat bottomMargin = 40;   //距离cell底部的间距
    CGFloat realLineHeight;
    if (self.isMonthType == YES) {
        realLineHeight = self.lineHeight * ((self.height-bottomMargin)/8*7/35);
    }else{
        realLineHeight = self.lineHeight * ((self.height-bottomMargin)/8);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.width/2, self.height-bottomMargin)];
    [path addLineToPoint:CGPointMake(self.width/2, self.height-realLineHeight-bottomMargin)];
    self.shapeLayer.path = path.CGPath;
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(0, self.height-realLineHeight-bottomMargin)];
    [path2 addLineToPoint:CGPointMake(self.width, self.height-realLineHeight-bottomMargin)];
    self.topLayer.path = path2.CGPath;
    
//    self.dateLabel.frame = CGRectMake(-22.5, self.contentView.height-25, 32.5, 14);
//    self.lastDateLabel.frame = CGRectMake(20, self.contentView.height-25, 32.5, 14);
    self.dateLabel.frame = CGRectMake(-27.5, self.contentView.height-25, 42.5, 14);
    self.lastDateLabel.frame = CGRectMake(15, self.contentView.height-25, 42.5, 14);
    
    //周颜色
    switch (self.lineHeight) {
        case 0:
            self.topLayer.strokeColor = kGreenColor.CGColor;
            break;
        case 1:
            self.topLayer.strokeColor = kGreenColor.CGColor;
            break;
        case 2:
            self.topLayer.strokeColor = kGreenColor.CGColor;
            break;
        case 3:
            self.topLayer.strokeColor = kOrangeColor.CGColor;
            break;
        case 4:
            self.topLayer.strokeColor = kOrangeColor.CGColor;
            break;
        case 5:
            self.topLayer.strokeColor = kOrangeColor.CGColor;
            break;
        case 6:
            self.topLayer.strokeColor = kOrangeColor.CGColor;
            break;
        case 7:
            self.topLayer.strokeColor = kOrangeColor.CGColor;
            break;
        default:
            break;
    }
    
    //月颜色
    if (self.lineHeight > 7 && self.lineHeight <= 10) {
        self.topLayer.strokeColor = kGreenColor.CGColor;
    }
    if (self.lineHeight > 10) {
        self.topLayer.strokeColor = kOrangeColor.CGColor;
    }
 
}

-(void)setLineHeight:(NSInteger)lineHeight{
    _lineHeight = lineHeight;
    [self layoutSubviews];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
//    if (selected) {
//        const CGFloat *components = CGColorGetComponents(self.topLayer.strokeColor);
//        CGFloat red = components[0];
//        CGFloat green = components[1];
//        CGFloat blue = components[2];
//        self.shapeLayer.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5].CGColor;
//    }else{
//        self.shapeLayer.strokeColor = kClearColor.CGColor;
//    }
}


@end
