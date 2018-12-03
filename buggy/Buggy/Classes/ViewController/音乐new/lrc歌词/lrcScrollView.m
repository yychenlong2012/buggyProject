//
//  lrcScrollView.m
//  Buggy
//
//  Created by goat on 2018/6/13.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "lrcScrollView.h"
#import "lrcTableViewCell.h"
#import "lrcLabel.h"
#import "lrcModel.h"
#import "MusicActionTools.h"
#import "MusicManager.h"

@interface lrcScrollView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) UIView *line;   //中间线  拖动歌词时的中间线
/** 歌词的数据 */
@property (nonatomic, strong) NSMutableArray *lrclist;
/** 当前播放的歌词的下标 */
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *noContentView;  //无歌词时的背景
@end
@implementation lrcScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableview.dataSource = self;
        self.tableview.delegate = self;
        self.tableview.bounces = NO;
        self.tableview.showsVerticalScrollIndicator = NO;
        self.tableview.showsHorizontalScrollIndicator = NO;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableview.rowHeight = 35;
        self.tableview.backgroundColor = kClearColor;
        [self addSubview:self.tableview];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor colorWithHexString:@"E04E63"];
        self.line.hidden = YES;
        [self addSubview:self.line];
        
        self.lrclist = [NSMutableArray array];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.tableview.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, self.height);
    // 设置tableView多出的滚动区域
    self.tableview.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
    
    self.line.frame = CGRectMake(ScreenWidth, self.height/2, ScreenWidth, 1);
}

#pragma mark - 显示横线
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.line.hidden = NO;
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    self.line.hidden = YES;
    
    //如果手指松开时滑动速度为0 则更新歌曲播放进度
    if (velocity.y == 0) {
        //获取中间cell索引
        NSIndexPath * middleIndexPath = [_tableview  indexPathForRowAtPoint:CGPointMake(0, scrollView.contentOffset.y + _tableview.frame.size.height/2)];
        if (middleIndexPath.row < self.lrclist.count && middleIndexPath.row != self.currentIndex) {
   
            //改变之前播放的cell的样式
            NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            lrcTableViewCell *currCell = [_tableview cellForRowAtIndexPath:currentIndex];
            currCell.lrclabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
            currCell.lrclabel.progress = 0;
            
            //改变现在选中cell的样式
            lrcTableViewCell *middleCell = [_tableview cellForRowAtIndexPath:middleIndexPath];
            middleCell.lrclabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:20];
            
            //改变播放进度
            lrcModel *model = self.lrclist[middleIndexPath.row];
            FSStreamPosition position = {0};
            CGFloat progress = (model.time+0.05)/MUSICMANAGER.duration.playbackTimeInSeconds;   //直接设置model.time会有问题，往后偏移一点时间即可，避开这些切换歌词的边缘时间
            if (progress >= 1) {
                progress = 0.99;    //如果播放进度设为1 那么不会自动跳转到下一曲
            }
            position.position = progress;
            [MUSICMANAGER seekToPosition:position];     //取值范围0 - 1
        }
    }
}

#pragma mark - dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lrclist.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    lrcTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lrcCell"];
    if (cell == nil) {
        cell = [[lrcTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lrcCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.currentIndex == indexPath.row) {
        cell.lrclabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:20];
    } else {
        cell.lrclabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        cell.lrclabel.progress = 0;
    }
    
    // 2.给cell设置数据
    // 2.1.取出模型
    lrcModel *model = self.lrclist[indexPath.row];
    
    // 2.2.给cell设置数据
    cell.lrclabel.text = model.text;
    
    return cell;
}

#pragma mark - set
-(void)setLrcName:(NSString *)lrcName{
    // 0.重置保存的当前位置的下标
    self.currentIndex = 0;
    // 1.保存歌词名称
    _lrcName = [lrcName copy];
    // 2.解析歌词
    [self.lrclist removeAllObjects];
    [self.tableview reloadData];
    //先显示无歌词界面
    [self addSubview:self.noContentView];
    [MusicActionTools downloadMusicLrcWithName:lrcName WithBlock:^(NSArray *lrcArray) {
        if (lrcArray.count > 0) {
            self.lrclist = [NSMutableArray arrayWithArray:lrcArray];
            [self.tableview reloadData];
        }
        
        if (lrcArray.count > 0) {
            [self.noContentView removeFromSuperview];
        }else{
            //显示无内容界面
            [self addSubview:self.noContentView];
        }
    }];
}
-(void)setCurrentTime:(NSTimeInterval)currentTime{
    
    _currentTime = currentTime;
    // 用当前时间和歌词进行匹配
    NSInteger count = self.lrclist.count;
    for (int i = 0; i < count; i++) {
        // 1.拿到i位置的歌词
        lrcModel *currentLineModel = self.lrclist[i];
        
        // 2.拿到下一句的歌词
        NSInteger nextIndex = i + 1;
        lrcModel *nextLineModel = nil;
        if (nextIndex < count) {
            nextLineModel = self.lrclist[nextIndex];
        }
        
        // 3.用当前的时间和i位置的歌词比较,并且和下一句比较,如果大于i位置的时间,并且小于下一句歌词的时间,那么显示当前的歌词
        if (self.currentIndex != i && currentTime >= currentLineModel.time && currentTime < nextLineModel.time) {
            
            // 1.获取需要刷新的行号
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            // 2.记录当前i的行号
            self.currentIndex = i;

            // 3.设置上一行和这一行的样式
            lrcTableViewCell *currentCell = (lrcTableViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
            currentCell.lrclabel.font =[UIFont fontWithName:@"PingFangSC-Light" size:20];
            lrcTableViewCell *preCell = (lrcTableViewCell *)[self.tableview cellForRowAtIndexPath:previousIndexPath];
            preCell.lrclabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
            preCell.lrclabel.progress = 0;

            // 4.显示对应句的歌词
            [self.tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // 5.设置外面歌词的Label的显示歌词
//            self.lrclabel.text = currentLrcLine.text;
            
            // 6.生成锁屏界面的图片
//            [self generatorLockImage];
        }
        
        // 4.根据进度,显示label画多少
        if (self.currentIndex == i) {
            // 4.1.拿到i位置的cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            lrcTableViewCell *cell = (lrcTableViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
            
            // 4.2.更新label的进度
            CGFloat progress = (currentTime - currentLineModel.time) / (nextLineModel.time - currentLineModel.time);
            cell.lrclabel.progress = progress;
            
            // 4.3.设置外面歌词的Label的进度
//            self.lrcLabel.progress = progress;
        }
    }
}

-(UIView *)noContentView{
    if (_noContentView == nil) {
        _noContentView = [[UIView alloc] init];
        _noContentView.backgroundColor = kClearColor;
        _noContentView.frame = CGRectMake(ScreenWidth + (ScreenWidth-RealWidth(250))/2, (self.height-RealWidth(290))/2, RealWidth(250), RealWidth(290));
        __weak typeof(self) wself = self;
        
        UIImageView *image = [[UIImageView alloc] init];
        image.image = ImageNamed(@"收藏歌曲");
        image.frame = CGRectMake(0, 0, _noContentView.width, _noContentView.width);
        [_noContentView addSubview:image];
        image.userInteractionEnabled = YES;
        [image addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            NSString *name = wself.lrcName;
            wself.lrcName = name;
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无歌词";
        label.frame = CGRectMake(0, image.bottom+20, _noContentView.width, 20);
        label.backgroundColor = kClearColor;
        [_noContentView addSubview:label];
    }
    return _noContentView;
}

@end
