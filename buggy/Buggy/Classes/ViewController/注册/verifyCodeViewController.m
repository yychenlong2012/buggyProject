//
//  verifyCodeViewController.m
//  Buggy
//
//  Created by goat on 2018/12/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "verifyCodeViewController.h"
#import "CLImageView.h"
#import "RegisterVC.h"
#import "bandPhoneNumViewController.h"

@interface verifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UIView *verifyCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;
@property (weak, nonatomic) IBOutlet UIView *textFieldPhone;
@property (weak, nonatomic) IBOutlet UIView *textFieldVerify;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *verifyCode;

@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic,strong) MQVerCodeImageView *verifyView;
@property (nonatomic,strong) NSString *verify;            //图形验证码
@property (nonatomic,strong) dispatch_source_t timer;      //定时器

@end

@implementation verifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textFieldPhone.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.textFieldPhone.layer.borderWidth = 0.5;
    self.textFieldVerify.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.textFieldVerify.layer.borderWidth = 0.5;

    
    [self.verifyCodeView addSubview:self.verifyView];
    
    //获取验证码按钮点击
    __weak typeof(self) wself = self;
    [self.btn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        
        //检验手机号格式
        if (![AYCommon isValidateMobile:self.phoneNum.text]) {
            [MBProgressHUD showToast:NSLocalizedString(@"输入正确的手机号", nil)];
            return;
        }
        
        //验证验证码
        if ([self.verifyCode.text isEqualToString:self.verify] || [self.verifyCode.text isEqualToString:self.verify.lowercaseString]) {
            NSString *type;
            switch (self.verifyType) {
                case 0:
                    type = @"register";
                    break;
                case 1:
                    type = @"reset_passwd";
                    break;
                case 2:
                    type = @"bind_mobile";
            }
            
            [NETWorkAPI getVerifyCodeWithPhoneNum:self.phoneNum.text type:type callback:^(NSString * _Nullable msg, NSError * _Nullable error) {
                if (msg != nil) {
                    [wself.verifyView freshVerCode];
                    wself.verifyCode.text = @"";
                    //输入密码界面
                    switch (self.verifyType) {
                        case 0:{
                            RegisterVC *vc = [[RegisterVC alloc] init];
                            vc.isRePwd = NO;
                            vc.phoneNumber = self.phoneNum.text;
                            vc.verifyCode = msg;
                            [wself.navigationController pushViewController:vc animated:YES];
                        }break;
                        case 1:{
                            reSetPasswordViewController *vc = [[reSetPasswordViewController alloc] init];
                            vc.verifyCode = msg;                      //验证码
                            vc.phoneNumber = self.phoneNum.text;        //手机号
                            [self.navigationController pushViewController:vc animated:YES];
                        }break;
                        case 2:{
                            bandPhoneNumViewController *vc = [[bandPhoneNumViewController alloc] init];
                            vc.verifyCode = msg;                      //验证码
                            vc.phoneNumber = self.phoneNum.text;        //手机号
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }
                }else{
                    [MBProgressHUD showToast:NSLocalizedString(@"验证码发送失败", nil)];
                }
            }];
        }else{
            [MBProgressHUD showToast:NSLocalizedString(@"验证码错误", nil)];
        }
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phoneNum resignFirstResponder];
    [self.verifyCode resignFirstResponder];
}

- (IBAction)resetVerifyImage:(id)sender {
    [self.verifyView freshVerCode];
}

#pragma mark - lazy
-(dispatch_source_t)timer{
    if (_timer == nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //设置定时器，开启时间，时间间隔、、
        dispatch_source_set_timer(_timer,DISPATCH_TIME_NOW,(int64_t)(2.0 * NSEC_PER_SEC), 0);
        //设置block回调
        dispatch_source_set_event_handler(_timer, ^{
           
        });
    }
    return _timer;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, navigationH);
        NSLog(@"%f",navigationH);
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
        naviLabel.text = NSLocalizedString(@"验证", nil);
        
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
    }
    return _naviView;
}

-(MQVerCodeImageView *)verifyView{
    if (_verifyView == nil) {
        //图形验证码
        _verifyView = [[MQVerCodeImageView alloc] init];
        _verifyView.frame = self.verifyCodeView.bounds;
        __weak typeof(self) wself = self;
        __weak typeof(_verifyView) weakVerify = _verifyView;
        _verifyView.bolck = ^(NSString *imageCodeStr){
            //打印生成的验证码
            NSLog(@"imageCodeStr = %@",imageCodeStr.lowercaseString);
            wself.verify = imageCodeStr;
        };
        //验证码字符是否可以斜着
        _verifyView.isRotation = NO;
        [_verifyView freshVerCode];
        _verifyView.userInteractionEnabled = YES;
        
        [_verifyView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakVerify freshVerCode];
            wself.verifyCode.text = @"";
        }];
    }
    return _verifyView;
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
    [self.view addSubview:self.naviView];
}


@end
