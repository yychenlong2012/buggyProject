//
//  histogramCollectionViewCell.h
//  Buggy
//
//  Created by goat on 2018/3/24.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface histogramCollectionViewCell : UICollectionViewCell
@property (nonatomic,assign) NSInteger lineHeight;
@property (nonatomic,strong) CAShapeLayer *topLayer;    //小横线
@property (nonatomic,strong) CAShapeLayer *shapeLayer;  //柱状背景
@property (nonatomic,strong) UILabel *dateLabel;        //日期
@property (nonatomic,strong) UILabel *lastDateLabel;    //结尾日期

@property (nonatomic,assign) BOOL isMonthType;          //当前cell是不是表示月
@end
