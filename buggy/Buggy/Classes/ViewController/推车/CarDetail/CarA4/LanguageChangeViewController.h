//
//  LanguageChangeViewController.h
//  Buggy
//
//  Created by goat on 2018/5/10.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, vcType) {
    languageVC   = 0,    //选择语言界面
    bellVC  = 1,     //铃声界面
    brakeSenVC = 2      //刹车灵敏度
};
@interface LanguageChangeViewController : UIViewController
@property (nonatomic,assign) vcType vctype;   //界面类型

@property (nonatomic,assign) BOOL isBellsOpen;     //提示音是否开启
@property (nonatomic,assign) NSInteger bellsNum;    //铃声种类
@property (nonatomic,strong) NSString *systemLanguage;  //系统语言

@property (nonatomic,assign) NSInteger brakeSen;   //灵敏度
@end
