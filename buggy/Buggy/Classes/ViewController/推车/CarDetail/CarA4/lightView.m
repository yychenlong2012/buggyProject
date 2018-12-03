//
//  lightView.m
//  Buggy
//
//  Created by goat on 2018/9/27.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "lightView.h"
#import "BlueToothManager.h"
#import "BLEA4API.h"
@interface lightView()
@property (weak, nonatomic) IBOutlet UIImageView *NormallyOnImage;      //常亮灯开关提示图片
@property (weak, nonatomic) IBOutlet UIImageView *BreathingLampImage;   //呼吸灯开关提示图片
@property (weak, nonatomic) IBOutlet UISwitch *carLightSwitch;
@property (weak, nonatomic) IBOutlet UILabel *normalOnLabel;            //
@property (weak, nonatomic) IBOutlet UILabel *breathingLampLabel;       //

@end
@implementation lightView

- (IBAction)carLightSwitchClick:(UISwitch *)sender {
    if (sender.on == YES) {  //开
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setCarLight:YES lightMode:0]];
    }else{
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setCarLight:NO lightMode:0]];
    }
}


-(void)awakeFromNib{
    [super awakeFromNib];
    
    //常亮模式
    [self.normalOnLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if (BLEMANAGER.currentPeripheral) {
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setCarLight:YES lightMode:0]];
        }
    }];
    
    //呼吸灯模式
    [self.breathingLampLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if (BLEMANAGER.currentPeripheral) {
            [BLEMANAGER writeValueForPeripheral:[BLEA4API setCarLight:YES lightMode:1]];
        }
    }];
}

//常亮模式
-(void)normalOnMode{
    self.NormallyOnImage.hidden = NO;
    self.BreathingLampImage.hidden = YES;
    self.carLightSwitch.on = YES;
}

//呼吸灯模式
-(void)breathingLampMode{
    self.NormallyOnImage.hidden = YES;
    self.BreathingLampImage.hidden = NO;
    self.carLightSwitch.on = YES;
}

//关闭所有灯
-(void)closeMode{
    self.NormallyOnImage.hidden = YES;
    self.BreathingLampImage.hidden = YES;
    self.carLightSwitch.on = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
