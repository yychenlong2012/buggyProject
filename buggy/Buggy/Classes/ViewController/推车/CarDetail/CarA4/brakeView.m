//
//  brakeView.m
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "brakeView.h"
#import "BlueToothManager.h"
#import "BLEA4API.h"
#import "CLButton.h"
#import <Masonry.h>

@interface brakeView()
@property (weak, nonatomic) IBOutlet UILabel *topLabel;        //最顶部的电子刹车label
@property (weak, nonatomic) IBOutlet UILabel *autoLabel;
@property (weak, nonatomic) IBOutlet UILabel *smartLabel;      //智能刹车label
@property (weak, nonatomic) IBOutlet UILabel *autoTipsLabel;
@property (weak, nonatomic) IBOutlet UIView *line;

@property (weak, nonatomic) IBOutlet UIView *autoClickView;    //自动刹车模式点击view
@property (weak, nonatomic) IBOutlet UIView *smartClickView;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIImageView *autoImage;
@property (weak, nonatomic) IBOutlet UIImageView *smartImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smartLabelTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smartClickViewTop;

@end
@implementation brakeView
- (IBAction)switchBtnValueChange:(UISwitch *)sender {
    if (sender.on == NO) {
        [BLEMANAGER writeValueForPeripheral:[BLEA4API closeBrake]];
    }else{
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setSmartBrake]];
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];

    __weak typeof(self) wself = self;
    [self.autoClickView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if (BLEMANAGER.currentPeripheral) {
            wself.autoImage.hidden = NO;
            wself.smartImage.hidden = YES;
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setAutoBrake]];
        }
    }];
    [self.smartClickView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if (BLEMANAGER.currentPeripheral) {
            wself.autoImage.hidden = YES;
            wself.smartImage.hidden = NO;
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setSmartBrake]];
        }
    }];
}

//关闭电子刹车
-(void)closeBrake{
    self.switchBtn.on = NO;
    self.autoImage.hidden = YES;
    self.smartImage.hidden= YES;
}
//自动刹车模式
-(void)autoBrakeMode{
    self.switchBtn.on = YES;
    self.autoImage.hidden = NO;
    self.smartImage.hidden= YES;
}
//智能刹车模式
-(void)smartBrakeMode{
    self.switchBtn.on = YES;
    self.autoImage.hidden = YES;
    self.smartImage.hidden= NO;
}
//隐藏自动刹车
-(void)hiddenAutoBrake{
    self.autoImage.hidden = YES;
    self.autoLabel.hidden = YES;
    self.autoTipsLabel.hidden = YES;
    self.autoClickView.hidden = YES;
    self.line.hidden = YES;
    
    //删除原有约束
    [self removeConstraint:self.smartLabelTop];
    [self removeConstraint:self.smartClickViewTop];
    
    //添加新约束
    __weak typeof(self) wself = self;
    [self.smartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.topLabel.mas_bottom).offset(25);
    }];

    [self.smartClickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.topLabel.mas_bottom).offset(25);
    }];
}
@end
