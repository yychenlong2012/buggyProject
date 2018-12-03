//
//  Theme.h
//  CarCare
//
//  Created by ileo on 14-8-12.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+HexString.h"

#define COLOR_HEXSTRING(hexStr) [UIColor colorWithHexString:hexStr]
#define ImageNamed(name) [UIImage imageNamed:name]
#define ImageOnceType(name,type)  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]]
#define ImageOncePNG(name)  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]]

#define FONT_DEFAULT_Bold(s) [UIFont boldSystemFontOfSize:s]
#define FONT_DEFAULT_Light(s) [UIFont systemFontOfSize:s]


#define FONT_TABLE_TITLE FONT_DEFAULT_Light(15)
#define FONT_TABLE_TIPS FONT_DEFAULT_Light(14)
#define FONT_BUTTON FONT_DEFAULT_Light(17 * _MAIN_RATIO_375)
#define FONT_LABEL FONT_DEFAULT_Light(16)
#define FONT_TEXTFIELD FONT_DEFAULT_Light(16)

@interface Theme : NSObject

#pragma mark --- 本应用主要颜色
/**
 *  导航条颜色（全局）
 *
 *  @return
 */
+(UIColor *)mainNavColor;

+ (UIColor *)mainTabbarColor;
/**
 *  主题颜色（全局）
 *
 *  @return
 */
+(UIColor *)mainColor;
/**
 *  背景颜色（全局）
 *
 *  @return
 */
+(UIColor *)mainBackGroundColor;

/**
  我的
 */
+(UIColor *)mineFunctionName;
+ (UIColor *)mineLineColor;
+ (UIColor *)mineBgColor;

/*
 健康贴士
 */
+ (UIColor *)healthTipsTitleColor;
+ (UIColor *)healthTipsDetailColor;
+ (UIColor *)healthTipsLineColor_YaoDian;
+ (UIColor *)healthTipsLineColor_TiZheng;
+ (UIColor *)healthTipsLineColor_KePu;
+ (UIColor *)healthTipsLineColor_ChengZhang;
+ (UIColor *)healthTipsLineColor_Qinzi;

// topCell

+ (UIColor *)healthtipsTopBirthdayColor;
+ (UIColor *)healthtipsTopAgeColor;
+ (UIColor *)healthtipsTopDetailColor;
+ (UIColor *)aboutUsDetailLBColor;
#pragma amrk --- 公共颜色
+(UIColor *)lineColor;
+(UIColor *)lineNewColor;
+(UIColor *)orangeColor;
+(UIColor *)yellowColor;
+(UIColor *)redColor;
+(UIColor *)blueColor;
+(UIColor *)greenColor;

//+(UIColor *)contentColor;
//+(UIColor *)wordColor;
//+(UIColor *)wordGrayColor;
//+(UIColor *)wordGrayNewColor;


@end
