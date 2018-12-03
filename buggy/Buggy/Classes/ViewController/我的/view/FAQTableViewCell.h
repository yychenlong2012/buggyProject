//
//  FAQTableViewCell.h
//  Buggy
//
//  Created by goat on 2017/11/14.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FAQTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UILabel *detail;
@property (nonatomic,strong) UIView *line;
@property (nonatomic,strong) UIImageView *arrow;
@property (nonatomic,assign) BOOL isSelect;

@end
