//
//  electricityView.h
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface electricityView : UIView
@property (nonatomic,strong) UILabel *leftlabel;
@property (nonatomic,strong) UILabel *rightLabel;

@property (nonatomic,strong) CAShapeLayer *leftLayer;
@property (nonatomic,strong) CAShapeLayer *rightLayer;

@property (nonatomic,assign) CGFloat leftValue;    //左边的电量
@property (nonatomic,assign) CGFloat rightValue;   //右边的电量


//关机状态
-(void)closeBattery;
@end
