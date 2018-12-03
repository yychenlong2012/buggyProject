//
//  TagView.m
//  Buggy
//
//  Created by ningwu on 16/5/29.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "TagView.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"

@implementation TagView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.pointView.layer.cornerRadius = 4.0f;
    self.pointView.layer.shadowColor=[UIColor grayColor].CGColor;
//    self.pointView.layer.shadowOffset=CGSizeMake(10, 10);
    self.pointView.layer.shadowOpacity=0.5;
    self.pointView.layer.shadowRadius=2;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    CGSize size = [self.textLabel sizeToString:text];
    self.width = size.width + 34;
    self.imgTag.width = self.width - 12;
}

@end
