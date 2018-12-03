//
//  setBabyBirthdayVC.m
//  Buggy
//
//  Created by goat on 2018/6/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "setBabyBirthdayVC.h"
#import "CLImageView.h"
#import "DatePickerView.h"
#import "setBabyGenderVC.h"
#import "BabyInfoViewController.h"
#import "BabyModel.h"

@interface setBabyBirthdayVC ()
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) DatePickerView *birthdayPicker;   //生日选择
@property (nonatomic,strong) UIButton *button;
@end

@implementation setBabyBirthdayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.birthdayPicker];
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
        _topLabel.text = NSLocalizedString(@"宝宝生日", nil);
        _topLabel.frame = CGRectMake((ScreenWidth-150)/2, self.naviView.bottom + 20, 150, RealWidth(30));
    }
    return _topLabel;
}
-(UIButton *)button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(30, ScreenHeight-RealWidth(192)-44, ScreenWidth-60, 44);
        [_button setBackgroundColor:[UIColor colorWithHexString:@"#E04E63"]];
        if (self.isResetData == YES) {//是修改数据
            [_button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        }else{
            [_button setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
        }
        _button.layer.cornerRadius = 8;
        [_button setTitleColor:kWhiteColor forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        __weak typeof(self) wself = self;
        [_button addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            NSDateFormatter *famater = [[NSDateFormatter alloc]init];
            [famater setDateFormat:@"yyyy-MM-dd"];
            NSString *strDate = [famater stringFromDate:wself.birthdayPicker.pickerView.date];

            if (wself.isResetData == YES) {  //是修改数据
                [NETWorkAPI updateBabyInfoWithId:wself.babyId optionType:UPLOAD_BABY_BIRTHDAY optionValue:strDate callback:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
    
                    }
                }];
                [wself.navigationController popToViewController:wself.sourceVC animated:YES];
            }else{
                //切换到下一个功能
                setBabyGenderVC *gender = [[setBabyGenderVC alloc] init];
                gender.isResetData = NO;
                wself.addBabyModel.birthday = strDate;
                gender.addBabyModel = wself.addBabyModel;
                gender.sourceVC = wself.sourceVC;
                gender.view.backgroundColor = kWhiteColor;
                if (wself.skip.hidden == NO) {
                    gender.skip.hidden = NO;
                }
                [wself.navigationController pushViewController:gender animated:YES];
            }
        }];
    }
    return _button;
}

-(DatePickerView *)birthdayPicker{
    if (_birthdayPicker == nil) {
        _birthdayPicker = [DatePickerView viewWithXib:@"DatePickerView"];
        _birthdayPicker.frame = CGRectMake((ScreenWidth-RealWidth(237))/2, self.topLabel.bottom+RealWidth(102), RealWidth(237), RealWidth(117));
        _birthdayPicker.corfirmBtn.hidden = YES;
        _birthdayPicker.cancelBtn.hidden = YES;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = kClearColor.CGColor;
        layer.strokeColor = kWhiteColor.CGColor;
        layer.lineWidth = 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:_birthdayPicker.pickerView.bounds];
        layer.path = path.CGPath;
        [_birthdayPicker.pickerView.layer addSublayer:layer];
    }
    return _birthdayPicker;
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

-(babyInfoModel *)addBabyModel{
    if (_addBabyModel == nil) {
        _addBabyModel = [[babyInfoModel alloc] init];
    }
    return _addBabyModel;
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
