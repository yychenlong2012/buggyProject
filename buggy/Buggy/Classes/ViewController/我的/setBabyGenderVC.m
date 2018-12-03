//
//  setBabyGenderVC.m
//  Buggy
//
//  Created by goat on 2018/6/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "setBabyGenderVC.h"
#import "CLImageView.h"
#import "setBabyNickNameVC.h"
#import "BabyInfoViewController.h"
#import "BabyModel.h"
@interface setBabyGenderVC ()
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UIView *boyOrGirl;    //宝宝性别
@property (nonatomic,strong) UIButton *button;

@property (nonatomic,strong) NSString *gender;   //性别
@property (nonatomic,strong) UIImageView *boy;
@property (nonatomic,strong) UIImageView *girl;
@end

@implementation setBabyGenderVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.naviView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.boyOrGirl];
    [self.view addSubview:self.button];
    [self.view addSubview:self.skip];
}

-(void)dealloc{
    NSLog(@"11");
}
-(UILabel *)topLabel{
    if (_topLabel == nil) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.textColor = [UIColor colorWithHexString:@"#1C1C1C"];
        _topLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:RealWidth(30)];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.text = NSLocalizedString(@"宝宝性别", nil);
        _topLabel.frame = CGRectMake((ScreenWidth-150)/2, self.naviView.bottom + 20, 150, RealWidth(30));
    }
    return _topLabel;
}
-(UIView *)boyOrGirl{
    if (_boyOrGirl == nil) {
        _boyOrGirl = [[UIView alloc] init];
        _boyOrGirl.frame = CGRectMake((ScreenWidth-RealWidth(237))/2, self.topLabel.bottom+RealWidth(102), RealWidth(237), RealWidth(117));
        
        self.boy = [[UIImageView alloc] init];
        self.boy.frame = CGRectMake(0, 0, RealWidth(88), RealWidth(88));
        self.boy.image = ImageNamed(@"Group 4");
        self.boy.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [self.boy addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([wself.gender isEqualToString:NSLocalizedString(@"小王子", nil)]) {
                wself.boy.image = ImageNamed(@"Group 4");
                wself.gender = @"";
            }else{
                wself.boy.image = ImageNamed(@"Group 7");
                wself.gender = NSLocalizedString(@"小王子", nil);
                wself.girl.image = ImageNamed(@"Group 5");
            }
        }];
        [_boyOrGirl addSubview:self.boy];
        
        UILabel *boyLabel = [[UILabel alloc] init];
        boyLabel.text = NSLocalizedString(@"小王子", nil);
        boyLabel.textAlignment = NSTextAlignmentCenter;
        boyLabel.textColor = [UIColor colorWithHexString:@"#4D4D4D"];
        boyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(14)];
        boyLabel.frame = CGRectMake(0, self.boy.bottom+RealWidth(15), 100, RealWidth(14));
        boyLabel.centerX = self.boy.centerX;
        [_boyOrGirl addSubview:boyLabel];
        
        self.girl = [[UIImageView alloc] init];
        self.girl.frame = CGRectMake(RealWidth(149), 0, RealWidth(88), RealWidth(88));
        self.girl.image = ImageNamed(@"Group 5");
        self.girl.userInteractionEnabled = YES;
        [self.girl addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([wself.gender isEqualToString:NSLocalizedString(@"小公主", nil)]) {
                wself.girl.image = ImageNamed(@"Group 5");
                wself.gender = @"";
            }else{
                wself.girl.image = ImageNamed(@"Group 9");
                wself.gender = NSLocalizedString(@"小公主", nil);
                wself.boy.image = ImageNamed(@"Group 4");
            }
        }];
        [_boyOrGirl addSubview:self.girl];
        
        UILabel *girlLabel = [[UILabel alloc] init];
        girlLabel.text = NSLocalizedString(@"小公主", nil);
        girlLabel.textAlignment = NSTextAlignmentCenter;
        girlLabel.textColor = [UIColor colorWithHexString:@"#4D4D4D"];
        girlLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(14)];
        girlLabel.frame = CGRectMake(0, self.girl.bottom+RealWidth(15), 100, RealWidth(14));
        girlLabel.centerX = self.girl.centerX;
        [_boyOrGirl addSubview:girlLabel];
    }
    return _boyOrGirl;
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

            if (wself.isResetData == YES) {   //修改数据
                [NETWorkAPI updateBabyInfoWithId:wself.babyId optionType:UPLOAD_BABY_SEX optionValue:wself.gender callback:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        
                    }
                }];
                [wself.navigationController popToViewController:wself.sourceVC animated:YES];
            }else{
                setBabyNickNameVC *nickName = [[setBabyNickNameVC alloc] init];
                nickName.isResetData = NO;
                wself.addBabyModel.sex = wself.gender;
                nickName.addBabyModel = wself.addBabyModel;
                nickName.sourceVC = wself.sourceVC;
                nickName.view.backgroundColor = kWhiteColor;
                if (wself.skip.hidden == NO) {
                    nickName.skip.hidden = NO;
                }
                [wself.navigationController pushViewController:nickName animated:YES];
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
