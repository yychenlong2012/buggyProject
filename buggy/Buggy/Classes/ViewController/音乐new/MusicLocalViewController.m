//
//  MusicLocalViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicLocalViewController.h"
#import "DYBaseNaviagtionController.h"
#import "MusicPlayNewController.h"
#import "DownLoadDataBase.h"
#import "MusicListModel.h"
#import "WNJsonModel.h"
#import "MusicItemListCell.h"
#import "MusicManager.h"
#import "MusicVehicleViewModel.h"
#import "NSString+AVLeanCloud.h"
#import "CLImageView.h"

#define MusicLikeCellHeight 52
@interface MusicLocalViewController ()
@property (nonatomic ,strong) NSMutableArray<musicModel *> *dataArray;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation MusicLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
//    [AYMessage showActiveViewOnView:self.view];
    [MUSICMANAGER addObserver:self forKeyPath:@"currentItemIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self requestDataOfPage:0];
}

- (void)dealloc{
    [MUSICMANAGER removeObserver:self forKeyPath:@"currentItemIndex"];
}

#pragma mark --- 添加观察者(currentIndex)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]]) {
        NSInteger indexPathRowNew = [change[NSKeyValueChangeNewKey] integerValue];
        NSInteger indexPathRowOld = [change[NSKeyValueChangeOldKey] integerValue];
        
        if (MUSICMANAGER.currentMusicType == kDownload) {
            NSIndexPath *indexNew = [NSIndexPath indexPathForRow:indexPathRowNew inSection:0];
            MusicItemListCell *musicCellNew = [self.tableView cellForRowAtIndexPath:indexNew];
            if (musicCellNew) {
                musicCellNew.selected = YES;
            }
            
            NSIndexPath *indexOld = [NSIndexPath indexPathForRow:indexPathRowOld inSection:0];
            MusicItemListCell *musicCellOld = [self.tableView cellForRowAtIndexPath:indexOld];
            if (musicCellOld) {
                musicCellOld.selected = NO;
            }
        }
    }
}

#pragma mark --- 数据源
//{
//    fileName = "";
//    musicId = 18010354;
//    musicImage = "http://192.168.10.106/Tp/Uploads/2018-11-21/d78e6ac2b3855b49ae78.png";
//    musicName = "\U94c1\U6775\U78e8\U9488";
//    musicUrl = "http://192.168.10.106/Tp/Uploads/2018-11-21/7ab4cc8833a6f26bc357.mp3";
//    orderDate = "http://192.168.10.106/Tp/Uploads/2018-11-21/7ab4cc8833a6f26bc357.mp3";
//    time = "02:15";
//}
- (void)requestDataOfPage:(NSInteger)page{
    __weak typeof(self) wself = self; 
    
    DownLoadDataBase *db = [[DownLoadDataBase alloc] init];
    [_dataArray removeAllObjects];
    NSArray *datas = [db selectAllDatas];
    for (NSDictionary *dic in datas) {
        musicModel *model = [[musicModel alloc] init];
        
        //歌曲 移除旧版本歌曲
        if (dic[@"musicUrl"] != nil && [dic[@"musicUrl"] isKindOfClass:[NSString class]]) {
            if ([dic[@"musicUrl"] hasPrefix:@"/var"]) {
                [db removeData:dic];
                continue;
            }
        }
        
        //歌曲url
        if ([dic[@"musicUrl"] isKindOfClass:[NSString class]] && [dic[@"musicUrl"] hasPrefix:@"http"]) {
            model.musicurl = dic[@"musicUrl"];
        }else{
            if ([dic[@"orderDate"] isKindOfClass:[NSString class]] && [dic[@"orderDate"] hasPrefix:@"http"]) {
                model.musicurl = dic[@"orderDate"];
            }
        }
        
        //id
        if ([dic[@"musicId"] isKindOfClass:[NSString class]]) {
            model.musicid = [dic[@"musicId"] integerValue];
        }
        
        //歌名
        if ([dic[@"musicName"] isKindOfClass:[NSString class]]) {
            model.musicname = dic[@"musicName"];
        }
        
        //时间
        if ([dic[@"time"] isKindOfClass:[NSString class]]) {
            model.time = dic[@"time"];
        }
        
        //图片
        if ([dic[@"musicImage"] isKindOfClass:[NSString class]] && [dic[@"musicImage"] hasPrefix:@"http"]) {
            model.imageurl = dic[@"musicImage"];
        }
    
        [_dataArray addObject:model];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_dataArray.count > 0) {
            [AYMessage hideNoContentTipView];
        }else{
            if (self->_dataArray.count == 0) {
                [AYMessage showNoContentTip:NSLocalizedString(@"为宝宝下载的歌曲\n都会放在这儿", nil) image:@"本地音乐_" onView:wself.tableView viewClick:^{
                      [wself requestDataOfPage:0];
                }];
            }
        }
       [AYMessage hideActiveView];
       [wself.tableView reloadData];
    });
    [self.tableView.mj_header endRefreshing];
}

#pragma mark --- 重写
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
    cell.model = _dataArray[indexPath.row];
    cell.index = (indexPath.row + 1);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [[MusicVehicleViewModel new] selectDeviceMode:self.deviceModel];
    
    [MUSICMANAGER.audioArray removeAllObjects];
    [MUSICMANAGER.audioArray addObjectsFromArray:self.dataArray];
    
    if (MUSICMANAGER.currentMusicType == kDownload) {   //是否正在播放收藏文件夹的歌曲
        //看是否同一行 且名字相同
        musicModel *model = self.dataArray[indexPath.row];
        if (MUSICMANAGER.currentItemIndex != indexPath.row || ![model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
            [MUSICMANAGER playItemAtIndex:indexPath.row];
        }
    }else{
        [MUSICMANAGER playItemAtIndex:indexPath.row];
    }
    MUSICMANAGER.currentMusicType = kDownload;
    
    MusicPlayNewController *player = [[MusicPlayNewController alloc] init];
    [self presentViewController:player animated:YES completion:nil];
}

// 判断是否划到最后一行
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if ([MainModel model].musicTypeNumber == MUSIC_TYPENUMBER_LOCAL) {
//
//        NSInteger playingNum = [BLEMusicPlayer shareManager].currentIndex;
//        NSIndexPath *indexPathMusic = [NSIndexPath indexPathForRow:playingNum inSection:0];
//        if (playingNum >=0 && indexPathMusic == indexPath) {
//            if ([BLEMusicPlayer shareManager].playing) {
//                cell.selected = YES;
//            }
//        }else{
//            cell.selected = NO;
//        }
//    }
}

- (UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self deleteDevice:indexPath];
        musicModel *model = _dataArray[indexPath.row];
        
        //删除磁盘中的文件
        NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [NSString cacheFolderPath], model.musicname];
        NSString * cacheFilePath2 = [NSString stringWithFormat:@"%@/%ld.mp3", [NSString cacheFolderPath], model.musicid];
        NSLog(@"检查该路径是否存在文件 = %@",cacheFilePath);
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:&error];
        }
        if (!error) {
            NSLog(@"删除成功");
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath2]) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath2 error:&error];
        }
        if (!error) {
            NSLog(@"删除成功");
        }
        
        //删除数据库中的记录
        DownLoadDataBase *db = [[DownLoadDataBase alloc] init];
        [db removeData:@{@"musicName":model.musicname}];
        
        [_dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

//刷新数据    父类调用
- (void)refrenshRequestData{
    [self requestDataOfPage:self.page];
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
        naviLabel.text = NSLocalizedString(@"下载列表", nil);
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
