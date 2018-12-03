//
//  AboutUSViewController.m
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "AboutUSViewController.h"
#import "CompanyProfileViewController.h"
#import "MineNormalCell.h"
#import "UserProtocol.h"
#import "FunctionViewController.h"
#import "CLImageView.h"

@interface AboutUSViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation AboutUSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    self.title = NSLocalizedString(@"关于我们",nil);

    [self.view addSubview:self.tableview];
}
-(void)dealloc{
    
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStylePlain];
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.dataSource = self;
        _tableview.delegate = self;
    }
    return _tableview;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return RealHeight(190);
    }else{
        return RealHeight(50);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {   //版本号
        UITableViewCell *topCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"top"];
        topCell.selectionStyle = UITableViewCellSelectionStyleNone;
        topCell.contentView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.8];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - RealWidth(90))/2, RealWidth(20), RealHeight(90), RealHeight(90))];
        icon.image = [UIImage imageNamed:@"logo"];
        [topCell.contentView addSubview:icon];
        
        UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 150)/2, icon.bottom + 10, 150, 25)];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];   //获取版本号
        NSString *versionText = [infoDict objectForKey:@"CFBundleShortVersionString"];
        version.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"当前版本", nil),versionText];
        version.textAlignment = NSTextAlignmentCenter;
        version.font = [UIFont systemFontOfSize:12];
        [topCell.contentView addSubview:version];
        
        return topCell;
    }
   
    MineNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aaa"];
    if (cell == nil) {
        cell = [[MineNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aaa"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.updateLabel.hidden = YES;
        CGRect frame = cell.updateLabel.frame;
        frame.origin.x = 20;
        frame.size.width = 150;
        cell.functionName.frame = frame;
        
        cell.functionName.text = self.titleArray[indexPath.row-1];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:  //功能介绍
        {
            FunctionViewController *vc = [[FunctionViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:  //用户协议
        {
            UserProtocol *procolVC = [[UserProtocol alloc]init];
            [self.navigationController pushViewController:procolVC animated:YES];
        }
            break;
        case 3:  //公司简介
        {
            CompanyProfileViewController *profile = [[CompanyProfileViewController alloc] init];
            [self.navigationController pushViewController:profile animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(NSArray *)titleArray{
    if (_titleArray == nil) {
        _titleArray = @[NSLocalizedString(@"功能介绍",nil),NSLocalizedString(@"用户协议",nil),NSLocalizedString(@"公司简介",nil)];
    }
    return _titleArray;
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
        naviLabel.text = NSLocalizedString(@"关于我们",nil);
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
