//
//  bandPhoneNumViewController.m
//  Buggy
//
//  Created by goat on 2018/12/13.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "bandPhoneNumViewController.h"
#import "CLImageView.h"
#import "setBabyBirthdayVC.h"

@interface bandPhoneNumViewController ()
@property (weak, nonatomic) IBOutlet UITextField *field;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation bandPhoneNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view1.layer.borderColor = KHexRGB(0xE04E63).CGColor;
    self.view1.layer.borderWidth = 0.5;
    [self.view addSubview:self.naviView];
}

- (IBAction)commit:(id)sender {
    //手机验证码比对
    if (![self.field.text isEqualToString:self.verifyCode]) {
        [MBProgressHUD showToast:NSLocalizedString(@"验证码错误", nil)];
        return;
    }
    //绑定手机
    [NETWorkAPI bindPhoneNumber:self.phoneNumber verifyCode:self.field.text callback:^(homeDataModel * _Nullable model, BOOL isfirstLogin, NSError * _Nullable error) {
        //绑定成功后添加宝宝
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
        naviLabel.text = NSLocalizedString(@"绑定手机", nil);
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
