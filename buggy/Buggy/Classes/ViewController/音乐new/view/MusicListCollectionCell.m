//
//  MusicListCollectionCell.m
//  Buggy
//
//  Created by goat on 2018/4/10.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicListCollectionCell.h"
@interface MusicListCollectionCell()
@property (nonatomic,strong) CAShapeLayer *borderLayer;
@end
@implementation MusicListCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageview = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageview];
    
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        [self.contentView addSubview:self.label];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageview.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.width);
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageview.bounds cornerRadius:8];
    layer.path = path.CGPath;
    self.imageview.layer.mask = layer;
    
    self.label.frame = CGRectMake(0, self.imageview.bottom+9, self.contentView.width, 15);
}
@end
