//
//  banner2.m
//  Buggy
//
//  Created by goat on 2018/6/30.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "banner2.h"
#import "bannerItem.h"

@interface banner2()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSMutableArray<bannerItem*> *itemArray;
@end
@implementation banner2

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.scrollview = [[UIScrollView alloc] init];
        self.scrollview.pagingEnabled = YES;
        self.scrollview.delegate = self;
        self.scrollview.clipsToBounds = NO;
        [self addSubview:self.scrollview];
        
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.numberOfPages = 4;
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#E04E63"];
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#F2F2F4"];
        [self addSubview:self.pageControl];
        
        self.itemArray = [NSMutableArray array];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.scrollview.frame = CGRectMake(0, 0, RealWidth(340), RealWidth(150));
    self.scrollview.centerX = self.width/2;
    
    self.pageControl.frame = CGRectMake(0, self.scrollview.bottom+7, 100, 12);
    self.pageControl.centerX = self.width/2;
}

-(void)setDataArray:(NSMutableArray<MusicBannerModel *> *)dataArray{
    _dataArray = dataArray;
    
    self.pageControl.numberOfPages = dataArray.count;
    
    self.scrollview.contentSize = CGSizeMake(dataArray.count*self.scrollview.width, 0);
    //设置数据
    [self.scrollview removeAllSubviews];
    [self.itemArray removeAllObjects];
    
    for (NSInteger i = 0; i<dataArray.count; i++) {
        bannerItem *item = [[bannerItem alloc] init];
        item.frame = CGRectMake(i*self.scrollview.width, 0, self.scrollview.width, self.scrollview.height);
        item.model = dataArray[i];
        [self.scrollview addSubview:item];
        [self.itemArray addObject:item];
    }
    //主动调用代理方法 初始化位置信息
    [self scrollViewDidScroll:self.scrollview];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}

-(void)startTimer{
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:7 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerRun{
    CGFloat currentOffsetX = self.scrollview.contentOffset.x;
    NSInteger currentPage = (NSInteger)((NSInteger)currentOffsetX/(NSInteger)RealWidth(340));
    CGFloat offsetX;
    if (currentPage == self.dataArray.count-1) {  //到底了
        offsetX = 0;
    }else{
        offsetX = currentOffsetX + RealWidth(340);
    }
    [self.scrollview setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;

    self.pageControl.currentPage = floor(offsetX/scrollView.width + 0.1);

    //中间线
    CGFloat centerX = offsetX + self.scrollview.width/2;
    
    for (bannerItem *item in self.itemArray) {
        CGFloat offsetWitCenter = fabs(item.centerX-centerX);
        CGFloat scale = offsetWitCenter/ScreenWidth;
        if (scale > 1) {
            scale = 1;
        }
        item.transform = CGAffineTransformMakeScale(1-scale*0.05, 1-scale*0.15);
    }
}


@end
