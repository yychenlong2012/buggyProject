//
//  MusicSpecialListController.m
//  Buggy
//
//  Created by goat on 2018/4/12.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicSpecialListController.h"
#import "MusicItemListCell.h"
#import "CLImageView.h"
#import "MYLabel.h"
#import "AYMessage.h"
#import "MusicListModel.h"
#import "WNJsonModel.h"
#import "MusicManager.h"
#import "MusicVehicleViewModel.h"
#import "MusicPlayNewController.h"
#import "FloatTools.h"

@interface MusicSpecialListController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic,strong) UIImageView *naviBackImage;   //导航栏返回按钮
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *header;               //tableHeaderView
@property (nonatomic,strong) NSMutableArray *dataArray;  
@property (nonatomic,strong) NSArray *colorAndImageArray;   //渐变颜色
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation MusicSpecialListController    //专题列表
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPage = 1;
    self.dataArray = [NSMutableArray array];
    [MUSICMANAGER addObserver:self forKeyPath:@"currentItemIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.naviBackImage];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self requestMusicList:self.currentPage];
}


//请求歌曲列表
-(void)requestMusicList:(NSInteger)page{
    [NETWorkAPI requestSceneMusicPage:[NSString stringWithFormat:@"%ld",page] pageNum:@"30" musicType:self.musicType-3 callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            [self.dataArray addObjectsFromArray:modelArray];
            [self.tableView reloadData];
        }
        
        if (currentPage >= 0 && currentPage < 10000) {
            self.currentPage = currentPage;
        }
    }];
}

-(void)dealloc{
    [MUSICMANAGER removeObserver:self forKeyPath:@"currentItemIndex"];
}

//KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]]) {

        NSInteger indexPathRowNew = [change[NSKeyValueChangeNewKey] integerValue]; //将要播放的歌曲下标
        NSInteger indexPathRowOld = [change[NSKeyValueChangeOldKey] integerValue]; //上一首歌曲的下标
        
        //控制cell的选中状态
        if (MUSICMANAGER.currentMusicType == self.musicType) {
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
#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count > 0) {  //有数据
        return self.dataArray.count;
    }else{
        return 1;   //显示空白
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return RealWidth(282)+4;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{return 0;}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArray.count > 0) {  //有数据
        return MusicListCellHeight;
    }else{
        return ScreenHeight-RealWidth(282)-4-bottomSafeH;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArray.count > 0) {  //有数据
        MusicItemListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[MusicItemListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < self.dataArray.count) {
            musicModel *model = _dataArray[indexPath.row];
            cell.model = model;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (MUSICMANAGER.currentItemIndex == indexPath.row) {
                if (MUSICMANAGER.currentMusicType == self.musicType) {   //防止不在同一个界面
                    cell.selected = YES;
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
    }else{
        //空白占位
        UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"empty"];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageV = [[UIImageView alloc] init];
        [emptyCell.contentView addSubview:imageV];
        imageV.frame = CGRectMake(0, 100, RealWidth(250), RealWidth(250));
        imageV.center = CGPointMake(ScreenWidth/2, (ScreenHeight-RealWidth(282)-4-bottomSafeH)/2);
        imageV.image = ImageNamed(@"无网络");
    
        return emptyCell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArray.count == 0) {
        [self requestMusicList:self.currentPage];
    }else{
//        [[MusicVehicleViewModel new] selectDeviceMode:self.deviceModel];
        
        [MUSICMANAGER.audioArray removeAllObjects];
        [MUSICMANAGER.audioArray addObjectsFromArray:self.dataArray];
        
        if (MUSICMANAGER.currentMusicType == self.musicType) {   //是否正在播放收藏文件夹的歌曲
            //看是否同一行 且名字相同
            musicModel *model = self.dataArray[indexPath.row];
            if (MUSICMANAGER.currentItemIndex != indexPath.row || ![model.musicname isEqualToString:MUSICMANAGER.currntMusicName]) {
                [MUSICMANAGER playItemAtIndex:indexPath.row];
            }
        }else{
            [MUSICMANAGER playItemAtIndex:indexPath.row];
        }
        MUSICMANAGER.currentMusicType = self.musicType;
        
        MusicPlayNewController *player = [[MusicPlayNewController alloc] init];
        [self.navigationController pushViewController:player animated:YES];
    }
}

#pragma mark - scrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        self.naviView.alpha = 0.0;
    }else{
        if (offsetY >= 200) {
            self.naviView.alpha = 1.0;
        }else{
            self.naviView.alpha = offsetY/200;
        }
    }
}

#pragma mark - lazy
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-bottomSafeH) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
//        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        __weak typeof(self) wself = self;
        [_tableView addSwipeGestureRecognizer:^(UISwipeGestureRecognizer *recognizer, NSString *gestureId) {
            [wself dismissViewControllerAnimated:YES completion:nil];
        } direction:UISwipeGestureRecognizerDirectionRight];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            if (wself.currentPage > 0) {
                wself.currentPage++;
                [wself requestMusicList:wself.currentPage];
            }else{
                [wself.tableView.mj_footer endRefreshing];
            }
        }];
    }
    return _tableView;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        NSDictionary *dict = self.colorAndImageArray[self.musicType-4];
        
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:dict[@"bottom"]];
        _naviView.alpha = 0.0;
        
        //毛玻璃
//        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//        effectView.frame = _naviView.bounds;
//        [_naviView addSubview:effectView];
        
        UILabel *naviTitle = [[UILabel alloc] init];
//        naviTitle.textColor = [UIColor colorWithHexString:@"#172058"];
        naviTitle.textColor = kWhiteColor;
        naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviTitle.text = dict[@"title"];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviTitle];
    }
    return _naviView;
}

-(UIImageView *)naviBackImage{
    if (_naviBackImage == nil) {
        _naviBackImage = [[CLImageView alloc] init];
        _naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        _naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        _naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _naviBackImage;
}

-(NSArray *)colorAndImageArray{
    if (_colorAndImageArray == nil) {
        _colorAndImageArray = @[   //@{@"top":@"#FBABB7",@"bottom":@"#F3667A",@"image":NSLocalizedString(@"羊水音", nil)},    //羊水音
                                @{@"top":@"#FCCD92",@"bottom":@"#F07D4D",@"image":@"哄睡",@"title":NSLocalizedString(@"哄睡", nil),@"tips":@"科学的方式，让宝宝在奇妙的声音中进入甜蜜梦乡，宝宝睡得安心，妈妈才更放心"},     //哄睡
                                 @{@"top":@"#5CE2BF",@"bottom":@"#15B783",@"image":@"安抚",@"title":NSLocalizedString(@"安抚", nil),@"tips":@"为宝宝提供优质的安抚旋律，从而促进宝宝脑部听觉的发育"},     //安抚
                                 @{@"top":@"#92BCFC",@"bottom":@"#4D7CF0",@"image":@"儿歌",@"title":NSLocalizedString(@"儿歌", nil),@"tips":@"没有儿歌的童年是不完整的，儿歌能唤起回忆，也能增添乐趣"},     //儿歌
                                 @{@"top":@"#E39FF9",@"bottom":@"#BB51E9",@"image":@"故事",@"title":NSLocalizedString(@"故事", nil),@"tips":@"简单的故事，易懂的道理，让故事陪伴孩子健康的成长"}  ];  //故事
    }
    return _colorAndImageArray;
}

-(UIView *)header{
    if (_header == nil) {
        _header = [[UIView alloc] init];
        _header.backgroundColor = kWhiteColor;
        _header.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(282));
        //渐变色
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.frame = _header.bounds;
        NSDictionary *dict = self.colorAndImageArray[self.musicType-4];
        layer.colors = @[(__bridge id)[UIColor colorWithHexString:dict[@"top"]].CGColor,(__bridge id)[UIColor colorWithHexString:dict[@"bottom"]].CGColor];
        //渐变区间
        layer.locations = @[@0.0,@1.0];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(1, 1);
        [_header.layer addSublayer:layer];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-big",dict[@"image"]]];
        imageView.frame = CGRectMake(ScreenWidth-RealWidth(155), RealWidth(59), RealWidth(155), RealWidth(198));
        [_header addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:35];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = dict[@"title"];
        label.textColor = kWhiteColor;
        label.frame = CGRectMake(RealWidth([UIScreen mainScreen].bounds.size.width==320?70:86), RealWidth(99), 150, 35);
        [_header addSubview:label];
        
        MYLabel *tips = [[MYLabel alloc] init];
        tips.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        tips.textAlignment = NSTextAlignmentLeft;
        tips.verticalAlignment = VerticalAlignmentTop;
        tips.textColor = kWhiteColor;
        tips.numberOfLines = 0;
        tips.text = dict[@"tips"];
        tips.frame = CGRectMake(RealWidth(40), label.bottom+14, imageView.left-50, _header.height-label.bottom-14);
        [_header addSubview:tips];
        
        UIView *line = [[UIView alloc] init];
        line.frame = CGRectMake(0, RealWidth(282), ScreenWidth, 4);
        line.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
        [_header addSubview:line];
    }
    return _header;
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
//隐藏状态栏
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

@end
