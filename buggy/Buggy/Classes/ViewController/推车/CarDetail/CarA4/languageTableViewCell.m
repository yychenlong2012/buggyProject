//
//  languageTableViewCell.m
//  Buggy
//
//  Created by goat on 2018/5/10.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "languageTableViewCell.h"

@implementation languageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.SelectedIcon = [[UIImageView alloc] init];
        self.SelectedIcon.image = ImageNamed(@"选中icon");
        [self.contentView addSubview:self.SelectedIcon];
        self.SelectedIcon.hidden = YES;
        
        self.language = [[UILabel alloc] init];
        self.language.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        self.language.textColor = [UIColor colorWithHexString:@"#101010"];
        [self.contentView addSubview:self.language];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.language.frame = CGRectMake(45, 10, 100, 17);
    self.SelectedIcon.frame = CGRectMake(20, 0, 15, 15);
    self.SelectedIcon.centerY = self.language.centerY;
    
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
