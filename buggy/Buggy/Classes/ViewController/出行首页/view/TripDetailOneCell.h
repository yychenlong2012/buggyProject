//
//  TripDetailOneCell.h
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class lineCollectionView;
@class histogramCollectionView;
typedef NS_ENUM(NSUInteger, showViewType) {
    TripShowFirstView   = 0,    //显示第一个界面  里程
    TripShowSecondView  = 1     //显示第二个界面  周频率
};
@interface TripDetailOneCell : UITableViewCell
@property (nonatomic,assign) showViewType viewType;
@property (nonatomic,strong) UILabel *topLabel;                      //里程数或者频率
@property (nonatomic,strong) UILabel *tipsLabel;                    //toplabel下面的label
@property (nonatomic,strong) NSAttributedString *beforeStr;    //界面左右切换时 保存上一个界面的topLabel字符串
@property (nonatomic,strong) lineCollectionView *lineView;            //竖线
@property (nonatomic,strong) histogramCollectionView *histogramView;  //柱状图
@end
