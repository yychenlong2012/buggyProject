//
//  MusicBtnView.m
//  Buggy
//
//  Created by goat on 2018/4/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicBtnView.h"

@implementation MusicBtnView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:[UIScreen mainScreen].bounds.size.width == 320?13:15];
        [self addSubview:self.label];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.width, self.width);
    self.label.frame = CGRectMake(0, self.height-15, self.width, 15);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
