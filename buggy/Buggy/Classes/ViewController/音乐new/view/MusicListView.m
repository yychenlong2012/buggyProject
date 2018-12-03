//
//  MusicListView.m
//  Buggy
//
//  Created by goat on 2018/4/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicListView.h"
@interface MusicListView()
@property (nonatomic,strong) UIImageView *playIcon;
@property (nonatomic,strong) UIImageView *musicIcon;
@property (nonatomic,strong) CAGradientLayer *colorLayer;   //阴影  渐变色
@end
@implementation MusicListView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        self.imageView.image = [UIImage imageNamed:@"Home_BGView_Day"];
        
        //阴影  渐变色
//        CAGradientLayer *layer = [CAGradientLayer layer];
//        layer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor,(__bridge id)kClearColor.CGColor];
//        layer.locations = @[@0.0,@1.0];
//        layer.startPoint = CGPointMake(0, 0);
//        layer.endPoint = CGPointMake(1, 0);
//        [self.imageView.layer addSublayer:layer];
//        self.colorLayer = layer;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#0E0E0E"];
        [self addSubview:self.titleLabel];
        
//        self.playedNum = [[UILabel alloc] init];
//        self.playedNum.textAlignment = NSTextAlignmentLeft;
//        self.playedNum.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//        self.playedNum.textColor = kWhiteColor;
//        [self.imageView addSubview:self.playedNum];
//        self.playedNum.text = @"131313";
        
//        self.playIcon = [[UIImageView alloc] init];
//        [self.imageView addSubview:self.musicIcon];
        
//        self.playingNum = [[UILabel alloc] init];
//        self.playingNum.textAlignment = NSTextAlignmentLeft;
//        self.playingNum.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//        self.playingNum.textColor = kWhiteColor;
//        [self.imageView addSubview:self.playingNum];
//        self.playingNum.text = @"52";
        
//        self.musicIcon = [[UIImageView alloc] init];
//        [self.imageView addSubview:self.musicIcon];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, RealWidth(160), RealWidth(160));
//    self.colorLayer.frame = CGRectMake(0, 0, self.imageView.width, 20);

    //圆角
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:8];
    shapelayer.path = path.CGPath;
    self.imageView.layer.mask = shapelayer;
    
    self.titleLabel.frame = CGRectMake(0, self.imageView.bottom+10, RealWidth(160), 15);
//    self.playIcon.frame = CGRectMake(10, 10, 10, 10);
//    self.playedNum.frame = CGRectMake(self.playIcon.right+10, 5, 60, 12);
//    self.musicIcon.frame = CGRectMake(self.imageView.width/2, 5, 10, 10);
//    self.playingNum.frame = CGRectMake(self.musicIcon.right+10, 5, 50, 10);
    
}


@end
