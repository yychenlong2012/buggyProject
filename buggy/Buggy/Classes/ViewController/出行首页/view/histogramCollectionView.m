//
//  histogramCollectionView.m
//  Buggy
//
//  Created by goat on 2018/3/24.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "histogramCollectionView.h"
#import "lineLayoutTwo.h"
#import "histogramCollectionViewCell.h"
#import "MYLabel.h"
#import "frequencyWeekModel.h"
#import "TripDetailViewController.h"
#define margin 40
@interface histogramCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) lineLayoutTwo *layout;

@end
@implementation histogramCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layout = [[lineLayoutTwo alloc] init];
        
//        layout.minimumLineSpacing = 0;
//        layout.minimumInteritemSpacing = 0;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.layout];
        self.collectionView.backgroundColor = kWhiteColor;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
//        self.collectionView.layer.borderWidth = 1;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        
        // 注册cell、sectionHeader、sectionFooter
        [self.collectionView registerClass:[histogramCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        //标识
        NSArray *textArray = @[@"7",@"6",@"5",@"4",@"3",@"2",@"1",@"0"];
        self.LabelArray = [NSMutableArray array];
        for (NSInteger i = 0; i<8; i++) {
            MYLabel *label = [[MYLabel alloc] init];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentRight;
            label.text = textArray[i];
            [label setVerticalAlignment:VerticalAlignmentBottom];
            [self addSubview:label];
            [self.LabelArray addObject:label];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.layout.itemSize = CGSizeMake(30, self.height - margin);
    self.collectionView.frame = CGRectMake(margin, margin, ScreenWidth-margin, self.height-margin);
    
    //标识
    CGFloat Labelheight = (self.collectionView.height-margin)/8;
    for (NSInteger i = 0; i<self.LabelArray.count; i++) {
        MYLabel *label =self.LabelArray[i];
        label.frame = CGRectMake(0, margin+i*Labelheight, 40, Labelheight);
        
        //坐标线
        CAShapeLayer *layer = [CAShapeLayer layer];
        if (i!=7) {
            layer.strokeColor = kRGBAColor(23, 32, 88, 0.04).CGColor;
        }else{
            layer.strokeColor = kRGBAColor(51, 71, 199, 0.2).CGColor;
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(label.right, label.bottom)];
        [path addLineToPoint:CGPointMake(ScreenWidth-label.right, label.bottom)];
        layer.path = path.CGPath;
        [self.layer addSublayer:layer];
        
        label.bottom += RealWidth(8);
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12.5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    histogramCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.lineHeight = 0;
    cell.isMonthType = self.isMonthType;
    cell.topLayer.strokeColor = kClearColor.CGColor;
    cell.shapeLayer.strokeColor = kClearColor.CGColor;
    if (indexPath.row < self.dataArray.count) {
        frequencyWeekModel *model = self.dataArray[indexPath.row];
        cell.lineHeight = model.frequency;
        cell.dateLabel.text = [model.traveldate substringFromIndex:5];
//        cell.dateLabel.text = model.traveldate;
//        cell.dateLabel.text = [[model.traveldate substringFromIndex:5] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        //最后一列显示两个日期
        if (indexPath.row == self.dataArray.count - 1) {
            NSDateFormatter *forma = [[NSDateFormatter alloc] init];
            forma.dateFormat = @"M.d";
            cell.lastDateLabel.text = [forma stringFromDate:[NSDate date]];
        }else{
            cell.lastDateLabel.text = @"";
        }
    }
    return cell;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView.contentOffset.x < -30) {
        //左拉刷新
        TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
        [vc loadMoreDateIsMileage:NO];
    }
}

//停止滑动时
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self manualSetToplabel];
}

//将显示在最中间的cell的内容赋值给toplabel
-(void)manualSetToplabel{
    //获得指定矩形内的cell的高度
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        //获取下标
        NSIndexPath *index = [self.collectionView indexPathForCell:cell];
        
        histogramCollectionViewCell *cell2 = (histogramCollectionViewCell *)cell;
        CGRect rect = [cell convertRect:cell.contentView.frame toView:self];
        CGFloat x = (ScreenWidth-40)/2+40;
        if (x > rect.origin.x && x < (rect.origin.x+rect.size.width)) {
            NSLog(@"%ld",(long)cell2.lineHeight);
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateFrequency:index:)]) {
                [self.delegate updateFrequency:cell2.lineHeight index:index];
            }
        }
    }
}

//设置shaperlayer和字体的颜色
-(void)manualSetShapeLayerColor{
    histogramCollectionViewCell *centerCell;
    histogramCollectionViewCell *nextCell;
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        histogramCollectionViewCell *cell2 = (histogramCollectionViewCell *)cell;
        CGRect rect = [cell convertRect:cell.contentView.frame toView:self];  //转换坐标
        CGFloat x = (ScreenWidth-40)/2+40;
        
        if (x > rect.origin.x && x < (rect.origin.x+rect.size.width)) {
            centerCell = cell2;
            //改变颜色
            const CGFloat *components = CGColorGetComponents(cell2.topLayer.strokeColor);
            CGFloat red = components[0];
            CGFloat green = components[1];
            CGFloat blue = components[2];
            cell2.shapeLayer.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5].CGColor;
            //字体
            cell2.dateLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
            cell2.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];

            //cell2右边的label也要变色
            NSIndexPath *centerPath = [self.collectionView indexPathForCell:cell];
            NSIndexPath *nextPath = [NSIndexPath indexPathForItem:centerPath.item+1 inSection:0];
            nextCell = (histogramCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:nextPath];
        }else{
            cell2.shapeLayer.strokeColor = kClearColor.CGColor;
            //字体
            cell2.dateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
            cell2.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        }
    }
    //设置下一个cell
    if (nextCell == nil) {
        centerCell.lastDateLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
        centerCell.lastDateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    }else{
        nextCell.dateLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
        nextCell.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        centerCell.lastDateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
        centerCell.lastDateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
    //设置最后一个cell
    if (nextCell != nil) {
        histogramCollectionViewCell *lastCell = self.collectionView.visibleCells.lastObject;
        lastCell.lastDateLabel.textColor = [UIColor colorWithHexString:@"#172058"];
        lastCell.lastDateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self manualSetShapeLayerColor];
}

-(void)setTitleArray:(NSArray<NSString *> *)titleArray{
    _titleArray = titleArray;
    
    if (self.LabelArray.count != self.titleArray.count) {
        return;
    }
    for (NSInteger i = 0; i<self.LabelArray.count; i++) {
        MYLabel *label =self.LabelArray[i];
        label.text = self.titleArray[i];
    }
}

@end
