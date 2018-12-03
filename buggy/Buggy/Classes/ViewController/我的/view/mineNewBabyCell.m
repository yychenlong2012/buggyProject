//
//  mineNewBabyCell.m
//  Buggy
//
//  Created by goat on 2018/7/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "mineNewBabyCell.h"

@implementation mineNewBabyCell{
    CAShapeLayer *shapelayer;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        
        shapelayer = [CAShapeLayer layer];
        self.icon.layer.mask = shapelayer;
        
        self.itemLabel = [[UILabel alloc] init];
        self.itemLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        self.itemLabel.textColor = [UIColor colorWithMacHexString:@"#101010"];
        self.itemLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.itemLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        self.detailLabel.textColor = [UIColor colorWithMacHexString:@"#CCCCCC"];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(20, 0, 30, 30);
    self.icon.centerY = self.contentView.height/2;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.icon.bounds];
    shapelayer.path = path.CGPath;
    self.icon.layer.mask = shapelayer;
    
    self.itemLabel.frame = CGRectMake(self.icon.right + 10, 2, 200, 16);
    self.itemLabel.centerY = self.contentView.height/2;
    
    self.detailLabel.frame = CGRectMake(ScreenWidth-170, 3.5, 150, 13);
    self.detailLabel.centerY = self.contentView.height/2;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
