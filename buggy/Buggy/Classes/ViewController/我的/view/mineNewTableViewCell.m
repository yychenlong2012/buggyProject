//
//  mineNewTableViewCell.m
//  Buggy
//
//  Created by goat on 2018/5/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "mineNewTableViewCell.h"

@implementation mineNewTableViewCell{
    CAShapeLayer *shapelayer;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        
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
        
        self.babyIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.babyIcon];
        self.babyIcon.hidden = YES;
//        shapelayer = [CAShapeLayer layer];
//        self.babyIcon.layer.mask = shapelayer;
        
        self.arrow = [[UIImageView alloc] init];
        self.arrow.image = ImageNamed(@"更多内容icon");
        [self.contentView addSubview:self.arrow];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(20, 0, 20, 20);
    self.icon.centerY = self.contentView.height/2;
    
    self.itemLabel.frame = CGRectMake(self.icon.right + 10, 2, 200, 16);
    self.itemLabel.centerY = self.contentView.height/2;
    
    self.detailLabel.frame = CGRectMake(ScreenWidth-170, 3.5, 150, 13);
    self.detailLabel.centerY = self.contentView.height/2;
    
    self.babyIcon.frame = CGRectMake(ScreenWidth-RealWidth(42)-20, 0, RealWidth(42), RealWidth(42));
    self.babyIcon.centerY = self.contentView.height/2;
    self.babyIcon.centerY = self.contentView.centerY;
    self.babyIcon.layer.cornerRadius = RealWidth(21);
    self.babyIcon.clipsToBounds = YES;
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.babyIcon.bounds];
//    shapelayer.path = path.CGPath;
    
    self.arrow.frame = CGRectMake(ScreenWidth-27, 0, 7, 12);
    self.arrow.centerY = self.itemLabel.centerY;
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
