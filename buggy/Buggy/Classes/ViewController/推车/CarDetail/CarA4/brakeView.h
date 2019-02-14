//
//  brakeView.h
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface brakeView : UIView

//关闭电子刹车
-(void)closeBrake;
//自动刹车模式
-(void)autoBrakeMode;
//智能刹车模式
-(void)smartBrakeMode;
//隐藏自动刹车
-(void)hiddenAutoBrake;
//按钮可用状态
-(void)buttonStatus:(BOOL)status;
@end
