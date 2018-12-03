//
//  promptView.h
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface promptView : UIView
@property (nonatomic,assign) NSInteger bellsNum;    //铃声种类
@property (nonatomic,assign) BOOL isBellsOpen;     //提示音是否开启
@property (nonatomic,strong) NSString *systemLanguage; //系统语言

@property (weak, nonatomic) IBOutlet UILabel *language;   //系统语言
@property (weak, nonatomic) IBOutlet UILabel *bells;      //铃声

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

//用于添加手势
@property (weak, nonatomic) IBOutlet UIView *languageView;
@property (weak, nonatomic) IBOutlet UIView *bellView;

@end
