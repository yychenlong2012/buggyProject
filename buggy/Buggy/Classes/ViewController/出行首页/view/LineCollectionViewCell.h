//
//  LineCollectionViewCell.h
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineCollectionViewCell : UICollectionViewCell
@property (nonatomic,assign) NSInteger lineHeight;
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) NSString *date;    //存放日期
@property (nonatomic,strong) NSString *orgDate;  //原始日期

@property (nonatomic,assign) CGFloat theLongestMileage;   //最长的日里程

-(void)isCenterCell:(BOOL)flag;   //是否为中间的cell
@end
