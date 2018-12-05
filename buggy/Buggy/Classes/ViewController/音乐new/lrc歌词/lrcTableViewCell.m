//
//  lrcTableViewCell.m
//  Buggy
//
//  Created by goat on 2018/6/13.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "lrcTableViewCell.h"
#import "lrcLabel.h"
@interface lrcTableViewCell()

@end
@implementation lrcTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = kClearColor;
        
        self.lrclabel = [[lrcLabel alloc] init];
        self.lrclabel.textColor = kBlackColor;
        self.lrclabel.textAlignment = NSTextAlignmentCenter;
        self.lrclabel.translatesAutoresizingMaskIntoConstraints = NO;   //??
        [self.contentView addSubview:self.lrclabel];
        self.lrclabel.backgroundColor  = kClearColor;
        __weak typeof(self) wself = self;
        [self.lrclabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wself.contentView);
        }];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
