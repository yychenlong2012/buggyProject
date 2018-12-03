//
//  tripAndMusicOneCellView.h
//  Buggy
//
//  Created by goat on 2018/5/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FSCalendar.h>
#import <Lottie/Lottie.h>

@protocol tripAndMusicOneCellViewDelegate <NSObject>
-(void)backgroundColorChange:(UIColor *)color;  //天气背景颜色改变
@end

@interface tripAndMusicOneCellView : UIView
@property (nonatomic,weak) id<tripAndMusicOneCellViewDelegate> delegate;

@property (nonatomic,strong) NSString *recommendedDate;      //出行推荐数据
@property (nonatomic,strong) NSMutableArray *imageviewArray;  //打卡前三名头像
@property (nonatomic,strong) UILabel *numLabel;              //多少人打卡

@property (nonatomic,strong) CAGradientLayer *gradientLayer;  //背景渐变图层
@property (nonatomic,strong) UIView *animationView;          //存放动画的背景
@property (nonatomic,strong) UILabel *temperature;           //温度
@property (nonatomic,strong) UILabel *air;                   //空气质量
@property (nonatomic,strong) UILabel *tipsLabel;             //tips
@property (nonatomic,strong) UIView *tripManage;
@property (nonatomic,strong) UILabel *dateLabel;             //时间
@property (nonatomic,strong) FSCalendar *calendar;
@property (nonatomic,strong) LOTAnimationView* animation;

@property (nonatomic,strong) UIButton *connectBtn;
@property (nonatomic,strong) UILabel *onlineLabel;
//展示天气动画
-(void)showWeatherAnimtionWithCode:(NSString *)weatherCode;
@end
