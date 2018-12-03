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

@interface lineCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
//@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *imageview;
@end
@implementation lineCollectionView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        lineLayoutOne *layout = [[lineLayoutOne alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        self.collectionView.backgroundColor = kWhiteColor;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.layer.borderWidth = 1;
        self.collectionView.layer.borderColor = kRedColor.CGColor;
        [self addSubview:self.collectionView];
        
        // 注册cell、sectionHeader、sectionFooter
        [self.collectionView registerClass:[LineCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        self.imageview = [[UIImageView alloc] init];
        self.imageview.image = [UIImage imageNamed:@"Group7"];
        [self addSubview:self.imageview];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    
    self.imageview.frame = CGRectMake(ScreenWidth/2 -15, self.height-50, 30, 30);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count+20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
//    cell.backgroundColor = kRandomColor;
    cell.lineHeight = 100 + arc4random()%300;
    cell.dateLabel.text = @"3.12";
    //抗锯齿
//    cell.layer.shouldRasterize = YES;
//    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    
    
    return cell;
}


//-(void)setDataArray:(NSArray<NSString*> *)dataArray
//{
//    _dataArray = dataArray;
//
//    //设置数据
//    self.scrollView.contentSize = CGSizeMake(dataArray.count * 70, 0);
//    for (NSInteger i = 0; i<dataArray.count; i++) {
//        UIView *view = [[UIView alloc] init];
//        view.backgroundColor = kRandomColor;
//        view.frame = CGRectMake(i*70, 0, 70, self.height);
//        [self.scrollView addSubview:view];
//
//        //线条背景view
//        UIView *lineBGView = [[UIView alloc] init];
//        lineBGView.backgroundColor = kClearColor;
//        lineBGView.frame = CGRectMake(0, 0, view.width, view.height-80);
//        lineBGView.layer.borderWidth = 1;
//        [view addSubview:lineBGView];
//
//        UIView *line = [[UIView alloc] init];
//        line.backgroundColor = kWhiteColor;
//        line.frame = CGRectMake(view.width/2-10, lineBGView.height-[dataArray[i] integerValue], 20, [dataArray[i] integerValue]);
//        line.layer.cornerRadius = 10;
//        [lineBGView addSubview:line];
//
//        UILabel *dataLabel = [[UILabel alloc] init];
//        dataLabel.textAlignment = NSTextAlignmentCenter;
//        dataLabel.font = [UIFont systemFontOfSize:15];
//        dataLabel.text = @"3.12";
//        dataLabel.frame = CGRectMake(view.width/2-20, view.height-50, 40, 40);
//        [view addSubview:dataLabel];
//    }
//}


@end
