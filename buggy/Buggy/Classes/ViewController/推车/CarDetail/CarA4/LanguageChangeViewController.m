//
//  LanguageChangeViewController.m
//  Buggy
//
//  Created by goat on 2018/5/10.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "LanguageChangeViewController.h"
#import "CLImageView.h"
#import "languageTableViewCell.h"
#import "BlueToothManager.h"
#import "BLEA4API.h"

@interface LanguageChangeViewController ()<UITableViewDelegate,UITableViewDataSource,BlueToothManagerDelegate>
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,assign) NSInteger selectedRow;
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation LanguageChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.vctype == languageVC) {   //如果是语言选择界面
        if ([self.systemLanguage isEqualToString:@"中文"]) {
            self.selectedRow = 0;
        }else{
            self.selectedRow = 1;
        }
    }else if(self.vctype == bellVC){   //如果是铃声选择界面
        self.selectedRow = self.bellsNum;
    }else{
        self.selectedRow = self.brakeSen;
    }
    
    if (self.vctype == languageVC) {
        self.dataArray = @[@"中文",@"英文"];
    }else if (self.vctype == bellVC){
        self.dataArray = @[@"语音提示",@"滴答声",@"无"];
    }else{
        self.dataArray = @[@"1",@"2",@"3",@"4",@"5（最灵敏）"];
    }
    
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.tableview];
}


#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{return 40;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    languageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[languageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row <= self.dataArray.count) {
        cell.language.text = self.dataArray[indexPath.row];
    }
    
    if (indexPath.row == self.selectedRow) {
        cell.SelectedIcon.hidden = NO;
    }else{
        cell.SelectedIcon.hidden = YES;
    }
    
    //刹车灵敏度页面的提示信息
    if (self.vctype != languageVC && self.vctype != bellVC && indexPath.row == self.dataArray.count-1) {
        UILabel *tips = [[UILabel alloc] init];
        tips.text = @"刹车灵敏度：推车在手松开后到自动刹车时的滑行距离";
        tips.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        tips.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
        tips.frame = CGRectMake(20, 40, ScreenWidth-40, 70);
        tips.numberOfLines = 0;
        
        [cell.contentView addSubview:tips];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedRow = indexPath.row;
    [self.tableview reloadData];
    if (self.vctype == languageVC) {   //设置语言
        if (indexPath.row == 0) {
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setSystemLanguage:@"中文"]];
            return;
        }
        if (indexPath.row == 1) {
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setSystemLanguage:@"英文"]];
            return;
        }
    }else if(self.vctype == bellVC){   //设置提示音铃声
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setupWarningSound:self.isBellsOpen andOtherSound:YES bellsNumber:indexPath.row]];
    }else{
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setBrakeSensitivity:indexPath.row]];
    }
}

#pragma mark - lazy
-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.backgroundColor = kWhiteColor;
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, navigationH);
        
        UILabel *naviTitle = [[UILabel alloc] init];
        naviTitle.textColor = kBlackColor;
        naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        if (self.vctype == languageVC) {
            naviTitle.text = NSLocalizedString(@"语言选择", nil);
        }else if (self.vctype == bellVC){
            naviTitle.text = NSLocalizedString(@"刹车提示音铃声", nil);
        }else{
            naviTitle.text = NSLocalizedString(@"智能刹车灵敏度", nil);
        }
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviTitle];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_back_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 18, 18);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
            [BLEMANAGER writeValueForPeripheral:[BLEA4API notifySuccess]];  //请求数据
        }];
        [_naviView addSubview:naviBackImage];
    }
    return _naviView;
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH) style:UITableViewStylePlain];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.bounces = NO;
        _tableview.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"];
    }
    return _tableview;
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

