//
//  setBabyNickNameVC.m
//  Buggy
//
//  Created by goat on 2018/6/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "setBabyNickNameVC.h"
#import "CLImageView.h"
#import "setBabyUserIconVC.h"
#import "BabyInfoViewController.h"
#import "BabyModel.h"
@interface setBabyNickNameVC ()
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UIView *babyNickname;  //昵称
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIButton *button;
@end

@implementation setBabyNickNameVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.naviView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.babyNickname];
    [self.view addSubview:self.button];
    [self.view addSubview:self.skip];
}

-(void)dealloc{
    NSLog(@"11");
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}

-(UILabel *)topLabel{
    if (_topLabel == nil) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.textColor = [UIColor colorWithHexString:@"#1C1C1C"];
        _topLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:RealWidth(30)];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.text = NSLocalizedString(@"宝宝昵称", nil);
        _topLabel.frame = CGRectMake((ScreenWidth-150)/2, self.naviView.bottom + 20, 150, RealWidth(30));
    }
    return _topLabel;
}

-(UIView *)babyNickname{
    if (_babyNickname == nil) {
        _babyNickname = [[UIView alloc] init];
        _babyNickname.frame = CGRectMake((ScreenWidth-RealWidth(237))/2, self.topLabel.bottom+RealWidth(102), RealWidth(237), RealWidth(117));
        
        self.textField = [[UITextField alloc] init];
        self.textField.frame = CGRectMake(0, 0, RealWidth(170), RealWidth(35));
        self.textField.center = CGPointMake(_babyNickname.width/2, _babyNickname.height/2);
        self.textField.placeholder = NSLocalizedString(@"宝宝昵称", nil);
        self.textField.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:RealWidth(28)];
        self.textField.textColor = [UIColor colorWithHexString:@"#E04E63"];
        self.textField.textAlignment = NSTextAlignmentCenter;
        [_babyNickname addSubview:self.textField];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = [UIColor colorWithHexString:@"#1C1C1C"].CGColor;
        layer.lineWidth = 3;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake((_babyNickname.width-RealWidth(185))/2, self.textField.bottom+10)];
        [path addLineToPoint:CGPointMake(_babyNickname.width - (_babyNickname.width-RealWidth(185))/2, self.textField.bottom+10)];
        layer.path = path.CGPath;
        [_babyNickname.layer addSublayer:layer];
    }
    return _babyNickname;
}

-(UIButton *)button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(30, ScreenHeight-RealWidth(192)-44, ScreenWidth-60, 44);
        [_button setBackgroundColor:[UIColor colorWithHexString:@"#E04E63"]];
        if (self.isResetData == YES) {
            [_button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        }else{
            [_button setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
        }
        _button.layer.cornerRadius = 8;
        [_button setTitleColor:kWhiteColor forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            __weak typeof(self) wself = self;
            [_button addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                if (wself.textField.text.length > 0) {
//                    [wself.BabyObject setObject:wself.textField.text forKey:@"name"];
                    
                }
                if (wself.isResetData == YES) {  //是更新
                    [NETWorkAPI updateBabyInfoWithId:wself.babyId optionType:UPLOAD_BABY_NAME optionValue:wself.textField.text callback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            
                        }
                    }];
                    [wself.navigationController popToViewController:wself.sourceVC animated:YES];
                }else{
                    setBabyUserIconVC *userIcon = [[setBabyUserIconVC alloc] init];
                    userIcon.isResetData = NO;
                    wself.addBabyModel.name = wself.textField.text;
                    userIcon.addBabyModel = wself.addBabyModel;
                    userIcon.sourceVC = wself.sourceVC;
                    userIcon.view.backgroundColor = kWhiteColor;
                    if (wself.skip.hidden == NO) {
                        userIcon.skip.hidden = NO;
                    }
                    [wself.navigationController pushViewController:userIcon animated:YES];
                }
            }];
    }
    return _button;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.backgroundColor = kWhiteColor;
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, navigationH);
        
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

-(UILabel *)skip{
    if (_skip == nil) {
        _skip = [[UILabel alloc] init];
        _skip.hidden = YES;
        _skip.text = NSLocalizedString(@"暂时不添加宝宝", nil);
        _skip.textColor = [UIColor colorWithHexString:@"#DDDDDD"];
        _skip.textAlignment = NSTextAlignmentCenter;
        _skip.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _skip.frame = CGRectMake((ScreenWidth-200)/2, ScreenHeight-40-bottomSafeH-16, 200, 16);
        _skip.userInteractionEnabled = YES;
        [_skip addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DIDLOGIN object:nil];
        }];
    }
    return _skip;
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
