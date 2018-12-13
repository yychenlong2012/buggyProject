//
//  reSetPasswordViewController.m
//  Buggy
//
//  Created by goat on 2018/12/13.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "reSetPasswordViewController.h"
#import "CLImageView.h"

@interface reSetPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UITextField *field1;
@property (weak, nonatomic) IBOutlet UITextField *field2;
@property (weak, nonatomic) IBOutlet UITextField *field3;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn1;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn2;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;

@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation reSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view1.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view1.layer.borderWidth = 0.5;
    self.view2.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view2.layer.borderWidth = 0.5;
    self.view3.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view3.layer.borderWidth = 0.5;
    
    [self.view addSubview:self.naviView];
}

- (IBAction)commit:(id)sender {
    //验证码检测
    if (![self.field1.text isEqualToString:self.verifyCode]) {
        [MBProgressHUD showToast:NSLocalizedString(@"验证码错误", nil)];
        return;
    }
    
    if ([self.field2.text isEqualToString:self.field3.text ]) {
        [NETWorkAPI resetPassword:self.field3.text mobilePhone:self.phoneNumber verifyCode:self.verifyCode callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {  //密码修改成功
                //自动登录
                [NETWorkAPI loginWithMobilePhone:self.phoneNumber password:self.field3.text callback:^(homeDataModel * _Nullable model,BOOL is, NSError * _Nullable error) {
                    
                }];
            }
        }];
    }else{
        [MBProgressHUD showToast:@"两次输入的密码不一致"];
    }
}

- (IBAction)btnClick1:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.field2 setSecureTextEntry:!sender.selected];
}

- (IBAction)btnClick2:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.field3 setSecureTextEntry:!sender.selected];
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
    self.contentTop.constant = navigationH + 30;
}
@end
