//
//  FAQTableViewCell.m
//  Buggy
//
//  Created by goat on 2017/11/14.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "FAQTableViewCell.h"

@implementation FAQTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, 44);
        self.contentView.clipsToBounds = YES;
        self.isSelect = NO;
        [self setCostomView];
    }
    return self;
}

-(void)setCostomView{

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.3;
    line.frame = CGRectMake(0, self.contentView.frame.size.height-1, ScreenWidth, 1);
    [self.contentView addSubview:line];
    __weak typeof(self) wself = self;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(wself.mas_bottom);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
    }];
    
    //图标
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.frame = CGRectMake(15, 14.5, 15, 15);
    arrow.alpha = 0.6;
    arrow.image = [UIImage imageNamed:@"音乐返回"];
    [self.contentView addSubview:arrow];
    self.arrow = arrow;
    
    //标题
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(35, 10, 150, 20);
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"11";
    label.textAlignment = NSTextAlignmentLeft;
    self.title = label;
    [self.contentView addSubview:label];
    
    //描述
    self.detail = [[UILabel alloc] init];
    self.detail.textColor = [UIColor grayColor];
    self.detail.frame = CGRectMake(35, 44, ScreenWidth -45, 11);
    self.detail.numberOfLines = 0;
    self.detail.font = [UIFont systemFontOfSize:14];
    self.detail.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.detail];
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
