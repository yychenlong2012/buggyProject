//
//  rankTableViewCell.m
//  Buggy
//
//  Created by goat on 2018/5/29.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "rankTableViewCell.h"

@implementation rankTableViewCell{
    CAShapeLayer *shapeLayer;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.userIcon = [[UIImageView alloc] init];
        shapeLayer = [CAShapeLayer layer];
        self.userIcon.layer.mask = shapeLayer;
        self.userIcon.image = ImageNamed(@"home_default");
        [self.contentView addSubview:self.userIcon];
        
        self.userName = [[UILabel alloc] init];
        self.userName.textColor = [UIColor colorWithHexString:@"#111111"];
        self.userName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        self.userName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.userName];
        
        self.time = [[UILabel alloc] init];
        self.time.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
        self.time.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        self.time.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.time];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.userIcon.frame = CGRectMake(25, 25, 40, 40);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.userIcon.bounds];
    shapeLayer.path = path.CGPath;
    
    self.userName.frame = CGRectMake(self.userIcon.right+20, 0, 120, 15);
    self.userName.centerY = self.userIcon.centerY;
    
    self.time.frame = CGRectMake(ScreenWidth-125, 0, 100, 13);
    self.time.centerY = self.userIcon.centerY;
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
