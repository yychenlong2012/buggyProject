//
//  MusicListViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicListViewController.h"
#import "MusicInfoListView.h"
#import "MusicViewModel.h"
#import "DYBaseNaviagtionController.h"
#import "MusicVehicleViewModel.h"
#import "NetWorkStatus.h"
#import "NSString+AVLoader.h"
#import "MusicManager.h"
#import "MusicAlbumModel.h"
#import "MusicListModel.h"
#import "WNJsonModel.h"
#import "MusicItemListCell.h"
#import "MusicPlayNewController.h"
#import "CLImageView.h"
#import "FloatTools.h"

@interface MusicListViewController ()<MusicInfoListViewDelegate,MusicInfoListViewDataDelegate>
@property (nonatomic ,strong) MusicInfoListView *listView;     
@property (nonatomic ,strong) NSMutableArray<musicModel *> *dataArray; //音源数组
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UILabel *naviTitle;
@property (nonatomic,strong) CLImageView *naviBackImage;
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation MusicListViewController
- (void)dealloc{
    [MUSICMANAGER removeObserver:self forKeyPath:@"currentItemIndex"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = 1;
    [self.view addSubview:self.listView];      //列表界面
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.naviBackImage];
    self.dataArray = [NSMutableArray array];
   
    if (self.model != nil && [self.model isKindOfClass:[MusicAlbumModel class]]) {
        self.listView.topModel = self.model;
        self.naviTitle.text = self.model.title;//导航栏数据
        [self requestMusiclist:self.currentPage];
    }
    
    [MUSICMANAGER addObserver:self forKeyPath:@"currentItemIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    __weak typeof(self) wself = self;
    self.listView.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (self.currentPage > 0) {
            self.currentPage++;
            [wself requestMusiclist:self.currentPage];
        }else{
            [wself.listView.tableView.mj_footer endRefreshing];
        }
    }];
}

//请求歌曲列表
-(void)requestMusiclist:(NSInteger)page{
    [NETWorkAPI requestAlbumMusicPage:[NSString stringWithFormat:@"%ld",page] pageNum:@"30" musicType:self.model.musictype album:self.model.albumaddress callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        [self.listView.tableView.mj_footer endRefreshing];
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            [AYMessage hideNoContentTipView];   //隐藏无内容提示试图
            [self.dataArray addObjectsFromArray:modelArray];
            //刷新
            [self.listView.tableView reloadData];
        }
        
        if (self.dataArray.count == 0) {
            [AYMessage showNoContentTip:NSLocalizedString(@"暂时与母星失去联系", nil) image:@"无网络" onView:self->_listView.tableView viewClick:^{
                [self requestMusiclist:self.currentPage];
            }];
        }
        
        if (currentPage >= 0 && currentPage < 10000) {
            self.currentPage = currentPage;
        }
    }];
}


//KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]]) {
        
        NSInteger indexPathRowNew = [change[NSKeyValueChangeNewKey] integerValue]; //将要播放的歌曲下标
        NSInteger indexPathRowOld = [change[NSKeyValueChangeOldKey] integerValue]; //上一首歌曲的下标
    
        //控制cell的选中状态
        if (MUSICMANAGER.currentMusicType == self.musicType) {
            if (indexPathRowOld < self.dataArray.count) {
                musicModel *model = self.dataArray[indexPathRowOld];
                if ([model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
                    NSIndexPath *indexNew = [NSIndexPath indexPathForRow:indexPathRowNew inSection:0];
                    MusicItemListCell *musicCellNew = [self.listView.tableView cellForRowAtIndexPath:indexNew];
                    if (musicCellNew) {
                        musicCellNew.selected = YES;
                    }
                    
                    NSIndexPath *indexOld = [NSIndexPath indexPathForRow:indexPathRowOld inSection:0];
                    MusicItemListCell *musicCellOld = [self.listView.tableView cellForRowAtIndexPath:indexOld];
                    if (musicCellOld) {
                        musicCellOld.selected = NO;
                    }
                }
            }
        }
    }
}
    
#pragma mark - MusicInfoListViewDataDelegate
- (NSInteger)musicNumberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)musicTableviewCell:(UITableViewCell *)tableViewCell musicCellForRowAtIndexPath:(NSIndexPath *)indexPath musicIdentifiler:(NSString *)musicIdentifiler{
   
    if (!tableViewCell) {
        tableViewCell = [[MusicItemListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:musicIdentifiler];
    }
    MusicItemListCell *cell = (MusicItemListCell *)tableViewCell;
    if (indexPath.row < self.dataArray.count) {
        cell.model = _dataArray[indexPath.row];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (MUSICMANAGER.currentItemIndex == indexPath.row) {
            if (MUSICMANAGER.currentMusicType == self.musicType) {   //防止不在同一个界面
                if (MUSICMANAGER.currentItemIndex < self.dataArray.count) {
                    musicModel *model = self.dataArray[MUSICMANAGER.currentItemIndex];
                    if ([model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
                        cell.selected = YES;
                    }
                }
            }
            if (MUSICMANAGER.currentItemIndex == 0) {   //防止页面刚进入时第一行cell为选中状态
                if ([FloatTools manager].isShowing == NO) {
                    cell.selected = NO;
                }
            }
        }else{
            cell.selected = NO;
        }
    });
    
    cell.index = indexPath.row + 1;
    return cell;
}


#pragma mark - MusicInfoListViewDelegate
//点击播放音乐
- (void)musicDidSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
//    [[MusicVehicleViewModel new] selectDeviceMode:self.deviceModel];
    
    [MUSICMANAGER.audioArray removeAllObjects];
    [MUSICMANAGER.audioArray addObjectsFromArray:self.dataArray];
    
    if (MUSICMANAGER.currentMusicType == kAlbum) {   //是否正在播放收藏文件夹的歌曲
        //看是否同一行 且名字相同
        musicModel *model = self.dataArray[indexPath.row];
        if (MUSICMANAGER.currentItemIndex != indexPath.row || ![model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
            [MUSICMANAGER playItemAtIndex:indexPath.row];
        }
    }else{
        [MUSICMANAGER playItemAtIndex:indexPath.row];
    }
    MUSICMANAGER.currentMusicType = kAlbum;
    
    MusicPlayNewController *player = [[MusicPlayNewController alloc] init];
    [self.navigationController pushViewController:player animated:YES];
}

- (void)musicwillDisplayCellForRowAtIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView{
    
//    NSInteger row = indexPath.row;
//    NSInteger section = indexPath.section;
//    if (row < 0|| section<0) {
//        return;
//    }
//    NSInteger sectionRow = [tableView numberOfRowsInSection:section];
//    if ((sectionRow -1) == row && !_isPullup) {
//        _isPullup = YES;
//         _pullUpNumber ++;
//        [self requestDataOfPage:_pullUpNumber];
//    }
}

-(void)scrollDidScroll:(CGFloat)offsetY{

    if (offsetY <= 0) {
        self.naviView.alpha = 0;
    }else if (offsetY >= 200){
        self.naviView.alpha = 1;
    }else{
        self.naviView.alpha = offsetY/200.0;
    }
}

#pragma mark - lazy
-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.backgroundColor = kWhiteColor;
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, navigationH);
        _naviView.alpha = 0;
        
        [_naviView addSubview:self.naviTitle];
        
        UIView *line = [[UIView alloc] init];
        line.frame = CGRectMake(0, 0, ScreenWidth, 1);
        line.bottom = _naviView.height+1;
        line.backgroundColor = kWhiteColor;
        line.layer.shadowRadius = 1;
        line.layer.shadowOpacity = 0.4;
        line.layer.shadowOffset = CGSizeMake(0, 2);
        line.layer.shadowColor = kBlackColor.CGColor;
        [_naviView addSubview:line];
    }
    return _naviView;
}

-(UILabel *)naviTitle{
    if (_naviTitle == nil) {
        _naviTitle = [[UILabel alloc] init];
        _naviTitle.textColor = kBlackColor;
        _naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _naviTitle.text = @"";
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
    }
    return _naviTitle;
}

-(CLImageView *)naviBackImage{
    if (_naviBackImage == nil) {
        _naviBackImage = [[CLImageView alloc] init];
        _naviBackImage.image = [UIImage imageNamed:@"navi_back_icon"];
        _naviBackImage.frame = CGRectMake(15, 13+statusBarH, 18, 18);
        _naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _naviBackImage;
}

- (MusicInfoListView *)listView{
    if (_listView == nil) {
        _listView = [[MusicInfoListView alloc] initWithFrame:self.view.bounds];
        _listView.dataSource = self;
        _listView.delegate = self;
    }
    return _listView;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [AVFile clearAllCachedFiles];
    
    //清除音乐缓存  直接移除文件夹  不需要单个移除
    //    NSError *error;
    //    [[NSFileManager defaultManager] removeItemAtPath:[NSString cacheFolderPath] error:&error];
    [MUSICMANAGER clearMusicCache];   //清空音乐缓存
}

@end
