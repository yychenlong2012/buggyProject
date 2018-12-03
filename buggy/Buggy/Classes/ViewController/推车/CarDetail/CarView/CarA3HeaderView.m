//
//  CarA3HeaderView.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3HeaderView.h"
#import "ParentsManager.h"
#import "BabyStrollerManager.h"
#import "CalendarHelper.h"
#import "MainModel.h"
@interface CarA3HeaderView ()<UIAlertViewDelegate>

@end

@implementation CarA3HeaderView{
    
    UILabel *_todayKcalLB;          //今日卡路里
    UILabel *_todayKilometreLB;     //今日行程
    UILabel *_totalKcalLB;          //总卡路里
    UILabel *_totalKilometreLB;     //总行程
    UIView  *_newTravelBgCircleView;//行程的背景图片
    UILabel *_adultWeight;          //体重数量
    UIButton *_editWeightImage;     //编辑体重的图标
    NSString *_todayVelocitySpeed;  //今日平均速度
    
    UIImageView *_image;
    UILabel     *_kcal;
    UILabel     *_todayKcal;
    UILabel     *_totalKcal;
    BOOL        _isFirst; /**<是不是第一次进来*/
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI { //[Theme mainNavColor]
    self.backgroundColor = kWhiteColor;
    _newTravelBgCircleView = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, CarA3HeaderViewHeight) bgColor:[UIColor clearColor] onView:self];
    [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, 230 * _MAIN_RATIO_375) bgColor:[Theme mainNavColor] onView:_newTravelBgCircleView];
    [self setupTravelUI];
}

- (void)setupTravelUI{
    _isFirst = NO;   //10月18号修改
    CGFloat width = _newTravelBgCircleView.width;
    UIImage *image = ImageNamed(@"bg_white");
    UIImageView *bgImage = [Factory imageViewWithCenter:CGPointMake(0, 0) image:image onView:_newTravelBgCircleView];
    bgImage.frame = CGRectMake(0, 0, image.size.width * _MAIN_RATIO_375, image.size.height * _MAIN_RATIO_375);
    bgImage.top = 18 * _MAIN_RATIO_375;
    bgImage.centerX = width/2;
    
    //圆盘上的体重label
    _adultWeight = [Factory labelWithFrame:CGRectMake(0, 48 * _MAIN_RATIO_375, ScreenWidth/5, 25 * _MAIN_RATIO_375) font:nil text:@"0" textColor:COLOR_HEXSTRING(@"#272536") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
    _adultWeight.centerX = width/2;
    _adultWeight.font = [UIFont fontWithName:@"PingFangSC-Light" size:27* _MAIN_RATIO_375];
//    _adultWeight.attributedText  = [self configureFontsAndColorsWithStr:@"0" unitStr:@"kg"];
    
    //体重加号按钮
    UIImage *editImage = ImageNamed(@"add_icon");
//    _editWeightImage = [Factory buttonWithFrame:CGRectMake(0, 0, editImage.size.width, editImage.size.height) withImageName:@"add_icon" click:^{} onView:_newTravelBgCircleView];
    _editWeightImage = [[UIButton alloc] init];
    [_editWeightImage setImage:editImage forState:UIControlStateNormal];
    _editWeightImage.backgroundColor = [UIColor clearColor];
    _editWeightImage.frame = CGRectMake(0, 0, editImage.size.width + 20 * _MAIN_RATIO_375, editImage.size.width + 20 * _MAIN_RATIO_375);
    [_newTravelBgCircleView addSubview:_editWeightImage];
   
    
    [_editWeightImage addTarget:self action:@selector(editWeight:) forControlEvents:UIControlEventTouchUpInside];
//    _editWeightImage.top = _adultWeight.bottom + 10 * _MAIN_RATIO_375;
    _editWeightImage.top = _adultWeight.bottom;
    _editWeightImage.centerX = width/2;
    
    for (NSInteger i = 0; i < 2; i ++) {
        CGFloat width_In = i == 0 ? 106 * _MAIN_RATIO_375 : (width - 106 * _MAIN_RATIO_375);
        UIImageView *iconImage = [Factory imageViewWithCenter:CGPointMake(width_In , 125 * _MAIN_RATIO_375) image:(i == 0 ? ImageNamed(@"calorio_icon") : ImageNamed(@"kilo_icon")) onView:_newTravelBgCircleView];
        
        UILabel *unit = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth / 5, 12) font:FONT_DEFAULT_Light(12) text:(i == 0 ?@"kcal":@"km") textColor:COLOR_HEXSTRING(@"#999999") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
        unit.centerX = width_In;
        unit.top = iconImage.bottom + 6 * _MAIN_RATIO_375;
        unit.font = [UIFont fontWithName:@"PingFangSC-Light" size:12 * _MAIN_RATIO_375];
        
        UILabel *unitName = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth / 4 + 20, 15) font:FONT_DEFAULT_Light(14) text:(i == 0 ?NSLocalizedString(@"今日卡路里", nil):NSLocalizedString(@"今日里程", nil)) textColor:COLOR_HEXSTRING(@"#666666") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
        unitName.centerX = width_In;
        unitName.top = unit.bottom + 10 * _MAIN_RATIO_375;
        
        UILabel *nameTotal = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth / 5 + 20, 13) font:FONT_DEFAULT_Light(12) text:(i == 0 ?NSLocalizedString(@"总卡路里", nil):NSLocalizedString(@"总里程", nil)) textColor:COLOR_HEXSTRING(@"#666666") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
        nameTotal.centerX = width_In;
        nameTotal.top = unitName.bottom + 47 * _MAIN_RATIO_375;
        
        //中心竖线分割线
        if (i == 0) {
            UIImageView *imageLine =[Factory imageViewWithCenter:CGPointMake(width/2, 0) imageRightHeight:ImageNamed(@"divider_img") onView:_newTravelBgCircleView];
            imageLine.top = unit.top;
            
            _image = iconImage;
            _kcal = unit;
            _todayKcal = unitName;
            _totalKcal = nameTotal;
        }
    }
    
    _todayKcalLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/5, 35 * _MAIN_RATIO_375) font:nil text:@"0" textColor:COLOR_HEXSTRING(@"#F47686") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
    _todayKcalLB.centerX = 106 * _MAIN_RATIO_375;
    _todayKcalLB.font = [UIFont fontWithName:@"PingFangSC-Light" size:25 * _MAIN_RATIO_375];
    _todayKcalLB.top = _todayKcal.bottom + 5 * _MAIN_RATIO_375;
    
    _todayKilometreLB =  [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/5, 35 * _MAIN_RATIO_375) font:nil text:@"0" textColor:COLOR_HEXSTRING(@"#F47686") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
    _todayKilometreLB.centerX = width - 106 * _MAIN_RATIO_375;
    _todayKilometreLB.font = [UIFont fontWithName:@"PingFangSC-Light" size:25 * _MAIN_RATIO_375];
    _todayKilometreLB.top = _todayKcal.bottom + 5 * _MAIN_RATIO_375;
    
    
    _totalKcalLB = [Factory labelWithFrame:CGRectMake(0, _todayKcalLB.bottom + 30, ScreenWidth/5, 18) font:nil text:@"0" textColor:COLOR_HEXSTRING(@"#333333") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
    _totalKcalLB.centerX = 106 * _MAIN_RATIO_375;
    _totalKcalLB.font = [UIFont fontWithName:@"PingFangSC-Light" size:17 * _MAIN_RATIO_375];
    _totalKcalLB.top = _totalKcal.bottom + 8 * _MAIN_RATIO_375;
    
    
    _totalKilometreLB = [Factory labelWithFrame:CGRectMake(0, _todayKcalLB.bottom + 30, ScreenWidth/5, 18) font:nil text:@"0" textColor:COLOR_HEXSTRING(@"#333333") onView:_newTravelBgCircleView textAlignment:NSTextAlignmentCenter];
    _totalKilometreLB.centerX =width - 106 * _MAIN_RATIO_375;
    _totalKilometreLB.font = [UIFont fontWithName:@"PingFangSC-Light" size:17 * _MAIN_RATIO_375];
    _totalKilometreLB.top = _totalKcal.bottom + 8 * _MAIN_RATIO_375;
}

- (void)editWeight:(UIButton *)sender{
    
    /* 判断体重是否为零，如果没有进行提示 */
    [self alertMessage];
}
//弹出
- (void)alertMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请输入您的体重", nil) message:NSLocalizedString(@"为了准确计算您的卡路里值，请输入合理体重", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *nameField = [alertView textFieldAtIndex:0];
    nameField.placeholder = NSLocalizedString(@"本人体重(10kg~200kg)", nil);
    nameField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    nameField.tag = 3;
    [alertView show];
}

- (void)configUIWith:(userTravelInfoModel *)model
{
    /* 新界面配置 */
//    _adultWeight.attributedText = [self configureFontsAndColorsWithStr:model.parentsWeight unitStr:@"kg"];
    _adultWeight.text = model.weight;
    if ([model.weight floatValue] != 0) {
        [_editWeightImage setImage:ImageNamed(@"edite_icon") forState:UIControlStateNormal];
    }else{
        //[MBProgressHUD showMessage:@"请您添加自己的体重" delay:0];
         //判断是不是第一次进图这个界面
        if ([MainModel model].isHaveNetWork) {
            if (_isFirst) {
                [self alertMessage];
                _isFirst = NO;
            }
        }
    }
//    _todayKilometreLB.text = [NSString stringWithFormat:@"%.2lf",model.todayMilage] ;
   
    _todayKilometreLB.text = [NSString stringWithFormat:@"%0.2f",[model.todaymileage integerValue]/1000.0];
    _totalKilometreLB.text = [NSString stringWithFormat:@"%0.2f",[model.totalmileage floatValue]];
    if (model.todaycalories != nil) {
        _todayKcalLB.text = [NSString stringWithFormat:@"%0.2f",[model.todaycalories floatValue]];
    }
    if (model.totalcalories != nil) {
        _totalKcalLB.text = [NSString stringWithFormat:@"%0.2f",[model.totalcalories floatValue]];
    }
    
//    _todayVelocitySpeed = model.todayVelocity;
    [[NSUserDefaults standardUserDefaults] setObject:model.weight forKey:@"AdultWeight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (textField.tag == 3) {
            if ([Check AdultWeightIsRight:textField.text]) {
                if ([MainModel model].isHaveNetWork) {
                    _adultWeight.text = textField.text;
                }else{
                    _adultWeight.text = @"0.0";
                }
                /* 开始上传数据,存储到本地 并发出通知更新所有的卡路里 */
                [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"AdultWeight"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //直接上传体重数据
//                [[AVUser currentUser] setObject:@([textField.text integerValue]) forKey:@"weight"];
//                [[AVUser currentUser] saveInBackground];
                [NETWorkAPI updateUserInfoWithOptionType:UPLOAD_USER_WEIGHT optionValue:textField.text callback:^(BOOL success, NSError * _Nullable error) {
                    
                }];
                
                /* 必须获取到最近一次的数据，才能够完成以下步奏 */
//                __block NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
//                [param setValue:_todayKilometreLB.text forKey:@"todayMileage"];
//                [param setValue:_totalKilometreLB.text forKey:@"totalMileage"];
//                [param setValue:_todayVelocitySpeed forKey:@"averageSpeed"];
//                [param setValue:[CalendarHelper getDate] forKey:@"time"];
//                /* 开始上传体重数据 */
//                [MBProgressHUD showHUDAddedTo:self animated:YES];
//                __weak typeof(self) wself = self;
//                [[ParentsManager manager] updateParentsWeight:textField.text finish:^(BOOL success) {
//                    if (success) {
////                        [BabyStrollerManager postA1Travel:param complete:^(NSDictionary *dic,BOOL success) {
////                            /* 再次上传完数据之后，会即时触发云函数(计算云今天的卡路里)，发出通知再次获取数据即可 */
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kPARENTSTOUSERINFO object:nil];
////                            [MBProgressHUD hideHUDForView:wself animated:YES];
////                        }];
//                    }
//                    [MBProgressHUD hideHUDForView:wself animated:YES];
//                } faile:^(NSError *error) {
//                    [MBProgressHUD hideHUDForView:wself animated:YES];
//                    [self showErrorMessage:error];
//                }];
            }
        }
    }
}

- (NSMutableAttributedString *)configureFontsAndColorsWithStr:(NSString *)str unitStr:(NSString *)unitStr{
    NSString *deatilStr = [NSString stringWithFormat:@"%@ %@",str,unitStr];
    NSMutableAttributedString *todayMileageStr = [[NSMutableAttributedString alloc] initWithString:deatilStr];
    NSRange rangeNum = NSMakeRange(0, str.length);
    NSRange rangeUnit = NSMakeRange(str.length, unitStr.length + 1);
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:COLOR_HEXSTRING(@"#272536") range:rangeNum];
    [todayMileageStr addAttribute:NSFontAttributeName value:FONT_DEFAULT_Light(20) range:rangeNum];
    [todayMileageStr addAttribute:NSForegroundColorAttributeName value:COLOR_HEXSTRING(@"#272536") range:rangeUnit];
    [todayMileageStr addAttribute:NSFontAttributeName value:FONT_DEFAULT_Light(11) range:rangeUnit];
    return todayMileageStr;
}

@end


@implementation CarA3SectionView

- (instancetype)initWithFrame:(CGRect)frame withName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIWithName:name];
    }
    return self;
}
- (void)setupUIWithName:(NSString *)name{
    
    [Factory labelWithFrame:CGRectMake(20 * _MAIN_RATIO_375, 12.5 * _MAIN_RATIO_375, ScreenWidth, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(17) text:name textColor:COLOR_HEXSTRING(@"#666666") onView:self textAlignment:NSTextAlignmentLeft];
   
    //锁图标
    self.lock = [[UIImageView alloc] init];
    self.lock.image = ImageNamed(@"Artboard");
    self.lock.frame = CGRectMake(ScreenWidth-30-22, 10, 22, 27);
    self.lock.hidden = YES;
    [self addSubview:self.lock];
}

@end

