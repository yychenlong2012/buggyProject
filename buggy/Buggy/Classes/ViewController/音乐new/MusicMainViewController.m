//
//  MusicMainViewController.m
//  Buggy
//
//  Created by goat on 2018/4/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicMainViewController.h"
#import "MusicBtnView.h"
#import "MusicListTableViewCell.h"
#import "MusicTotalListController.h"
#import "MusicSpecialListController.h"
#import "MusicBannerModel.h"
#import "MusicPlayNewController.h"
#import "WNJsonModel.h"
#import "MusicAlbumModel.h"
#import "banner2.h"
#import "CLLabel.h"
#import "UIImage+COSAdtions.h"

@interface MusicMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIView *btnBGView;
//@property(nonatomic,strong) NSCache *cache;
@property(nonatomic,strong) NSMutableArray *albumArray;   //专辑 热门歌单
@property(nonatomic,strong) NSMutableArray *recommendArray;   //专辑 推荐歌单
@property(nonatomic,strong) banner2 *banner;

@property(nonatomic,strong) NSMutableArray *emptyBannerData;    //无banner内容时的占位内容
@end

@implementation MusicMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumArray = [NSMutableArray array];
    self.recommendArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];

}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.banner startTimer];
    //请求数据
    if (self.banner.dataArray.count == 0) {
        [self requestBannerData];
    }
    if (self.albumArray.count == 0 || self.recommendArray.count == 0) {
        [self requestItemData];
    }
}

-(void)requestBannerData{
    [NETWorkAPI requestBannerDatacallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (modelArray != nil && error == nil) {
            self.banner.dataArray = [NSMutableArray arrayWithArray:modelArray];
        }else{
            //没有数据时使用占位数据
//            self.banner.dataArray = self.emptyBannerData;
        }
    }];
}

//请求专辑
-(void)requestItemData{
    [NETWorkAPI requestHotMusiccallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            [self.albumArray addObjectsFromArray:modelArray];
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationTop];
        }else{
            
        }
    }];
    
    [NETWorkAPI requestRecommendMusiccallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            [self.recommendArray addObjectsFromArray:modelArray];
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 1)];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationTop];
        }else{
            
        }
    }];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{ return 3; }
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
        case 1:
            if (self.albumArray.count == 0) {
                return 1;   //用于显示空白占位
            }else{
                return (NSInteger)ceilf(self.albumArray.count/2.0);
            }
        case 2:
            return (NSInteger)ceilf(self.recommendArray.count/2.0);
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return RealWidth(50)+51;
        case 1:
            if (self.albumArray.count == 0) {
                return RealWidth(160)*3;
            }else{
                return RealWidth(160)+45;
            }
        case 2:
            return RealWidth(160)+45;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return RealWidth(149)+37;
        case 1:
            return self.albumArray.count == 0? 0 : 63;
        case 2:
            return self.recommendArray.count == 0? 0 : 76;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return self.banner;
        }
        case 1:{
            UIView *header = [[UIView alloc] init];
            header.backgroundColor = kWhiteColor;
            header.frame = CGRectMake(0, 0, ScreenWidth, 48);
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
            line.frame = CGRectMake(0, 0, ScreenWidth, 4);
            [header addSubview:line];
            
            UILabel *titleOne = [[UILabel alloc] init];
            titleOne.textAlignment = NSTextAlignmentLeft;
            titleOne.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
            titleOne.text = NSLocalizedString(@"热门歌单", nil);
            titleOne.frame = CGRectMake(25, 28, 150, 20);
            [header addSubview:titleOne];
            
            CLLabel *btn = [[CLLabel alloc] init];
            btn.extraWidth = 15;
            btn.textAlignment = NSTextAlignmentRight;
            btn.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            btn.textColor = [UIColor colorWithHexString:@"#333333"];
            btn.text = NSLocalizedString(@"全部歌单", nil);
            btn.frame = CGRectMake(ScreenWidth-100-20, 34, 100, 14);
            btn.userInteractionEnabled = YES;
            __weak typeof(self) weakSelf = self;
            [btn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                MusicTotalListController *vc = [[MusicTotalListController alloc] init];
                vc.view.backgroundColor = kWhiteColor;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
            [header addSubview:btn];
            return header;
        }
        case 2:{
            UIView *header = [[UIView alloc] init];
            header.backgroundColor = kWhiteColor;
            header.frame = CGRectMake(0, 0, ScreenWidth, 76);
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithHexString:@"#F2F2F4"];
            line.frame = CGRectMake(0, 0, ScreenWidth, 4);
            [header addSubview:line];
            
            UILabel *titleOne = [[UILabel alloc] init];
            titleOne.textAlignment = NSTextAlignmentLeft;
            titleOne.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
            titleOne.text = NSLocalizedString(@"为宝宝推荐", nil);
            titleOne.frame = CGRectMake(25, 28, 150, 20);
            [header addSubview:titleOne];
            return header;
        }
    }
    return [[UIView alloc] init];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 5;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = kWhiteColor;
    if (section == 0) {
        footer.frame = CGRectMake(0, 0, 0,0);
    }else{
        footer.frame = CGRectMake(0, 0, ScreenWidth, 5);
    }
    return footer;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"btn"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"btn"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.btnBGView];
        return cell;
    }
    
    MusicListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list"];
    if (cell == nil) {
        cell = [[MusicListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"list"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 1) {  //热门歌单
        if (self.albumArray.count > 0) {
            cell.leftModel = self.albumArray[indexPath.row * 2];
            if ((indexPath.row * 2 + 1) < self.albumArray.count) {
                cell.rightModel = self.albumArray[indexPath.row * 2 + 1];
            }
        }else{
            //无数据时的占位
            UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"empty"];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageV = [[UIImageView alloc] init];
            [emptyCell.contentView addSubview:imageV];
            imageV.frame = CGRectMake((ScreenWidth-RealWidth(250))/2, 0, RealWidth(250), RealWidth(250));
            imageV.image = ImageNamed(@"无网络");
            imageV.userInteractionEnabled = YES;
            __weak typeof(self) wself = self;
            [imageV addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                [wself requestBannerData];
                [wself requestItemData];
            }];
            return emptyCell;
        }
    }
    if (indexPath.section == 2) {  //推荐
        if (self.recommendArray.count > 0) {
            cell.leftModel = self.recommendArray[indexPath.row * 2];
            if ((indexPath.row * 2 + 1) < self.recommendArray.count) {
                cell.rightModel = self.recommendArray[indexPath.row * 2 + 1];
            }
        }
    }
    return cell;
}

#pragma mark - lazy
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarH+20, ScreenWidth, ScreenHeight-tabbarH-statusBarH-20) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kWhiteColor;
//        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
-(banner2 *)banner{
    if (_banner == nil) {
        _banner = [[banner2 alloc] init];
        _banner.backgroundColor = kWhiteColor;
        _banner.frame = CGRectMake(0, 0, RealWidth(340), RealWidth(149)+37);
    }
    return _banner;
}
-(UIView *)btnBGView{
    if (_btnBGView == nil) {
        _btnBGView = [[UIView alloc] init];
        _btnBGView.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(95-20));
        _btnBGView.backgroundColor = kWhiteColor;
        
        //NSLocalizedString(@"羊水音", nil),
        NSArray *titleArray = @[NSLocalizedString(@"哄睡", nil),NSLocalizedString(@"安抚", nil),NSLocalizedString(@"儿歌", nil),NSLocalizedString(@"故事", nil)];
        NSArray *imageArray = @[@"哄睡",@"安抚",@"儿歌",@"故事"];
        CGFloat margin = (ScreenWidth-40-RealWidth(50)*titleArray.count)/(titleArray.count-1);
        for (NSInteger i = 0; i<titleArray.count; i++) {
            MusicBtnView *btnview = [[MusicBtnView alloc] init];
            btnview.frame = CGRectMake(20+ i*(RealWidth(50)+margin), 0, RealWidth(50), RealWidth(50)+28);
            btnview.imageView.image = [UIImage imageNamed:imageArray[i]];
            btnview.label.text = titleArray[i];
            btnview.userInteractionEnabled = YES;
            __weak typeof(self) wself = self;
            [btnview addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                MusicSpecialListController *vc = [[MusicSpecialListController alloc] init];
                vc.musicType = i+4;
                vc.view.backgroundColor = kWhiteColor;
                [wself.navigationController pushViewController:vc animated:YES];
                [wself.banner stopTimer];
            }];
            [_btnBGView addSubview:btnview];
        }
    }
    return _btnBGView;
}

//暂时不用
-(NSMutableArray *)emptyBannerData{
    if (_emptyBannerData == nil) {
        NSArray *array = @[@{@"type":@"text",
                             @"title":@"让孩子学音乐有哪些好处",
                             @"imgUrl":@"https://lc-1r2os0w0.cn-n1.lcfile.com/98d86ea3f8e1d9cb40f9.png",
                             @"url":@"https://lc-1r2os0w0.cn-n1.lcfile.com/fc9439a9b35225a9ebda.html"
                             },
                           @{@"type":@"text",
                             @"title":@"2-5岁宝宝怎样接触音乐",
                             @"imgUrl":@"https://lc-1r2os0w0.cn-n1.lcfile.com/f68068f4e8628523aded.png",
                             @"url":@"https://lc-1R2oS0W0.cn-n1.lcfile.com/b31bf94741159f999898.html"
                             },
                           @{@"type":@"text",
                             @"title":@"0-3岁宝宝适合的音乐游戏",
                             @"imgUrl":@"https://lc-1r2os0w0.cn-n1.lcfile.com/fdd3677ffedafaaaac84.png",
                             @"url":@"https://lc-1R2oS0W0.cn-n1.lcfile.com/c3aac4aa9fb401e88a62.html"
                             },
                           @{@"type":@"text",
                             @"title":@"多让宝宝聆听美妙的音乐",
                             @"imgUrl":@"https://lc-1r2os0w0.cn-n1.lcfile.com/b616b0c387828e130655.png",
                             @"url":@"https://lc-1R2oS0W0.cn-n1.lcfile.com/f49f2b43e616656c77bf.html"
                             }];
        _emptyBannerData = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            MusicBannerModel *model = [[MusicBannerModel alloc] init];
            model.type = dict[@"type"];
            model.imgurl = dict[@"imgUrl"];
            model.url = dict[@"url"];
            [_emptyBannerData addObject:model];
        }
    }
    return _emptyBannerData;
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.banner stopTimer];
}
@end
