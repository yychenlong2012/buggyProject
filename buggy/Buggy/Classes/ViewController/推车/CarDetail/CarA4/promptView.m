//
//  promptView.m
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "promptView.h"
#import "MainViewController.h"
#import "LanguageChangeViewController.h"
#import "DYBaseNaviagtionController.h"
#import "BlueToothManager.h"
#import "BLEA4API.h"

@implementation promptView
- (IBAction)sliderSelectedValue:(UISlider *)sender {
    [BLEMANAGER writeValueForPeripheral:[BLEA4API setWarningVolume:(NSInteger)sender.value]];
}

- (IBAction)switchBtnValueChange:(UISwitch *)sender {
    if (sender.on) {
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setupWarningSound:YES andOtherSound:YES bellsNumber:self.bellsNum]];
    }else{
        [BLEMANAGER writeValueForPeripheral:[BLEA4API setupWarningSound:NO andOtherSound:YES bellsNumber:self.bellsNum]];
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.slider setThumbImage:ImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    
    __weak typeof(self) wself = self;
    [self.languageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        LanguageChangeViewController *language = [[LanguageChangeViewController alloc] init];
        language.vctype = languageVC;
        language.isBellsOpen = wself.isBellsOpen;
        language.bellsNum = wself.bellsNum;
        language.systemLanguage = wself.systemLanguage;
        [Navi pushViewController:language animated:YES];
    }];
    
    [self.bellView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        LanguageChangeViewController *language = [[LanguageChangeViewController alloc] init];
        language.vctype = bellVC;
        language.isBellsOpen = wself.isBellsOpen;
        language.bellsNum = wself.bellsNum;
        language.systemLanguage = wself.systemLanguage;
        [Navi pushViewController:language animated:YES];
    }];
}

@end
