//
//  CarA3SetTableViewCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/31.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3SetTableViewCell.h"
#import "NSUserDefaults+SafeAccess.h"

@implementation CarA3SetTableViewCell{
    UISlider *_backLightSlider;
    UIButton *_closeBt;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
//    __weak typeof(self) wself = self;

    // 防盗图标
    UIImageView *guardAgainstTheftImageView = [Factory imageViewWithFrame:CGRectMake(0, 0, 19 * _MAIN_RATIO_375, 19 * _MAIN_RATIO_375) image:ImageNamed(@"icon_防盗") onView:self.contentView];
    guardAgainstTheftImageView.left = 20 * _MAIN_RATIO_375;
    guardAgainstTheftImageView.top = 15 * _MAIN_RATIO_375;
    
    // 防盗文字
    UILabel *guardAgainstTheftLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/ 2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15) text:NSLocalizedString(@"一键防盗", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    guardAgainstTheftLB.left = 10 * _MAIN_RATIO_375 + guardAgainstTheftImageView.right;
    guardAgainstTheftLB.centerY = guardAgainstTheftImageView.centerY;
    
    // 防盗按钮
    self.switchBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switchBtn.tintColor = COLOR_HEXSTRING(@"#eeeeee");
    self.switchBtn.onTintColor = COLOR_HEXSTRING(@"#F593A0");
    self.switchBtn.right = ScreenWidth - 20 * _MAIN_RATIO_375;
    self.switchBtn.centerY = guardAgainstTheftLB.centerY;
    [self.switchBtn addTarget:self action:@selector(SwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchBtn];

    // 关闭刹车系统图标
    UIImageView *cancleBrakeImageView = [Factory imageViewWithFrame:CGRectMake(0, 0, 19 * _MAIN_RATIO_375, 19 * _MAIN_RATIO_375) image:ImageNamed(@"icon_智能刹车") onView:self.contentView];
    cancleBrakeImageView.left = 20 * _MAIN_RATIO_375;
    cancleBrakeImageView.top = guardAgainstTheftImageView.bottom + 20 * _MAIN_RATIO_375;
    
    // 关闭刹车系统文字
    UILabel *cancleBrakeLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/ 2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15) text:NSLocalizedString(@"智能刹车", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    cancleBrakeLB.left = 10 * _MAIN_RATIO_375 + cancleBrakeImageView.right;
    cancleBrakeLB.centerY = cancleBrakeImageView.centerY;
    
    // 关闭刹车系统   智能刹车开关
    self.autoBrakeBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.autoBrakeBtn.tintColor = COLOR_HEXSTRING(@"#eeeeee");
    self.autoBrakeBtn.onTintColor = COLOR_HEXSTRING(@"#F593A0");
    self.autoBrakeBtn.right = ScreenWidth - 20 * _MAIN_RATIO_375;
    self.autoBrakeBtn.centerY = cancleBrakeLB.centerY;
    [self.autoBrakeBtn addTarget:self action:@selector(autoBrakeBtnAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.autoBrakeBtn];

    // 背光图标
    UIImageView *backLight = [Factory imageViewWithFrame:CGRectMake(0, 0, 19 * _MAIN_RATIO_375, 19 * _MAIN_RATIO_375) image:ImageNamed(@"Travel_Backlight") onView:self.contentView];
    backLight.left = 20 * _MAIN_RATIO_375;
    backLight.top = cancleBrakeImageView.bottom + 20 * _MAIN_RATIO_375;
    
    //背光文字
    UILabel *backLightLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/ 2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15) text:NSLocalizedString(@"按键背光调节", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    backLightLB.left = 10 * _MAIN_RATIO_375 + backLight.right;
    backLightLB.centerY = backLight.centerY;
    
    // 背光进度条
    //    UIImage *image = ImageNamed(@"调节按钮");
    UIImage *image = [UIImage imageWithColor:COLOR_HEXSTRING(@"#F593A0") cornerRadius:8 * _MAIN_RATIO_375];
    UISlider *backLightSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 335 * _MAIN_RATIO_375, 20)];
    backLightSlider.centerX = ScreenWidth/2;
    backLightSlider.top = backLightLB.bottom + 38 * _MAIN_RATIO_375;
    [backLightSlider addTarget:self action:@selector(backLightSet:) forControlEvents:UIControlEventValueChanged];
    [backLightSlider setThumbImage:image forState:UIControlStateNormal];
    backLightSlider.tintColor = COLOR_HEXSTRING(@"#F593A0");
    backLightSlider.maximumTrackTintColor = COLOR_HEXSTRING(@"#F7F7F7");
    backLightSlider.minimumValue = 0.0f;
    backLightSlider.maximumValue = 6.0f;
    backLightSlider.value = 0.0;
    backLightSlider.continuous = NO;
    [self addSubview:backLightSlider];
    _backLightSlider = backLightSlider;
    
    CGFloat sliderWidth = (335 - 12 ) * _MAIN_RATIO_375 / 6;
    for (NSInteger i = 0; i < 7; i ++) {
        UIButton *dot = [Factory buttonEmptyWithFrame:CGRectMake(0, 0, 12 * _MAIN_RATIO_375, 12 * _MAIN_RATIO_375) click:nil onView:nil];
        dot.backgroundColor = COLOR_HEXSTRING(@"#F7F7F7");
        dot.centerY = backLightSlider.height / 2;
        dot.centerX = i * sliderWidth + 6 * _MAIN_RATIO_375;
        dot.clipsToBounds = YES;
        dot.layer.cornerRadius = 6 * _MAIN_RATIO_375;
        dot.tag = i;
        [dot addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchUpInside];
        [backLightSlider insertSubview:dot belowSubview:backLightSlider];
    }
    
    //如果一键防盗开启则智能刹车关闭且不能使用
    // 一键关机
    UIButton *closeButton = [Factory buttonWithCenter:CGPointMake(ScreenWidth/2,backLightSlider.bottom + 70 * _MAIN_RATIO_375) withImage:ImageNamed(@"button_关机") click:nil onView:self.contentView];
    [closeButton addTarget:self action:@selector(closeDevice) forControlEvents:UIControlEventTouchUpInside];
    _closeBt = closeButton;
    
    // 一键关机文字
    UILabel *closeLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/3, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15) text:NSLocalizedString(@"一键关机", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    closeLB.centerX = ScreenWidth/ 2;
    closeLB.top = closeButton.bottom + 7.5 * _MAIN_RATIO_375;
}

- (void)selectMode:(UIButton *)sender{
    UIButton *button = sender;
    button.backgroundColor = COLOR_HEXSTRING(@"#F593A0");
    NSInteger num  = button.tag;
    _backLightSlider.value = num;
    if (self.backLightBlock) {
        self.backLightBlock((int)num);
    }
    for (NSInteger i = 0; i < num + 1; i ++) {
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = (UIButton *)[_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F593A0");
        }
    }
    for (NSInteger i = num + 1; i < 7; i ++) {
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = [_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F7F7F7");
        }
    }
}

//一键防盗开关
- (void)SwitchAction:(UISwitch *)sw{   //一键防盗开关
    if (sw.on == YES) {
        if (self.autoBrakeBtn.on == YES) {
            self.autoBrakeBtn.enabled = NO;
        }else{
            [AYMessage show:@"智能刹车未开启" onView:self autoHidden:YES];
            sw.on = NO;
        }
    }else{
        self.autoBrakeBtn.enabled = YES;
    }
    self.switchActionBlock(sw.on);
}

//智能刹车开关
- (void)autoBrakeBtnAction:(UISwitch *)sw{
    if (sw.on == NO) {
        if (self.switchBtn.on == YES) {  //如果一键防盗开启，智能刹车无法关闭
            [AYMessage show:@"一键防盗未关闭" onView:self autoHidden:YES];
            sw.on = YES;
        }else{
            self.switchBtn.enabled = NO;
        }
    }else{
        self.switchBtn.enabled = YES;
    }
    self.cancleDeviceBrakeActionBlock(sw);
}

- (void)backLightSet:(UISlider *)slider{
  
    if (!slider.enabled) {
        [self showMessage:NSLocalizedString(@"请刹车后调节灯光", nil)];
        return;
    }
    int num = 0;
    if (slider.value > 1.0) {
        num =  (int)slider.value + ((slider.value - (int)slider.value) > 0 ? 1 : 0);
    }
    if (slider.value < 1.0 && slider.value > 0) {
        num = 1;
    }
    if (self.backLightBlock) {
        self.backLightBlock(num);
    }
    DLog(@"---------%f",slider.value);
    
    for (NSInteger i = 0; i < num + 1; i ++) {
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = (UIButton *)[_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F593A0");
        }
    }
    for (NSInteger i = num ; i < 7; i ++) {
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = [_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F7F7F7");
        }
    }
 
}

- (void)closeDevice{
    if (self.closeDeviceBlock) {
        self.closeDeviceBlock();
    }
}

- (void)setBackLightProgress:(float)value{
    _backLightSlider.value = value;
    for (NSInteger i = 0; i < value + 1; i ++) {
 
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = (UIButton *)[_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F593A0");
        }
    }
    for (NSInteger i = value ; i < 7; i ++) {
        if ([[_backLightSlider viewWithTag:i] isKindOfClass:[UIButton class]]) {
            UIButton *dot = [_backLightSlider viewWithTag:i];
            dot.backgroundColor = COLOR_HEXSTRING(@"#F7F7F7");
        }
    }
}


- (void)setBLEConnectStatus:(BOOL)connect{
//    
//    if (connect) {
//        [self setNeedsLayout];
//    }
    if (connect) { 
        [_closeBt setImage:ImageNamed(@"button_关机") forState:UIControlStateNormal];
        _closeBt.enabled = YES;
        self.switchBtn.enabled = YES;
        self.autoBrakeBtn.enabled = YES;
        _backLightSlider.enabled = YES;
    }else{
        [_closeBt setImage:ImageNamed(@"unconnected-关机") forState:UIControlStateNormal];
        _closeBt.enabled = NO;
        self.switchBtn.enabled = NO;
        self.autoBrakeBtn.enabled = NO;
        _backLightSlider.enabled = NO;
    }
}
//灯光调节是否可点击
- (void)closeOrOpenLight:(BOOL)flag{
    if (flag) {
        _backLightSlider.enabled = YES;
    }else{
        _backLightSlider.enabled = NO;
    }
}
- (void)open{
    self.autoBrakeBtn.onTintColor = [UIColor lightGrayColor];
    self.switchBtn.onTintColor = [UIColor lightGrayColor];
    
    _closeBt.enabled = YES;
    self.switchBtn.enabled = YES;
    self.autoBrakeBtn.enabled = YES;
    _backLightSlider.enabled = YES;
   
}
- (void)close{
    _closeBt.enabled = NO;
    self.switchBtn.enabled = NO;
    self.autoBrakeBtn.enabled = NO;
    _backLightSlider.enabled = NO;
}
- (void)isON:(BOOL)flag{  //智能刹车
    self.autoBrakeBtn.on = !self.autoBrakeBtn.on;
}
@end
