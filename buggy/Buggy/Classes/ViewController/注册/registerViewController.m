//
//  registerViewController.m
//  Buggy
//
//  Created by goat on 2018/12/14.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "registerViewController.h"
#import "CLImageView.h"
#import "setBabyBirthdayVC.h"

@interface registerViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UITextField *field1;
@property (weak, nonatomic) IBOutlet UITextField *field2;
@property (weak, nonatomic) IBOutlet UITextField *field3;
@property (weak, nonatomic) IBOutlet UITextField *field4;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;

@property (weak, nonatomic) IBOutlet MQVerCodeImageView *verifyView;

@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic,strong) NSString *imageVerify;            //图形验证码
@property (nonatomic,strong) NSString *verifyCode;             //短信验证码
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.verifyCode = @"";
}

-(void)setupUI{
    [self.view addSubview:self.naviView];
    self.view1.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view1.layer.borderWidth = 0.5;
    self.view2.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view2.layer.borderWidth = 0.5;
    self.view3.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view3.layer.borderWidth = 0.5;
    self.view4.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view4.layer.borderWidth = 0.5;
    self.field4.delegate = self;
    self.verifyBtn.tag = 0;
    
    if (self.isRegister == NO) {
        self.field4.placeholder = NSLocalizedString(@"请输入新的6-22位密码", nil);
    }
    
    [self.field2 setSecureTextEntry:NO];
    
    __weak typeof(self) wself = self;
    self.verifyView.bolck = ^(NSString *imageCodeStr){
        //打印生成的验证码
        NSLog(@"imageCodeStr = %@",imageCodeStr.lowercaseString);
        wself.imageVerify = imageCodeStr;
    };
    //验证码字符是否可以斜着
    _verifyView.isRotation = NO;
    [self.verifyView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [wself.verifyView freshVerCode];
        wself.field2.text = @"";
    }];
    [self.verifyView freshVerCode];
}

- (IBAction)showPassword:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.field4 setSecureTextEntry:!sender.selected];
}

- (IBAction)verifyClick:(UIButton *)sender {
    
    if (self.verifyBtn.tag != 0) {
        return;
    }
    
    self.field3.text = @"";
    //检验手机号格式
    if (![AYCommon isValidateMobile:self.field1.text]) {
        [MBProgressHUD showToast:NSLocalizedString(@"请输入正确的手机号", nil)];
        return;
    }
    if (self.field2.text.length == 0) {
        [MBProgressHUD showToast:NSLocalizedString(@"请输入图形验证码", nil)];
        return;
    }
    if (![self.field2.text isEqualToString:self.imageVerify] && ![self.field2.text isEqualToString:self.imageVerify.lowercaseString]) {
        [MBProgressHUD showToast:NSLocalizedString(@"图形验证码错误", nil)];
        self.field2.text = @"";
        return;
    }
    NSString *type;
    if (self.isRegister) {
        type = @"register";
    }else{
        type = @"reset_passwd";
    }
    //发送验证码
    [NETWorkAPI getVerifyCodeWithPhoneNum:self.field1.text type:type callback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        if (msg != nil) {
            self.verifyCode = msg;
            //发送成功后清空图形验证码
//            self.field2.text = @"";
            [self.verifyView freshVerCode];
            //验证码高亮
            [self.field3 becomeFirstResponder];
            //成功发送验证码后开启定时器
            self.verifyBtn.tag = 60;
            [self.timer fire];
        }
    }];
}

- (IBAction)commit:(UIButton *)sender {
    //校验验证码
    if (self.field3.text.length == 0) {
        [MBProgressHUD showToast:NSLocalizedString(@"请输入短信验证码", nil)];
        return;
    }
    if (![self.field3.text isEqualToString:self.verifyCode]) {
        [MBProgressHUD showToast:NSLocalizedString(@"短信验证码错误", nil)];
        return;
    }
    //校验密码
    if (self.field4.text.length == 0) {
        [MBProgressHUD showToast:NSLocalizedString(@"请输入密码", nil)];
        return;
    }
    if (![Check checkPassword:self.field4.text]) {
        [MBProgressHUD showToast:NSLocalizedString(@"密码格式不正确", nil)];
        return;
    }
    
    if (self.isRegister) {
        //注册
        [NETWorkAPI registerWithMobilePhone:self.field1.text password:self.field4.text verifyCode:self.field3.text callback:^(homeDataModel * _Nullable model,BOOL is, NSError * _Nullable error) {
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
    }else{
        //修改密码
        [NETWorkAPI resetPassword:self.field4.text mobilePhone:self.field1.text verifyCode:self.field3.text callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {  //密码修改成功
                //自动登录
                [NETWorkAPI loginWithMobilePhone:self.field1.text password:self.field4.text callback:^(homeDataModel * _Nullable model,BOOL is, NSError * _Nullable error) { }];
            }
        }];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.field1 resignFirstResponder];
    [self.field2 resignFirstResponder];
    [self.field3 resignFirstResponder];
    [self.field4 resignFirstResponder];
}

-(void)timerRun{
    self.verifyBtn.tag--;
    if (self.verifyBtn.tag == 0) {
        [self.verifyBtn setTitle:@"验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }else{
        [self.verifyBtn setTitle:[NSString stringWithFormat:@"%lds",(long)self.verifyBtn.tag] forState:UIControlStateNormal];
    }
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - delegate
//点击键盘的return
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self commit:nil];
    return YES;
}

#pragma mark - lazy
-(NSTimer *)timer{
    if (_timer == nil) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        _timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
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
        if (self.isRegister) {
            naviLabel.text = NSLocalizedString(@"注册", nil);
        }else{
            naviLabel.text = NSLocalizedString(@"修改密码", nil);
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
    self.contentTop.constant = navigationH + 30;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}
@end
