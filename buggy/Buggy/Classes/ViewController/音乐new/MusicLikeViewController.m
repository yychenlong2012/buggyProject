//
//  MusicLikeViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/22.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicLikeViewController.h"
#import "MusicLikeViewModel.h"
#import "MusicPlayNewController.h"
#import "DYBaseNaviagtionController.h"
#import "MusicItemListCell.h"
#import "MusicVehicleViewModel.h"
#import "MusicManager.h"
#import "CLImageView.h"

#define MusicLikeCellHeight 52
@interface MusicLikeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) NSMutableArray<musicModel *> *dataArray;
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
/**
 是否正在上拉
 */
@property (nonatomic) BOOL isPullup;
 @property (nonatomic) NSInteger pullUpNumber; // 上提加载的次数
@end

@implementation MusicLikeViewController

- (void)dealloc{
    [MUSICMANAGER removeObserver:self forKeyPath:@"currentItemIndex"];
}

- (void)viewDidLoad {
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    [AYMessage showActiveViewOnView:self.view];
    self.title = NSLocalizedString(@"宝宝喜欢", nil);
    [self refrenshRequestData];
    [MUSICMANAGER addObserver:self forKeyPath:@"currentItemIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark --- Observer 检测当前的索引
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]]) {
        
        NSInteger indexPathRowNew = [change[NSKeyValueChangeNewKey] integerValue];
        NSInteger indexPathRowOld = [change[NSKeyValueChangeOldKey] integerValue];
        
        if (MUSICMANAGER.currentMusicType == kLike) {
            NSIndexPath *indexNew = [NSIndexPath indexPathForRow:indexPathRowNew inSection:0];    //选中新选行
            MusicItemListCell *musicCellNew = [self.tableView cellForRowAtIndexPath:indexNew];
            if (musicCellNew) {
                musicCellNew.selected = YES;
            }
            
            NSIndexPath *indexOld = [NSIndexPath indexPathForRow:indexPathRowOld inSection:0];     //取消上一行
            MusicItemListCell *musicCellOld = [self.tableView cellForRowAtIndexPath:indexOld];
            if (musicCellOld) {
                musicCellOld.selected = NO;
            }
        }
    }
}
 
#pragma mark --- Data
- (void)requestDataOfPage:(NSInteger)page{
    __weak typeof(self) wself = self;
    if (page == 0) {
        return;
    }
    [MusicLikeViewModel getLikelWithPage:page List:^(NSArray *datas, NSError *error) {
       if (error.code == 0 && datas) {
                [AYMessage hideNoContentTipView];
          [self->_dataArray addObjectsFromArray:datas];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [wself.tableView reloadData];
                     wself.isPullup = false;
                   //  [wself requestDataOfPage:page];
                 });
          if (self->_dataArray.count == 0) {
              [AYMessage showNoContentTip:[NSString stringWithFormat:NSLocalizedString(@"为宝宝收藏的歌曲\n都会放在这儿", nil)] image:@"收藏歌曲" onView:self.tableView viewClick:^{
                  //  [wself refrenshRequestData];
              }];
          }
         }
        [AYMessage hideActiveView];
    }];
     [self.tableView.mj_header endRefreshing];
}

- (void)refrenshRequestData{
    [_dataArray removeAllObjects];
    __weak typeof(self) wself = self;
    [MusicLikeViewModel getLikelWithPage:0 List:^(NSArray *datas, NSError *error) {
        if (error.code == 0 && datas) {
            [AYMessage hideNoContentTipView];
            self->_dataArray = (NSMutableArray *)datas;
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.tableView reloadData];
                wself.isPullup = YES;
              //  [wself refrenshRequestData];
            });
            if (self->_dataArray.count == 0) {
                [AYMessage showNoContentTip:[NSString stringWithFormat:NSLocalizedString(@"为宝宝收藏的歌曲\n都会放在这儿", nil)] image:@"收藏歌曲" onView:self.tableView viewClick:^{
                    //  [wself refrenshRequestData];
                }];
            }
        }
        [self.tableView.mj_header endRefreshing];
        [AYMessage hideActiveView];
    }];
    
}

#pragma mark --- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MusicLikeCellHeight;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    MusicItemListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MusicItemListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_dataArray.count != 0) {
        cell.model = _dataArray[indexPath.row];
    }
    cell.index = indexPath.row + 1;
    return cell;
}
 
#pragma mark --- 处理cell被选中的动画状态
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [[MusicVehicleViewModel new] selectDeviceMode:self.deviceModel];
    [MUSICMANAGER.audioArray removeAllObjects];
    [MUSICMANAGER.audioArray addObjectsFromArray:self.dataArray];
    if (MUSICMANAGER.currentMusicType == kLike) {   //是否正在播放收藏文件夹的歌曲
        //看是否同一行 且名字相同
        musicModel *model = self.dataArray[indexPath.row];
        if (MUSICMANAGER.currentItemIndex != indexPath.row || ![model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
            [MUSICMANAGER playItemAtIndex:indexPath.row];
        }
    }else{
        [MUSICMANAGER playItemAtIndex:indexPath.row];
    }
    MUSICMANAGER.currentMusicType = kLike;
    MusicPlayNewController *player = [[MusicPlayNewController alloc] init];
    [self presentViewController:player animated:YES completion:nil];
}

- (void)musicwillDisplayCellForRowAtIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (row < 0|| section<0) {
        return;
    }
    NSInteger sectionRow = [tableView numberOfRowsInSection:section];
    if ((sectionRow -1) == row && !_isPullup) {
        _isPullup = YES;
        _pullUpNumber ++;
        [self requestDataOfPage:_pullUpNumber];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController?49:0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [_naviView addSubview:naviBackImage];
        
        UILabel *naviLabel = [[UILabel alloc] init];
        naviLabel.textColor = kWhiteColor;
        naviLabel.text = NSLocalizedString(@"宝宝喜欢", nil);
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
    }
    return _naviView;
}

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
@end
