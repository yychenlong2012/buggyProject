//
//  histogramCollectionView.h
//  Buggy
//
//  Created by goat on 2018/3/24.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class frequencyWeekModel;
@class MYLabel;
@protocol histogramCollectionViewDelegate <NSObject>
-(void)updateFrequency:(NSInteger)frequency index:(NSIndexPath*)index;   //频率刷新

@end
@interface histogramCollectionView : UIView
@property (nonatomic,weak) id<histogramCollectionViewDelegate> delegate;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray<MYLabel *> *LabelArray;   //柱状图的坐标提示
@property (nonatomic,strong) NSArray<NSString *> *titleArray;         //柱状图坐标
@property (nonatomic,strong) NSArray<frequencyWeekModel*> *dataArray;  //数据

@property (nonatomic,assign) BOOL isMonthType;    //当前cell是不是表示月


-(void)manualSetToplabel;
-(void)manualSetShapeLayerColor;
@end
