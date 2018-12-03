//
//  lineBGView.h
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class lineLayoutOne;
@class dateModel;
@protocol lineCollectionViewDelegate <NSObject>
-(void)updateMileage:(NSInteger)mileage index:(NSIndexPath*)index;   //日里程刷新

-(void)scrollViewContentOffsetX:(CGFloat)offsetX;  //x的偏移量

@end
@interface lineCollectionView : UIView
@property (nonatomic,weak) id<lineCollectionViewDelegate> delegate;
@property (nonatomic,strong) NSMutableArray<dayMileageModel *> *dataArray;
@property (nonatomic,strong) lineLayoutOne *layout;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *centerIndexPath;    //中间cell的下标
@property (nonatomic,assign) CGFloat theLongestMileage;        //最长的出行记录

-(void)manualSetToplabel;  //设置顶部文字
-(void)setSparseAnddense:(CGFloat)cellWidth;   //设置稠密布局和稀疏布局
-(void)setupCenterCell;
@end
