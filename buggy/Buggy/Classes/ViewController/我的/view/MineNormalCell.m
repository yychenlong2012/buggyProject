//
//  MineNormalCell.m
//  Buggy
//
//  Created by 孟德林 on 16/9/22.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "MineNormalCell.h"

@implementation MineNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, NormalCellHeight);
        [self setCostomView];
    }
    return self;
}

- (void)setCostomView{
    
    self.titleImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 18, 18) image:nil onView:self];
    self.titleImage.left = self.left + 20 * _MAIN_RATIO_375;
    self.titleImage.centerY = NormalCellHeight / 2;
    
    self.functionName = [Factory labelWithFrame:CGRectMake(0, 0, 130, 21) font:FONT_DEFAULT_Light(16) text:nil textColor:[Theme mineFunctionName] onView:self textAlignment:NSTextAlignmentCenter];
    self.functionName.left = self.titleImage.right + 7.5 * _MAIN_RATIO_375;
    self.functionName.centerY = NormalCellHeight / 2;
    self.functionName.textAlignment = NSTextAlignmentLeft;

    UIView *lineView = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth - 40 * _MAIN_RATIO_375, 0.5) bgColor:[Theme mineLineColor] onView:self];
    lineView.left = self.titleImage.left;
    lineView.bottom = NormalCellHeight;
    [Factory imageViewWithCenter:CGPointMake(lineView.right, NormalCellHeight/ 2) image:ImageNamed(@"arror") onView:self];
    
    //检测更新提示
    UILabel *label = [[UILabel alloc] init];
    NSString *str = NSLocalizedString(@"更新",nil);
    if ([str containsString:@"update"]) {
        str = [NSString stringWithFormat:@" %@",NSLocalizedString(@"更新",nil)];
    }else{
        str = [NSString stringWithFormat:@"   %@",NSLocalizedString(@"更新",nil)];
    }
    label.text = str;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = COLOR_HEXSTRING(@"#F47686");
    label.frame = CGRectMake(0, 0, 45, 18);
    label.centerY = self.centerY;
    label.left = ScreenWidth - 35 - label.width;
    label.layer.cornerRadius = 9;
    label.clipsToBounds = YES;
    [self addSubview:label];
    self.updateLabel = label;
}

@end
