//
//  CalendarHelper.h
//  Buggy
//
//  Created by 孟德林 on 2016/10/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#define DateFormateNormal  @"yyyy-MM-dd HH:mm:ss"

#define DateFormateCostom  @"yyyy年MM月dd日 HH时mm分ss秒"

#import <Foundation/Foundation.h>

@interface CalendarHelper : NSObject

/*
 格式转换
 */
+ (NSString *)transformDateFormat:(NSDate *)date;

/**
 *  计算上次日期距离现在多久
 *
 *  @param lastTime    上次日期(需要和格式对应)
 *  @param format1     上次日期格式
 *  @param currentTime 最近日期(需要和格式对应)
 *  @param format2     最近日期格式
 *
 *  @return xx分钟前、xx小时前、xx天前
 */
+ (NSString *)timeIntervalFromLastTime:(NSString *)lastTime
                                      lastTimeFormat:(NSString *)format1
                                       ToCurrentTime:(NSString *)currentTime
                     currentTimeFormat:(NSString *)format2;


/**
 将日期字符串转化为date格式

 @return 
 */
+ (NSString *)getDate;


/**
 将fload类型转化为

 @param transform value
 @return 生成的字符串
 */
+ (NSString *)transformFloadToTimeWithMinuteAndSecond:(float )value;

@end
