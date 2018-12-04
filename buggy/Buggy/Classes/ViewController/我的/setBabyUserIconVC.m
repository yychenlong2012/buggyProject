//
//  setBabyUserIconVC.m
//  Buggy
//
//  Created by goat on 2018/6/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "setBabyUserIconVC.h"
#import "CLImageView.h"
#import "WNImagePicker.h"
#import "UIImage+COSAdtions.h"
#import "BabyInfoViewController.h"
#import "BabyModel.h"
#import "MineNewViewController.h"

@interface setBabyUserIconVC ()<WNImagePickerDelegate>
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIView *babyIcon;   //头像
@property (nonatomic,strong) UIImageView *icon;  //宝宝头像

@property (nonatomic,strong) NSData *imageData;
@end

@implementation setBabyUserIconVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.babyIcon];
    [self.view addSubview:self.button];
    [self.view addSubview:self.skip];
}
-(void)dealloc{
    NSLog(@"setBabyUserIconVC-dealloc");
}
#pragma mark -- WNImagePickerDelegate
- (void)getCutImage:(UIImage *)image controller:(WNImagePicker *)vc{
    [self.navigationController popToViewController:self animated:YES];
    self.icon.image = image;
    //上传baby头像
    NSData *imageData = [image compressImageWithImage:image aimWidth:414*2 aimLength:1024*1024 accuracyOfLength:1024];
    self.imageData = imageData;
    
    //id不为空说明是修改
    if (self.babyId != nil) {
        [NETWorkAPI updateBabyInfoWithId:self.babyId optionType:UPLOAD_BABY_HEADER optionValue:imageData callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [MBProgressHUD showToast:NSLocalizedString(@"头像上传成功", nil)];
            }else{
                [MBProgressHUD showToast:NSLocalizedString(@"头像上传失败", nil)];
            }
        }];
    }
}

-(UILabel *)topLabel{
    if (_topLabel == nil) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.textColor = [UIColor colorWithHexString:@"#1C1C1C"];
        _topLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:RealWidth(30)];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.text = NSLocalizedString(@"宝宝头像", nil);
        _topLabel.frame = CGRectMake((ScreenWidth-150)/2, self.naviView.bottom + 20, 150, RealWidth(30));
    }
    return _topLabel;
}

-(UIView *)babyIcon{
    if (_babyIcon == nil) {
        _babyIcon = [[UIView alloc] init];
        _babyIcon.frame = CGRectMake((ScreenWidth-RealWidth(237))/2, self.topLabel.bottom+RealWidth(102), RealWidth(237), RealWidth(117));
        
        self.icon = [[UIImageView alloc] init];
        self.icon.frame = CGRectMake(0, 0, RealWidth(90), RealWidth(90));
        self.icon.centerX = _babyIcon.width/2;
        self.icon.image = ImageNamed(@"Group 2 Copy");
        self.icon.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [self.icon addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            WNImagePicker *pickerVC  = [[WNImagePicker alloc]init];
            pickerVC.delegate = wself;
            [wself.navigationController pushViewController:pickerVC animated:YES];
        }];
        [_babyIcon addSubview:self.icon];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.icon.bounds];
        layer.path = path.CGPath;
        self.icon.layer.mask = layer;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = NSLocalizedString(@"点击换头像", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"#4D4D4D"];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(14)];
        label.frame = CGRectMake(0, self.icon.bottom+RealWidth(15), 100, RealWidth(14));
        label.centerX = self.icon.centerX;
        [_babyIcon addSubview:label];
    }
    return _babyIcon;
}

//完成按钮
-(UIButton *)button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(30, ScreenHeight-RealWidth(192)-44, ScreenWidth-60, 44);
        [_button setBackgroundColor:[UIColor colorWithHexString:@"#E04E63"]];
        [_button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        _button.layer.cornerRadius = 8;
        [_button setTitleColor:kWhiteColor forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        __weak typeof(self) wself = self;
        [_button addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            //添加宝贝
            if (wself.addBabyModel != nil) {
                [NETWorkAPI addBabyInfoWithModel:wself.addBabyModel header:wself.imageData callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
                    if (![modelArray isKindOfClass:[NSArray class]]) {
                        return ;
                    }
                    if ([wself.sourceVC isKindOfClass:[MineNewViewController class]]) {
                        MineNewViewController *mine = (MineNewViewController *)wself.sourceVC;
                        [mine.babyArray removeAllObjects];
                        [mine.babyArray addObjectsFromArray:modelArray];
                        [mine.tableview reloadData];
//                        [mine.babyArray insertObject:wself.addBabyModel atIndex:0];
//                        [mine.tableview reloadData];
                    }
                }];
            }
            
            if (wself.skip.hidden == NO) {  //注册时用到
                [[NSNotificationCenter defaultCenter] postNotificationName:DIDLOGIN object:nil];
            }else{   //一般修改添加信息时用到
                [wself.navigationController popToViewController:wself.sourceVC animated:YES];
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
