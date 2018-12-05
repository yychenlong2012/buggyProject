//
//  AYReSetPasswordVC.m
//  Buggy
//
//  Created by goat on 2017/8/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "AYReSetPasswordVC.h"
#import "MainModel.h"
#import "LoginViewModel.h"
#import "CLImageView.h"
#import "ScreenMgr.h"
@interface AYReSetPasswordVC ()<UITextFieldDelegate>
@property (nonatomic ,strong) UITextField *password1;//密码
@property (nonatomic ,strong) UITextField *password2;//确认密码
@property (nonatomic ,strong) UIButton    *commitBtn;/**<提交按钮*/
@property (nonatomic ,strong) UIButton    *showPwd1;/**<显示密码*/
@property (nonatomic ,strong) UIButton    *showPwd2;/**<显示或隐藏密码*/
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation AYReSetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    NSLog(@"%@",[self class]);
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 设置UI
 */
- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.password1];
    [self.view addSubview:self.password2];
    [self.view addSubview:self.showPwd1];
    [self.view addSubview:self.showPwd2];
    [self.view addSubview:self.commitBtn];
}
#pragma  mark - Lazy Load
- (UITextField *)password1{
    if (!_password1) {
        _password1 = [[UITextField alloc] initWithFrame:CGRectMake(20, 34+20+navigationH, kWidth - 100, 34)];
        _password1.placeholder = @"请输入密码";
        _password1.delegate = self;
        _password1.font = [UIFont systemFontOfSize:14];
        _password1.textAlignment = NSTextAlignmentCenter;
        [self.password1 setSecureTextEntry:YES];
    }
    return _password1;
}
- (UITextField *)password2{
    if (!_password2) {
        _password2 = [[UITextField alloc] initWithFrame:CGRectMake(20, 34+20+54+navigationH, kWidth - 100, 34)];
        _password2.placeholder = @"请确认密码";
        _password2.delegate = self;
        _password2.font = [UIFont systemFontOfSize:14];
        _password2.textAlignment = NSTextAlignmentCenter;
        [self.password2 setSecureTextEntry:YES];
    }
    return _password2;
}
- (UIButton *)commitBtn{
    if (!_commitBtn) {
        _commitBtn = [AYView createButtonWithFrame:CGRectMake(0, 54+20+54+64+navigationH, kWidth-50, 44) title:@"确定" bgColor:[Theme mainNavColor] radius:0 target:self action:@selector(commitClick)];
        _commitBtn.centerX = kWidth/2;
    }
    return _commitBtn;
}
- (UIButton *)showPwd1{
    if (!_showPwd1) {
        _showPwd1 = [AYView createButtonWithFrame:CGRectMake(kWidth - 85, 34+20+navigationH, 50, 24) title:@"" imageName:nil bgImageName:@"password_show_nor" radius:0 target:self action:@selector(showClick:)];
        [_showPwd1 setBackgroundImage:[UIImage imageNamed:@"password_show_pre"] forState:UIControlStateSelected];
        _showPwd1.tag = 0;
    }
    return _showPwd1;
}
- (UIButton *)showPwd2{
    if (!_showPwd2) {
        _showPwd2 = [AYView createButtonWithFrame:CGRectMake(kWidth - 85, 34+20+54+navigationH, 50, 24) title:@"" imageName:nil bgImageName:@"password_show_nor" radius:0 target:self action:@selector(showClick:)];
        _showPwd2.tag = 1;
        [_showPwd2 setBackgroundImage:[UIImage imageNamed:@"password_show_pre"] forState:UIControlStateSelected];
    }
    return _showPwd2;
}
//提交事件
- (void)commitClick{

    if ([self.password1.text isEqualToString:self.password2.text ]) {
        [NETWorkAPI resetPassword:self.password2.text mobilePhone:self.userID callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {  //密码修改成功
                //自动登录
                [NETWorkAPI loginWithMobilePhone:self.userID password:self.password2.text callback:^(homeDataModel * _Nullable model, NSError * _Nullable error) {
                    
                }];
            }
        }];
    }else{
        [MBProgressHUD showToast:@"两次输入不一致"];
    }
}
//显示或者隐藏
- (void)showClick:(UIButton *)sender{
   
    if (sender.tag) {
        sender.selected = !sender.selected;
        [self.password2 setSecureTextEntry:sender.selected];
    }else{
        sender.selected = !sender.selected;
        [self.password1 setSecureTextEntry:sender.selected];
    }
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
        naviLabel.text = NSLocalizedString(@"修改密码", nil);
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
