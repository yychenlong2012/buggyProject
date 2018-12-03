//
//  SetupViewController.m
//  Buggy
//
//  Created by goat on 2018/5/8.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "SetupViewController.h"
#import "CLImageView.h"
#import "BabyInfoTableViewCell.h"
#import "UserModel.h"
#import "AlertActionSheetMgr.h"
#import "AboutUSViewController.h"
#import "UserProtocol.h"
#import "MusicManager.h"
#import "FloatTools.h"
#import "ScreenMgr.h"
#import "BlueToothManager.h"

@interface SetupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UITableView *tableview;

@property (nonatomic ,assign) BOOL hideVersionCell;  //是否显示更新行
@property (nonatomic ,assign) BOOL hasVersionUpdate; //是否显示更新图标
@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hideVersionCell = YES;
    self.hasVersionUpdate = NO;
    
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.tableview];
    
    [self checkVersion];
}

-(void)dealloc{
    NSLog(@"111");
}

-(void)checkVersion{
    __weak typeof(self) wself = self;
    [NETWorkAPI requestAppControlCallback:^(NSString * _Nullable version, BOOL isHidenVersionCell, NSError * _Nullable error) {
        if ([version isKindOfClass:[NSString class]]) {
            wself.hideVersionCell = isHidenVersionCell;
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *oldVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
            
            wself.hasVersionUpdate = [wself checkUpdateWithOldVersion:oldVersion newVersion:version];
        }
        [wself.tableview reloadData];
    }];
    
    //检测版本
//    [[UserModel model] getNewestVersion:^(AVObject *object, NSError *error) {
//        if (error) {
//            NSLog(@"获取版本号失败");
//            return ;
//        }
//        if (object) {
//            NSString *isHiden = [object objectForKey:@"HideVersionCell"];
//            wself.hideVersionCell = [isHiden isEqualToString:@"1"] ? YES : NO;
//            NSString *newVersion = [object objectForKey:@"version"];
//
//            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
//            NSString *oldVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
//
//            wself.hasVersionUpdate = [wself checkUpdateWithOldVersion:oldVersion newVersion:newVersion];
//        }
//        [wself.tableview reloadData];
//    }];
}

//判断是否有新版本
-(BOOL)checkUpdateWithOldVersion:(NSString *)oldVersion newVersion:(NSString *)newVersion{
    
    NSArray *old = [oldVersion componentsSeparatedByString:@"."];
    NSArray *new = [newVersion componentsSeparatedByString:@"."];
    
    NSInteger oldVersionNmuber = 100 * [old[0] integerValue] + 10 * [old[1] integerValue] + [old[2] integerValue];
    NSInteger newVersionNmuber = 100 * [new[0] integerValue] + 10 * [new[1] integerValue] + [new[2] integerValue];
    
    return (newVersionNmuber > oldVersionNmuber) ? YES : NO;
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 2;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && self.hideVersionCell) {
            return 0;
        }
        return RealWidth(55);
    }
    return 49;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{return 7;}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"];
    view.frame = CGRectMake(0, 0, ScreenWidth, 7);
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BabyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[BabyInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.arrow.hidden = YES;
            if (self.hideVersionCell == NO) {
                cell.icon.image = ImageNamed(@"检查更新");
                cell.itemLabel.text = NSLocalizedString(@"检查更新", nil);
                if (self.hasVersionUpdate) {  //有新版本更新
                    UILabel *label = [[UILabel alloc] init];
                    label.textColor = kWhiteColor;
                    label.textAlignment = NSTextAlignmentCenter;
                    label.text = NSLocalizedString(@"可更新", nil);
                    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
                    label.backgroundColor = [UIColor colorWithHexString:@"E04E63"];
                    label.frame = CGRectMake(ScreenWidth-70, 0, 50, 20);
                    label.centerY = RealWidth(55)/2;
                    label.layer.cornerRadius = 4;
                    label.layer.masksToBounds = YES;
                    [cell.contentView addSubview:label];
                }
            }
        }else if (indexPath.row == 1){
            cell.icon.image = ImageNamed(@"关于三爸");
            cell.itemLabel.text = NSLocalizedString(@"关于三爸", nil);
            cell.arrow.hidden = NO;
        }else{
            cell.icon.image = ImageNamed(@"用户协议");
            cell.itemLabel.text = NSLocalizedString(@"用户协议", nil);
            cell.arrow.hidden = NO;
        }
    }
    if (indexPath.section == 1) {
        cell.arrow.hidden = YES;
        if (indexPath.row == 0) {
            UILabel *label = [[UILabel alloc] init];
            label.text = NSLocalizedString(@"退出登录", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:19];
            label.frame = CGRectMake((ScreenWidth-120)/2, 15, 120, 19);
            [cell.contentView addSubview:label];
        }else{
            UILabel *label = [[UILabel alloc] init];
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];   //获取版本号
            NSString *versionText = [infoDict objectForKey:@"CFBundleShortVersionString"];
            label.text = [NSString stringWithFormat:@"三爸育儿 Version %@",versionText];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHexString:@"#C5C5C5"];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            label.frame = CGRectMake((ScreenWidth-200)/2, 15, 200, 19);
            [cell.contentView addSubview:label];
            cell.contentView.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //检查更新
            if (self.hasVersionUpdate) {
                [ALERTACTIONSHEETMGR createFromVC:self withAlertType:TYPE_ALERTVC_ALERT withTitle:NSLocalizedString(@"提示", nil) withMessage:NSLocalizedString(@"有新的版本", nil) withCanCelTitle:NSLocalizedString(@"取消", nil) withRedBtnTitle:nil withOtherBtnTitle:NSLocalizedString(@"更新", nil) clickIndexBlock:^(NSInteger index) {
                    
                    if (index == 2) {
                        NSString *version = [UIDevice currentDevice].systemVersion;
                        if (version.doubleValue >= 10.0) {
                            [[UIApplication sharedApplication] openURL:
                             [NSURL URLWithString:@"https://itunes.apple.com/cn/app/san-ge-you-zi/id1121966499?mt=8"] options:@{} completionHandler:nil];
                        }else{
                            [[UIApplication sharedApplication] openURL:
                             [NSURL URLWithString:@"https://itunes.apple.com/cn/app/san-ge-you-zi/id1121966499?mt=8"]];
                        }
                    }
                }];
            }else{
                [ALERTACTIONSHEETMGR createFromVC:self withAlertType:TYPE_ALERTVC_ALERT withTitle:NSLocalizedString(@"提示", nil) withMessage:NSLocalizedString(@"当前已是最新版本", nil) withCanCelTitle:NSLocalizedString(@"我知道了", nil) withRedBtnTitle:nil withOtherBtnTitle:nil clickIndexBlock:^(NSInteger index) {
                }];
            }
        }else if (indexPath.row == 1){
            //关于三爸
            AboutUSViewController *aboutUS = [[AboutUSViewController alloc] init];
            [self.navigationController pushViewController:aboutUS animated:YES];
        }else{
            //用户协议
            UserProtocol *procolVC = [[UserProtocol alloc]init];
            [self.navigationController pushViewController:procolVC animated:YES];
        }
    }else{
        
        if (indexPath.row == 0) {
            //退出登录
            __weak typeof(self) wself = self;
            [ALERTACTIONSHEETMGR createFromVC:wself withAlertType:TYPE_ALERTVC_ALERT withTitle:NSLocalizedString(@"提示", nil) withMessage:NSLocalizedString(@"确定要退出当前账号？",nil) withCanCelTitle:NSLocalizedString(@"取消", nil) withRedBtnTitle:nil withOtherBtnTitle:NSLocalizedString(@"确定", nil) clickIndexBlock:^(NSInteger index) {
                if (index == 2) {
                    [[FloatTools manager] dismissMusicRelocateView];
                    [MUSICMANAGER stop];
                    [BLEMANAGER cancelConnect];
                    BLEMANAGER.currentPeripheral = nil;
                    [NETWorkAPI.deviceArray removeAllObjects];
//                    [[MainModel model] logout];
//                    [[MainModel model] showLoginVC];
//                    [leanCloudMgr event:YOUZI_Loginout];
                    [NETWorkAPI logoutWithCallback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            [SCREENMGR changeToLoginScreen];
                        }
                    }];
                }
            }];
        }
    }
}

#pragma mark - 隐藏导航栏
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

#pragma mark - lazy
-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.bounces = NO;
        _tableview.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"];
    }
    return _tableview;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.backgroundColor = kWhiteColor;
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, navigationH);
        
        UILabel *naviTitle = [[UILabel alloc] init];
        naviTitle.textColor = kBlackColor;
        naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviTitle.text = NSLocalizedString(@"设置", nil);
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.frame = CGRectMake((ScreenWidth-100)/2, 13+statusBarH, 100, 18);
        [_naviView addSubview:naviTitle];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_back_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 18, 18);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [_naviView addSubview:naviBackImage];
    }
    return _naviView;
}

@end
