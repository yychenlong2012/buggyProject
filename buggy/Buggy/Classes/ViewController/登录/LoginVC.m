//
//  LoginVC.m
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
//#import <AVOSCloudSNS.h>
//#import <LeanCloudSocial/AVUser+SNS.h>
#import "LoginModel.h"
#import "RegisterVC.h"
#import "setBabyBirthdayVC.h"
#import "ScreenMgr.h"
#import "LoginViewModel.h"
#import "UserProtocol.h"
#import "verifyCodeViewController.h"
#import "bandThirdPartViewController.h"
#import "registerViewController.h"

@interface LoginVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;

@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNum;
@property (weak, nonatomic) IBOutlet UIButton *rePassword;   //找回密码
@property (weak, nonatomic) IBOutlet UIButton *login;   //登录
@property (weak, nonatomic) IBOutlet UIButton *registration;   //新用户注册


@property (weak, nonatomic) IBOutlet UIView *openIDOAuthView;
@property (weak, nonatomic) IBOutlet UILabel *userAgreement;//用户协议

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewTopConstraint;      //app图标顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewBottomConstraint;  //底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewWidthConstraint;   //宽
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;  //高

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginTopConstraint;       //登录顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTopConstraint;        //密码顶部约束


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpBtnHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openIDOHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerButtonHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openIDOAuthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdBottomConstraint;

@end

@implementation LoginVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkAppStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"登录", nil);
    UITapGestureRecognizer *panGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.openIDOAuthView.hidden = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.userAgreement addGestureRecognizer:tap];
    
    self.iconViewTopConstraint.constant = RealHeight(54);
    self.iconViewWidthConstraint.constant = RealHeight(100);
    self.iconViewHeightConstraint.constant = RealHeight(100);
    self.iconViewBottomConstraint.constant = RealHeight(41);    //、、
    self.signInBtnHeightConstraint.constant = RealHeight(30);
    self.pwdTopConstraint.constant = RealHeight(17);
    self.loginTopConstraint.constant = RealHeight(27);
    self.registerButtonHeightConstraint.constant = RealHeight(40);
    
    
    if (ScreenHeight == 480) {
        
        self.iconViewTopConstraint.constant = 30;
        self.iconViewBottomConstraint.constant = 20;
        self.pwdTopConstraint.constant = 10;
        self.loginTopConstraint.constant = 20;
        self.iconViewWidthConstraint.constant = 75;
        self.iconViewHeightConstraint.constant = 75;
        self.signInBtnHeightConstraint.constant = 25;
        self.signUpBtnHeightConstraint.constant = 25;
        self.openIDOHeightConstraint.constant = 80;
        self.registerButtonHeightConstraint.constant = 30;
        self.openIDOHeightConstraint.constant = 90;
        self.thirdTopConstraint.constant = 15;
        self.thirdBottomConstraint.constant = 10;
    }
    
    self.tfPhoneNum.placeholder = NSLocalizedString(@"手机号",nil);
    self.tfPassword.placeholder = NSLocalizedString(@"密码",nil);
    [self.rePassword setTitle:NSLocalizedString(@"找回密码",nil) forState:UIControlStateNormal];
    [self.login setTitle:NSLocalizedString(@"登录",nil) forState:UIControlStateNormal];
    [self.registration setTitle:NSLocalizedString(@"新用户注册",nil) forState:UIControlStateNormal];
    self.userAgreement.text = NSLocalizedString(@"登录即同意用户协议",nil);
}


//判断设备是否安装了相应的app而显示或者隐藏按钮
-(void)checkAppStatus{

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Sinaweibo://"]])  //新浪微博
        self.weiboBtn.hidden = NO;
    else
        self.weiboBtn.hidden = YES;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])     //微信
        self.weixinBtn.hidden = NO;
    else
        self.weixinBtn.hidden = YES;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]])        //qq
        self.qqBtn.hidden = NO;
    else
        self.qqBtn.hidden = YES;
}



- (void)tapClick{
    UserProtocol *VC = [UserProtocol new];
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark ===  手机号码登录
- (IBAction)onLogin:(id)sender {
    [NETWorkAPI loginWithMobilePhone:self.tfPhoneNum.text password:self.tfPassword.text callback:^(homeDataModel * _Nullable model, BOOL isfirstLogin, NSError * _Nullable error) {
        
    }];
}

//点击键盘的return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.tfPhoneNum) {
        if ([Check validateMobile:textField.text]) {
            
        }else{
            [MBProgressHUD showError:NSLocalizedString(@"手机号不正确", nil)];
        }
    }else{
        if ([Check checkPassword:self.tfPassword.text]) {
            [self onLogin:nil];
        }else{
            
        }
    }
    return YES;
}

#pragma mark ====  第三方登录
- (IBAction)onLoginWeixin:(id)sender {
    [self resignNameAndPasswordFirstResponder];
    [NETWorkAPI loginToGetUserInfoForPlatform:UMSocialPlatformType_WechatSession callback:^(homeDataModel * _Nullable model, BOOL isfirstLogin, NSError * _Nullable error) {
        if (isfirstLogin) {
            bandThirdPartViewController *vc = [[bandThirdPartViewController alloc] init];
//            verifyCodeViewController *vc = [[verifyCodeViewController alloc] init];
            vc.view.backgroundColor = kWhiteColor;
//            vc.verifyType = BAND_PHONE_TYPE;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)onLoginWeibo:(id)sender {
    [self resignNameAndPasswordFirstResponder];
    [NETWorkAPI loginToGetUserInfoForPlatform:UMSocialPlatformType_Sina callback:^(homeDataModel * _Nullable model, BOOL isfirstLogin, NSError * _Nullable error) {
        if (isfirstLogin) {
            bandThirdPartViewController *vc = [[bandThirdPartViewController alloc] init];
//            verifyCodeViewController *vc = [[verifyCodeViewController alloc] init];
            vc.view.backgroundColor = kWhiteColor;
//            vc.verifyType = BAND_PHONE_TYPE;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)onLoginQQ:(id)sender {
    [self resignNameAndPasswordFirstResponder];
    [NETWorkAPI loginToGetUserInfoForPlatform:UMSocialPlatformType_QQ callback:^(homeDataModel * _Nullable model, BOOL isfirstLogin, NSError * _Nullable error) {
        if (isfirstLogin) {
            bandThirdPartViewController *vc = [[bandThirdPartViewController alloc] init];
//            verifyCodeViewController *vc = [[verifyCodeViewController alloc] init];
            vc.view.backgroundColor = kWhiteColor;
//            vc.verifyType = BAND_PHONE_TYPE;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


// 忘记密码
- (IBAction)resetPassword:(id)sender {
//    RegisterVC *VC= [[RegisterVC alloc]init];
//    VC.isRePwd = YES;
//    [self.navigationController pushViewController:VC animated:YES];
    
//    verifyCodeViewController *vc = [[verifyCodeViewController alloc] init];
//    vc.view.backgroundColor = kWhiteColor;
//    vc.verifyType = RESET_PASSWORD_TYPE;
//    [self.navigationController pushViewController:vc animated:YES];

    registerViewController *vc = [[registerViewController alloc] init];
    vc.isRegister = NO;
    [self.navigationController pushViewController:vc animated:YES];
}
// 注册
- (IBAction)onRegister:(id)sender {
//    RegisterVC *vc = [[RegisterVC alloc]init];
//    vc.isRePwd = NO;
//    [self.navigationController pushViewController:vc animated:YES];
//    getVerifyCodeViewController *vc = [[getVerifyCodeViewController alloc] init];
//    vc.view.backgroundColor = kWhiteColor;
    
//    verifyCodeViewController *vc = [[verifyCodeViewController alloc] init];
//    vc.view.backgroundColor = kWhiteColor;
//    vc.verifyType = REGISTER_TYPE;
//    [self.navigationController pushViewController:vc animated:YES];
    
    registerViewController *vc = [[registerViewController alloc] init];
    vc.isRegister = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- ToolMethod
- (void)panView:(UITapGestureRecognizer *)panGestureRecognizer{
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resignNameAndPasswordFirstResponder];
    }
}

- (void)resignNameAndPasswordFirstResponder{
    [self.tfPassword resignFirstResponder];
    [self.tfPhoneNum resignFirstResponder];
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
- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
