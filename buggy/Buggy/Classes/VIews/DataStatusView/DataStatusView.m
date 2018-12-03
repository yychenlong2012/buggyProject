//
//  DataStatusView.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/1.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "DataStatusView.h"

@implementation DataStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupStatusView];
    }
    return self;
}

- (void)setupStatusView{
    
    UIView *nodataView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:nodataView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 300)];
    imageView.center = nodataView.center;
    [imageView setImage:[UIImage imageNamed:@"bgImage.jpg"]];
    [nodataView addSubview:imageView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 500, 100, 100)];
    textLabel.text = @"对不起，没有数据，请重新刷新";
    textLabel.textAlignment = NSTextAlignmentCenter;
    [nodataView addSubview:textLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = imageView.frame;
    [button addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [nodataView addSubview:button];
}

- (void)reloadData{
    if (_reload) {
        _reload();
    }
}

@end
