//
//  LineCollectionViewCell.m
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "LineCollectionViewCell.h"
#import "animationTools.h"
@interface LineCollectionViewCell()
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) UIBezierPath *path;
@end
@implementation LineCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#6477f0"].CGColor;
//        self.shapeLayer.lineWidth = self.contentView.width-2;
//        self.shapeLayer.lineWidth = 20;
        self.shapeLayer.lineCap = @"round";
        [self.contentView.layer addSublayer:self.shapeLayer];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
        [self.contentView addSubview:self.dateLabel];
        
        self.path = [UIBezierPath bezierPath];
    
        self.contentView.backgroundColor = kClearColor;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //根据最长的那条数据设置长度
    CGFloat height = 0;
    if (self.theLongestMileage > 0) {
        //根据距离等级设置高度上限  500米以内为第一级  500-1000为第二级  大于1000为第三级
        if (self.theLongestMileage < 1000) {
            height = self.lineHeight/self.theLongestMileage * RealWidth(200);
        }else if (self.theLongestMileage < 2000){
            height = self.lineHeight/self.theLongestMileage * RealWidth(270);
        }else{
            height = self.lineHeight/self.theLongestMileage * RealWidth(320);
        }
    }else{
        height = self.lineHeight;
    }
    
    [self.path removeAllPoints];
    [self.path moveToPoint:CGPointMake(self.width/2, self.height-(ScreenWidth==320?40:55))];
    [self.path addLineToPoint:CGPointMake(self.width/2, self.height-height-(ScreenWidth==320?40:55))];
    self.shapeLayer.path = self.path.CGPath;
    if (self.contentView.width == 10) {
        self.shapeLayer.lineWidth = 8;
    }else{
        self.shapeLayer.lineWidth = 20;
    }
    
    if (self.lineHeight > 0) {
        animationTools *tools = [[animationTools alloc] init];
        __weak typeof(self) wself = self;
        [tools animationWithFormValue:0.0 toValue:1.0 damping:5 velocity:30 duration:1.0 callback:^(CGFloat value) {
            wself.shapeLayer.strokeEnd = value;
        }];
    }
    
    self.dateLabel.frame = CGRectMake(0, self.height-17, self.contentView.width, 17);
    
    if (self.contentView.width <= 20) {
        self.dateLabel.hidden = YES;
    }else{
        self.dateLabel.hidden = NO;
    }
}

-(void)setLineHeight:(NSInteger)lineHeight{
    _lineHeight = lineHeight;
    [self layoutSubviews];
}

-(void)isCenterCell:(BOOL)flag{
    if (flag) {
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#E04E63"].CGColor;
        self.dateLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
        self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    }else{
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#6477f0"].CGColor;
        self.dateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
        self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
}
@end
