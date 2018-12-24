//
//  MusicTotalListController.m
//  Buggy
//
//  Created by goat on 2018/4/10.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicTotalListController.h"
#import "MusicListCollectionCell.h"
#import "CLLabel.h"
#import "CLImageView.h"
#import "MusicAlbumModel.h"
#import "WNJsonModel.h"
#import "MusicListViewController.h"
#import <SDImageCacheConfig.h>

static BOOL SDImageCacheOldShouldDecompressImages = YES;
static BOOL SDImagedownloderOldShouldDecompressImages = YES;

@interface MusicTotalListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching>
@property (nonatomic,strong) UICollectionView *collection;
@property (nonatomic,strong) UIView *popView;      //点击按钮弹出的标签背景界面
@property (nonatomic,strong) UIView *btnBGView;
@property (nonatomic,strong) UIButton *hot;
@property (nonatomic,strong) UIButton *category;
@property (nonatomic,strong) UIView *hotView;      //热度标签框
@property (nonatomic,strong) UIView *categoryView; //类别标签框
@property (nonatomic,strong) NSMutableArray *albumArray;   //专辑数据
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation MusicTotalListController   //全部歌单
-(void)loadView{
    [super loadView];
    
    //禁用sdwebimage的解压缩
    SDImageCache *canche = [SDImageCache sharedImageCache];
    SDImageCacheOldShouldDecompressImages = canche.config.shouldDecompressImages;
    canche.config.shouldDecompressImages = NO;
    
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    SDImagedownloderOldShouldDecompressImages = downloder.shouldDecompressImages;
    downloder.shouldDecompressImages = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumArray = [NSMutableArray array];
    
    self.currentPage = 1;
    [self setupUI];
    
    [self requestAlbumListWithPage:self.currentPage];
}

-(void)dealloc{
    //恢复默认设置
    SDImageCache *canche = [SDImageCache sharedImageCache];
    canche.config.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;
    
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
}

-(void)requestAlbumListWithPage:(NSInteger)page{
    [NETWorkAPI requestAllMusicPage:[NSString stringWithFormat:@"%ld",page] pageNum:@"30" callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        [self.collection.mj_footer endRefreshing];
        if ([modelArray isKindOfClass:[NSArray class]] && modelArray.count>0) {
            //刷新组
            [self.albumArray addObjectsFromArray:modelArray];
            [self.collection reloadData];
        }
        
        if (currentPage >= 0 && currentPage < 10000) {
            self.currentPage = currentPage;
        }
    }];
    

//        [AYMessage hideNoContentTipView];   //隐藏无内容提示试图

//            [AYMessage showNoContentTip:NSLocalizedString(@"暂时与母星失去联系", nil) image:@"无网络" onView:self.collection viewClick:^{
//                [self requestAlbumListWithPage:1];
//            }];
}


-(void)setupUI{
    //导航栏
    UIView *navi = [[UIView alloc] init];
    navi.backgroundColor = kWhiteColor;
    navi.frame = CGRectMake(0, statusBarH, ScreenWidth, 44);
    [self.view addSubview:navi];
    
    CLImageView *imageV = [[CLImageView alloc] init];
    imageV.image = [UIImage imageNamed:@"navi_back_icon"];
    imageV.frame = CGRectMake(15, 12, 20, 20);
    imageV.userInteractionEnabled = YES;
    __weak typeof(self) wself = self;
    [imageV addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [wself.navigationController popViewControllerAnimated:YES];
    }];
    [navi addSubview:imageV];
    
    UILabel *naviTitle = [[UILabel alloc] init];
    naviTitle.text = NSLocalizedString(@"所有歌单", nil);
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
    naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13, 200, 18);
    [navi addSubview:naviTitle];
    
//    UIView *lineOne = [[UIView alloc] init];
//    lineOne.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
//    lineOne.frame = CGRectMake(0, 43, ScreenWidth, 1);
//    [navi addSubview:lineOne];
    
    self.btnBGView = [[UIView alloc] initWithFrame:CGRectMake(0, navi.bottom, ScreenWidth, 1)];  //高度35
    self.btnBGView.backgroundColor = kWhiteColor;
    [self.view addSubview:self.btnBGView];
    //热度
    self.hot = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, 35)];
    [self.hot setTitle:NSLocalizedString(@"热度", nil) forState:UIControlStateNormal];
    self.hot.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [self.hot setTitleColor:kBlackColor forState:UIControlStateNormal];
    [self.hot setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
    [self.hot setImageEdgeInsets:UIEdgeInsetsMake(0.0, 69, 0.0, 0.0)];
    [self.hot setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [self.hot addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSData *imageData1 = UIImagePNGRepresentation([wself.hot imageForState:UIControlStateNormal]);
        NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"下拉icon"]);
        if ([imageData1 isEqualToData:imageData2]) {
            [wself.hot setImage:[UIImage imageNamed:@"下拉icon向上"] forState:UIControlStateNormal];
            [wself.hot setTitleColor:[UIColor colorWithHexString:@"#E04E63"] forState:UIControlStateNormal];
            [wself.popView addSubview:wself.hotView];
            [wself.categoryView removeFromSuperview];
            [UIView animateWithDuration:0.25 animations:^{
                wself.popView.frame = CGRectMake(0, wself.btnBGView.bottom, ScreenWidth, wself.collection.height);
            }];
            [wself.category setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.category setTitleColor:kBlackColor forState:UIControlStateNormal];
        }else{
            [wself.hot setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.hot setTitleColor:kBlackColor forState:UIControlStateNormal];
            [wself.hotView removeFromSuperview];
            [UIView animateWithDuration:0.25 animations:^{
                wself.popView.frame = CGRectMake(0, wself.btnBGView.bottom, ScreenWidth, 0);
            }];
        }
    }];
//    [self.btnBGView addSubview:self.hot];
    //类别
    self.category = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, 35)];
    [self.category setTitle:NSLocalizedString(@"类别", nil) forState:UIControlStateNormal];
    self.category.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [self.category setTitleColor:kBlackColor forState:UIControlStateNormal];
    [self.category setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
    [self.category setImageEdgeInsets:UIEdgeInsetsMake(0.0, 69, 0.0, 0.0)];
    [self.category setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    self.category.userInteractionEnabled = YES;
    [self.category addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSData *imageData1 = UIImagePNGRepresentation([wself.category imageForState:UIControlStateNormal]);
        NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"下拉icon"]);
        if ([imageData1 isEqualToData:imageData2]) {
            [wself.category setImage:[UIImage imageNamed:@"下拉icon向上"] forState:UIControlStateNormal];
            [wself.category setTitleColor:[UIColor colorWithHexString:@"#E04E63"] forState:UIControlStateNormal];
            [wself.popView addSubview:wself.categoryView];
            [wself.hotView removeFromSuperview];
            [UIView animateWithDuration:0.25 animations:^{
                wself.popView.frame = CGRectMake(0, wself.btnBGView.bottom, ScreenWidth, wself.collection.height);
            }];
            [wself.hot setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.hot setTitleColor:kBlackColor forState:UIControlStateNormal];
        }else{
            [wself.category setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.category setTitleColor:kBlackColor forState:UIControlStateNormal];
            [wself.categoryView removeFromSuperview];
            [UIView animateWithDuration:0.25 animations:^{
                wself.popView.frame = CGRectMake(0, wself.btnBGView.bottom, ScreenWidth, 0);
            }];
        }
    }];
//    [self.btnBGView addSubview:self.category];
    
    UIView *linetwo = [[UIView alloc] init];
    linetwo.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
    linetwo.frame = CGRectMake(0, 34.5, ScreenWidth, 0.5);
//    [self.btnBGView addSubview:linetwo];
    
    //列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat w = [UIScreen mainScreen].bounds.size.width == 320?155:160;
    layout.itemSize = CGSizeMake(RealWidth(w), RealWidth(w)+9+15+10);
    layout.minimumLineSpacing = 25;
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.btnBGView.bottom, ScreenWidth, ScreenHeight-navigationH-self.btnBGView.height) collectionViewLayout:layout];
    self.collection.backgroundColor = kWhiteColor;
    self.collection.delegate = self;
    if ([UIDevice currentDevice].systemVersion.boolValue >= 10.0) {
        self.collection.prefetchDataSource = self;
    }
    self.collection.dataSource = self;
    self.collection.showsHorizontalScrollIndicator = NO;
    self.collection.contentInset = UIEdgeInsetsMake(20, 20, 10, 20);
    self.collection.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (wself.currentPage > 0) {
            wself.currentPage++;
            [wself requestAlbumListWithPage:wself.currentPage];
        }else{
            [wself.collection.mj_footer endRefreshing];
        }
    }];
    [self.view addSubview:self.collection];
    [self.collection registerClass:[MusicListCollectionCell class] forCellWithReuseIdentifier:@"cell"];
//    [self.collection addSubview:self.popView];
    [self.view addSubview:self.popView];
//    [self.view insertSubview:self.popView belowSubview:btnBGView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.albumArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12.5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MusicListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageview.image = nil;
    cell.label.text =@"";
    if (indexPath.row < self.albumArray.count) {
        MusicAlbumModel *model = self.albumArray[indexPath.row];
        
        if ([model.imageface isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:model.imageface];
            if (url) {
                [cell.imageview sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
//                [cell.imageview sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图") options:SDWebImageProgressiveDownload|SDWebImageLowPriority];
            }
        }
        
        if (model.title != nil && [model.title isKindOfClass:[NSString class]]) {
            cell.label.text = model.title;
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.albumArray.count) {
        MusicListViewController *vc = [[MusicListViewController alloc] init];
        vc.musicType = kAlbum;
        vc.model = self.albumArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - lazy
- (UIView *)popView{
    if (_popView == nil) {
        _popView = [[UIView alloc] init];
        _popView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _popView.frame = CGRectMake(0, self.btnBGView.bottom, ScreenWidth, 0);
        _popView.userInteractionEnabled = YES;
        __weak typeof(_popView) weakPopview = _popView;
        __weak typeof(self) wself = self;
        [_popView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakPopview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [wself.hot setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.hot setTitleColor:kBlackColor forState:UIControlStateNormal];
            [wself.category setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
            [wself.category setTitleColor:kBlackColor forState:UIControlStateNormal];
            [UIView animateWithDuration:0.25 animations:^{
                weakPopview.frame = CGRectMake(0, wself.btnBGView.bottom, ScreenWidth, 0);
            }];
        }];
    }
    return _popView;
}

-(UIView *)hotView{
    if (_hotView == nil) {
        _hotView = [[UIView alloc] init];
        _hotView.backgroundColor = kWhiteColor;
        _hotView.frame = CGRectMake(0, 0, ScreenWidth, 78);
        
        UIButton *new = [[UIButton alloc] init];
        [new setTitle:NSLocalizedString(@"最新上架", nil) forState:UIControlStateNormal];
        [new setTitleColor:kBlackColor forState:UIControlStateNormal];
        new.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        [new setImage:[UIImage imageNamed:@"选中 copy"] forState:UIControlStateNormal];
        new.frame = CGRectMake(0, 0, 130, 39);
        [new setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
        [_hotView addSubview:new];
        
        UIButton *welcome = [[UIButton alloc] init];
        [welcome setTitle:NSLocalizedString(@"最受欢迎", nil) forState:UIControlStateNormal];
        [welcome setTitleColor:kBlackColor forState:UIControlStateNormal];
        welcome.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        [welcome setImage:[UIImage imageNamed:@"选中 copy"] forState:UIControlStateNormal];
        welcome.frame = CGRectMake(0, 39, 130, 39);
        [welcome setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
        [_hotView addSubview:welcome];
        
        __weak typeof(welcome) weakWelcome = welcome;
        __weak typeof(new) weakNew = new;
        [new addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([[weakNew titleColorForState:UIControlStateNormal] isEqual:kBlackColor]) {
                [weakNew setTitleColor:[UIColor colorWithHexString:@"#E04E63"] forState:UIControlStateNormal];
                [weakNew setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
                
                [weakWelcome setImage:[UIImage imageNamed:@"选中 copy"] forState:UIControlStateNormal];
                [weakWelcome setTitleColor:kBlackColor forState:UIControlStateNormal];
            }
        }];
        
        [welcome addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([[weakWelcome titleColorForState:UIControlStateNormal] isEqual:kBlackColor]) {
                [weakWelcome setTitleColor:[UIColor colorWithHexString:@"#E04E63"] forState:UIControlStateNormal];
                [weakWelcome setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
                
                [weakNew setImage:[UIImage imageNamed:@"选中 copy"] forState:UIControlStateNormal];
                [weakNew setTitleColor:kBlackColor forState:UIControlStateNormal];
            }
        }];
    }
    return _hotView;
}

-(UIView *)categoryView{
    if (_categoryView == nil) {
        _categoryView = [[UIView alloc] init];
        _categoryView.backgroundColor = kWhiteColor;
        _categoryView.frame = CGRectMake(0, 0, ScreenWidth, 117);
        
        CGFloat margin = (ScreenWidth-4*53 - 60)/3;
        NSInteger col = 4;  //列数
        NSArray *titleArray = @[@"科普",@"古典",@"练耳",@"英语",@"科普",@"古典",@"练耳",@"英语"];
        for (NSInteger i = 0; i < titleArray.count; i++) {
            CLLabel *label = [[CLLabel alloc] init];
            label.extraWidth = 10;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            label.text = titleArray[i];
            label.frame = CGRectMake(i%col * (53+margin) + 30, i/col*(25 + 20) + 22, 53, 25);
            label.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
            label.userInteractionEnabled = YES;
            label.textColor = [UIColor colorWithHexString:@"#999999"];
            __weak typeof(label) weakLabel = label;
            [label addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                if (![weakLabel.textColor isEqual:kWhiteColor]) {
                    weakLabel.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
                    weakLabel.textColor = kWhiteColor;
                }else{
                    weakLabel.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
                    weakLabel.textColor = [UIColor colorWithHexString:@"#999999"];
                }
            }];
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:label.bounds cornerRadius:6];
            layer.path = path.CGPath;
            label.layer.mask = layer;
            [_categoryView addSubview:label];
        }
    }
    return _categoryView;
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
