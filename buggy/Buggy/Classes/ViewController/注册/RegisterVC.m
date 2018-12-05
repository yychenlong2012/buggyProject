//
//  RegisterVC.m
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "RegisterVC.h"
#import "UIColor+Additions.h"
#import "AYReSetPasswordVC.h" //修改密码
//#import "AddBirthdayVC.h"
#import "setBabyBirthdayVC.h"
#import "CLImageView.h"
@interface RegisterVC (){
//    AVUser *_user;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTopConstraint;   //确定按钮顶部约束
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;    //内容距离顶部的高度

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[self class]);
    [self.view addSubview:self.naviView];
    self.contentTop.constant = navigationH + 30;
//    _user = [AVUser user];
    if (self.isRePwd) {
        self.view3.alpha = 0;
        [self.commitbtn setTitle:NSLocalizedString(@"确定修改", nil) forState:UIControlStateNormal];
    }
//    [leanCloudMgr event:YOUZI_Register];
    self.view1.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view1.layer.borderWidth = 0.5;
    self.view2.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view2.layer.borderWidth = 0.5;
    self.view3.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view3.layer.borderWidth = 0.5;
    self.btnTopConstraint.constant = RealHeight(72);
    
    self.tfPhoneNum.placeholder = NSLocalizedString(@"输入手机号",nil);
    self.tfPassword.placeholder = NSLocalizedString(@"输入6-22位密码",nil);
    self.tfVerifyCode.placeholder = NSLocalizedString(@"输入验证码",nil);
    [self.btnVerfigy setTitle:NSLocalizedString(@"验证码",nil) forState:UIControlStateNormal];
    [self.commitbtn setTitle:NSLocalizedString(@"下一步",nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//下一步
- (IBAction)onNext:(id)sender {
    
    //验证验证码长度
    if (self.tfVerifyCode.text.length != 6){
        [MBProgressHUD showToast:NSLocalizedString(@"验证码错误", nil)];
        return;
    }
    
    if (self.isRePwd) {//修改密码

        AYReSetPasswordVC *VC = [AYReSetPasswordVC new];
        VC.code = self.tfVerifyCode.text;
        VC.userID = self.tfPhoneNum.text;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else{//注册

        //检验密码格式
        if (![Check checkPassword:self.tfPassword.text]) {
            [MBProgressHUD showToast:NSLocalizedString(@"密码格式不正确", nil)];
            return;
        }
        
        //检验手机号格式
        if (![AYCommon isValidateMobile:self.tfPhoneNum.text]) {
            [MBProgressHUD showToast:NSLocalizedString(@"输入正确的手机号", nil)];
            return;
        }
        
        [NETWorkAPI registerWithMobilePhone:self.tfPhoneNum.text password:self.tfPassword.text callback:^(homeDataModel * _Nullable model, NSError * _Nullable error) {
            if (model != nil && error == nil) {
                //添加宝宝信息
                setBabyBirthdayVC *birthday = [[setBabyBirthdayVC alloc] init];
                birthday.isResetData = NO;
                birthday.sourceVC = self;
                birthday.skip.hidden = NO;
                birthday.view.backgroundColor = kWhiteColor;
                [self.navigationController pushViewController:birthday animated:YES];
            }
        }];
    }
}

//发送验证码
- (IBAction)onVerify:(id)sender {
    
    //判断是不是来重置密码
    if (self.isRePwd) {    //重置密码
        if ([AYCommon isValidateMobile:self.tfPhoneNum.text]) {
            self.btnVerfigy.backgroundColor = [UIColor lightGrayColor];
            [self.btnVerfigy setTitle:@"60s" forState:UIControlStateNormal];
            self.btnVerfigy.tag = 60;
            [self.btnVerfigy setEnabled:NO];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerloop) userInfo:nil repeats:YES];
            
            //获取验证码
//            [AVUser requestPasswordResetWithPhoneNumber:self.tfPhoneNum.text
//                                                  block:^(BOOL succeeded,
//                                                          NSError *error) {
//                NSLog(@"%@",error);
//                if (succeeded) {
//                    [MBProgressHUD showToast:NSLocalizedString(@"验证短信已发送，请注意查收", nil)];
//                }else{
//                    //网络中断：-1005
//                    //无网络连接：-1009
//                    //请求超时：-1001
//                    //服务器内部错误：-1004
//                    //找不到服务器：-1003
//                    NSLog(@"error = %@",error);
//                    if (error.code == 601) {
//                        [MBProgressHUD showToast:NSLocalizedString(@"发送短信过快，或超过每日上限", nil)];
//                    }else if (error.code == -1009) {
//                        [MBProgressHUD showToast:NSLocalizedString(@"无网络连接", nil)];
//                    }else if (error.code == 213) {
//                        [MBProgressHUD showToast:NSLocalizedString(@"手机号对应的用户不存在", nil)];
//                    }else if (error.code == -1005){
//                        [MBProgressHUD showToast:NSLocalizedString(@"网络中断", nil)];
//                    }else if (error.code == -1001){
//                        [MBProgressHUD showToast:NSLocalizedString(@"请求超时", nil)];
//                    }else{
//                        [MBProgressHUD showToast:[NSString stringWithFormat:@"%@%ld",NSLocalizedString(@"未知的错误", nil),(long)error.code]];
//                    }
//                }
//            }];
        }else{
            [MBProgressHUD showToast:NSLocalizedString(@"输入正确的手机号", nil)];
        }
    }else{  //注册
        
        if ([AYCommon isValidateMobile:self.tfPhoneNum.text]) { //判断是否为正确的手机号码
            self.btnVerfigy.backgroundColor = [UIColor lightGrayColor];
            [self.btnVerfigy setTitle:@"60s" forState:UIControlStateNormal];
            self.btnVerfigy.tag = 60;
            [self.btnVerfigy setEnabled:NO];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerloop) userInfo:nil repeats:YES];
            
            //获取验证码
//            [AVSMS requestShortMessageForPhoneNumber:self.tfPhoneNum.text options:nil callback:^(BOOL succeeded, NSError * _Nullable error) {
//
//                if (succeeded) {
//                    [MBProgressHUD showToast:NSLocalizedString(@"验证短信已发送，请注意查收", nil)];
//                }else{
//                    if (error.code == 1) {
//                        [MBProgressHUD showToast:NSLocalizedString(@"次数已达今日上限", nil)];
//                    }else{
//                        [MBProgressHUD showToast:error.localizedDescription];
//                    }
//                }
//            }];

        }else{
            [MBProgressHUD showToast:NSLocalizedString(@"输入正确的手机号", nil)];
        }
    }
}

- (void)timerloop
{
    NSInteger tag = self.btnVerfigy.tag;
    tag -= 1;
    self.btnVerfigy.tag = tag;
    NSString *text = [NSString stringWithFormat:@"%ld",tag];
    self.btnVerfigy.titleLabel.text = text;
    [self.btnVerfigy setTitle:text forState:UIControlStateNormal];
    [self.btnVerfigy setTitle:text forState:UIControlStateHighlighted];
    if (tag <= 0) {
        [timer invalidate];
        timer = nil;
        [self.btnVerfigy setEnabled:YES];
        [self.btnVerfigy setTitle:NSLocalizedString(@"验证码", nil) forState:UIControlStateNormal];
        self.btnVerfigy.backgroundColor = [UIColor colorWithHexString:@"E04E63"];
    }
}


- (IBAction)showOrHide:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.tfPassword setSecureTextEntry:!sender.selected];
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
        if (self.isRePwd) {
            naviLabel.text = NSLocalizedString(@"修改密码", nil);
        }else{
            naviLabel.text = NSLocalizedString(@"注册",nil);
        }
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
