//
//  BabyInfoViewController.m
//  Buggy
//
//  Created by goat on 2018/5/5.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BabyInfoViewController.h"
#import "CLImageView.h"
#import "BabyInfoTableViewCell.h"
#import "BabyModel.h"
#import "setBabyBirthdayVC.h"
#import "setBabyGenderVC.h"
#import "setBabyNickNameVC.h"
#import "setBabyUserIconVC.h"
#import "MineNewViewController.h"

@interface BabyInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UIView *naviView;

@end

@implementation BabyInfoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.babyModel = [[babyInfoModel alloc] init];
    self.view.backgroundColor = kWhiteColor;
    //导航栏
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.tableview];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestBabyInfo];
}

-(void)requestBabyInfo{
    [NETWorkAPI requestBabyInfoWithId:self.babyId callback:^(id  _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[babyInfoModel class]]) {
            self.babyModel = model;
            self.babyModel.objectid = self.babyId;
            [self.tableview reloadData];
            
            //修改上一个界面的信息
            for (NSInteger i = 0; i<self.lastVC.babyArray.count; i++) {
                babyInfoModel *baby = self.lastVC.babyArray[i];
                if ([baby.objectid isEqualToString:self.babyId]) {
                    [self.lastVC.babyArray replaceObjectAtIndex:i withObject:self.babyModel];
                    [self.lastVC.tableview reloadData];
                }
            }
        }
    }];
}

-(void)dealloc{
    NSLog(@"11");
}
#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{return 4;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{return RealWidth(55);}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BabyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[BabyInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrow.hidden = YES;
    if (indexPath.row == 0) {
        cell.icon.image = ImageNamed(@"头像");
        cell.itemLabel.text = NSLocalizedString(@"头像", nil);
        if ([self.babyModel.header isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:self.babyModel.header];
            if (url) {
                [cell.babyIcon sd_setImageWithURL:url placeholderImage:ImageNamed(@"home_default")];
            }
        }
        cell.babyIcon.hidden = NO;
    }else if (indexPath.row == 1){
        cell.icon.image = ImageNamed(@"乳名");
        cell.itemLabel.text = NSLocalizedString(@"乳名", nil);
        cell.detailLabel.text = self.babyModel.name;
    }else if (indexPath.row == 2){
        cell.icon.image = ImageNamed(@"性别");
        cell.itemLabel.text = NSLocalizedString(@"性别", nil);
        cell.detailLabel.text = self.babyModel.sex;
    }else{
        cell.icon.image = ImageNamed(@"生日");
        cell.itemLabel.text = NSLocalizedString(@"生日", nil);
        cell.detailLabel.text = self.babyModel.birthday;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        setBabyUserIconVC *userIcon = [[setBabyUserIconVC alloc] init];
        userIcon.isResetData = YES;
        userIcon.babyId = self.babyId;
        userIcon.sourceVC = self;
        userIcon.view.backgroundColor = kWhiteColor;
        [self.navigationController pushViewController:userIcon animated:YES];
    }else if (indexPath.row == 1){
        setBabyNickNameVC *name = [[setBabyNickNameVC alloc] init];
        name.isResetData = YES;
        name.babyId = self.babyId;
        name.sourceVC = self;
        name.view.backgroundColor = kWhiteColor;
        [self.navigationController pushViewController:name animated:YES];
    }else if(indexPath.row == 2){
        setBabyGenderVC *gender = [[setBabyGenderVC alloc] init];
        gender.isResetData = YES;
        gender.babyId = self.babyId;
        gender.sourceVC = self;
        gender.view.backgroundColor = kWhiteColor;
        [self.navigationController pushViewController:gender animated:YES];
    }else if(indexPath.row == 3){
        setBabyBirthdayVC *birthday = [[setBabyBirthdayVC alloc] init];
        birthday.isResetData = YES;
        birthday.babyId = self.babyId;
        birthday.sourceVC = self;
        birthday.view.backgroundColor = kWhiteColor;
        [self.navigationController pushViewController:birthday animated:YES];
    }
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-bottomSafeH-navigationH) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        naviTitle.text = NSLocalizedString(@"宝宝资料", nil);
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
@end
