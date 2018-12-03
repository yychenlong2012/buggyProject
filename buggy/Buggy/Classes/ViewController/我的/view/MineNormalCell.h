//
//  MineNormalCell.h
//  Buggy
//
//  Created by 孟德林 on 16/9/22.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#define NormalCellHeight 52.5

#import <UIKit/UIKit.h>

@interface MineNormalCell : UITableViewCell

@property (nonatomic ,strong) UILabel  *functionName;

@property (nonatomic ,strong) UIImageView *titleImage;

@property (nonatomic ,strong) UILabel *updateLabel;  

@end
