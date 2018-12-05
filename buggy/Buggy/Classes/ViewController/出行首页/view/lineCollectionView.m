//
//  lineBGView.m
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "lineCollectionView.h"
#import "LineCollectionViewCell.h"
#import "lineLayoutOne.h"
#import "dateModel.h"
#import "TripDetailViewController.h"

@interface lineCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UIImageView *imageview;
@property (nonatomic,strong) UIView *lineView;

@end
@implementation lineCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        lineLayoutOne *layout = [[lineLayoutOne alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(40, ScreenHeight-bottomSafeH-statusBarH-239);
        self.layout = layout;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        self.collectionView.backgroundColor = kWhiteColor;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        
        // 注册cell、sectionHeader、sectionFooter
        [self.collectionView registerClass:[LineCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        self.imageview = [[UIImageView alloc] init];
        self.imageview.image = [UIImage imageNamed:@"指示图标"];
        [self addSubview:self.imageview];
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"#172058"];
        self.lineView.alpha = 0.15;
        [self addSubview:self.lineView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    
    self.imageview.frame = CGRectMake((ScreenWidth-11)/2, self.height-35, 13, 11);
    self.lineView.frame = CGRectMake(0, self.imageview.bottom, ScreenWidth, 1);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    if (indexPath.row < self.dataArray.count && self.dataArray.count>0) {
        dayMileageModel *model = self.dataArray[indexPath.row];
        cell.lineHeight = model.mileage;
        cell.dateLabel.text = [model.traveldate substringFromIndex:5];
        cell.date = model.traveldate;
        cell.orgDate = model.date;
        cell.theLongestMileage = self.theLongestMileage;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%@",indexPath);
}


#pragma mark - scrollviewdelegate
//停止滑动时
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self manualSetToplabel];
 
    //偏移量微调
    //当前中心位置
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.width/2;
    //距离中心最近的位置
    CGFloat minOffsetX = MAXFLOAT;
    //停止滑动时调整位置
    for (UITableViewCell *cell in self.collectionView.visibleCells) {
        //cell的中心
        CGFloat cellCenterX = cell.left + cell.contentView.width/2;
        if (ABS(centerX - cellCenterX) < ABS(minOffsetX)) {
            minOffsetX = centerX - cellCenterX;
        }
    }
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x - minOffsetX, 0) animated:YES];
}

//结束拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.x < -30) {
        //左拉刷新
        if ([[UIViewController presentingVC] isKindOfClass:[TripDetailViewController class]]) {
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            [vc loadMoreDateIsMileage:YES];
        }
    }else{
        //结束拖拽时不会触发停止滑动的代理方法   手动调用
        if (decelerate == NO) {  //结束拖拽时没有速度调用
            [self scrollViewDidEndDecelerating:self.collectionView];
        }
    }
}

//滑动过程
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewContentOffsetX:)] && self.delegate) {
        [self.delegate scrollViewContentOffsetX:scrollView.contentOffset.x];
    }
    //设置cell的样式
    [self setupCenterCell];
}

//将显示在最中间的cell的内容赋值给toplabel
-(void)manualSetToplabel{
    //获得指定矩形内的cell的高度
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        //获得下标
        NSIndexPath *index = [self.collectionView indexPathForCell:cell];
        
        LineCollectionViewCell *cell2 = (LineCollectionViewCell *)cell;
        CGRect rect = [cell convertRect:cell.contentView.frame toView:self];
        CGFloat x = ScreenWidth/2;
        
        //获得屏幕中间的cell
        if (x > rect.origin.x && x < (rect.origin.x+rect.size.width)) {
            self.centerIndexPath = index;
            if ([self.delegate respondsToSelector:@selector(updateMileage:index:)] && self.delegate) {
                [self.delegate updateMileage:cell2.lineHeight index:index];
            }
            //先看看每日详情数据是否存在
            if (index.row < self.dataArray.count) {
                dayMileageModel *model = self.dataArray[index.row];
                if (model.travelInfoArray != nil && [model.travelInfoArray isKindOfClass:[NSMutableArray class]] && model.travelInfoArray.count > 0) {
                    if ([[UIViewController presentingVC] isKindOfClass:[TripDetailViewController class]]) {
                        TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
                        [vc.travelInfoArray removeAllObjects];
                        [vc.travelInfoArray addObjectsFromArray:model.travelInfoArray];
                        //刷新数据
                        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                        [vc.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                        [vc.tableview setContentOffset:CGPointZero animated:YES];
                    }
                }else{
                    //请求每日详情
                    if ([[UIViewController presentingVC] isKindOfClass:[TripDetailViewController class]]) {
                        TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
                        [vc requestDailyMesseageWithDate:cell2.orgDate andLineHeight:cell2.lineHeight index:index.row];
                    }
                }
            }
        }
    }
}


//设置中间cell的颜色
-(void)setupCenterCell{
    //改变颜色
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        LineCollectionViewCell *cell2 = (LineCollectionViewCell *)cell;
        CGRect rect = [cell convertRect:cell.contentView.frame toView:self];
        CGFloat x = ScreenWidth/2;
        //获得屏幕中间的cell
        if (x > rect.origin.x && x < (rect.origin.x+rect.size.width)) {
            [cell2 isCenterCell:YES];
        }else{
            [cell2 isCenterCell:NO];
        }
    }
}

//切换稠密和稀疏布局时调用
-(void)setSparseAnddense:(CGFloat)cellWidth{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //正确的偏移量
        CGFloat offsetX = cellWidth*(self.centerIndexPath.row);
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    });
}

-(void)setDataArray:(NSMutableArray<dayMileageModel *> *)dataArray{
    _dataArray = dataArray;
    self.centerIndexPath = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
}

@end
