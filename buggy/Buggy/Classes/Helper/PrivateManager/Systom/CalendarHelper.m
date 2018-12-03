//
//  CalendarHelper.m
//  Buggy
//
//  Created by 孟德林 on 2016/10/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "CalendarHelper.h"

@implementation CalendarHelper

+ (NSString *)transformDateFormat:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormateNormal];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)timeIntervalFromLastTime:(NSString *)lastTime
                        lastTimeFormat:(NSString *)format1
                         ToCurrentTime:(NSString *)currentTime
                     currentTimeFormat:(NSString *)format2
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    dateFormatter1.dateFormat = format1;
    NSDate *lastDate = [dateFormatter1 dateFromString:lastTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = format2;
    NSDate *currentDate = [dateFormatter2 dateFromString:currentTime];
    return [CalendarHelper timeIntervalFromLastTime:lastDate ToCurrentTime:currentDate];
}

+ (NSString *)timeIntervalFromLastTime:(NSDate *)lastTime ToCurrentTime:(NSDate *)currentTime{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    //上次时间
    NSDate *lastDate = [lastTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:lastTime]];
    //当前时间
    NSDate *currentDate = [currentTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:currentTime]];
    //时间间隔
    NSInteger intevalTime = [currentDate timeIntervalSinceReferenceDate] - [lastDate timeIntervalSinceReferenceDate];
    
    //秒、分、小时、天、月、年
    NSInteger minutes = intevalTime / 60;
    NSInteger hours = intevalTime / 60 / 60;
    NSInteger day = intevalTime / 60 / 60 / 24;
    NSInteger month = intevalTime / 60 / 60 / 24 / 30;
    NSInteger yers = intevalTime / 60 / 60 / 24 / 365;
    
    if (minutes <= 10) {
        return [NSString stringWithFormat: @"%ld分钟",(long)minutes];;
    }else if (minutes < 60){
        return [NSString stringWithFormat: @"%ld分钟",(long)minutes];
    }else if (hours < 24){
        return [NSString stringWithFormat: @"%ld小时",(long)hours];
    }else if (day < 30){
        return [NSString stringWithFormat: @"%ld天",(long)day];
    }else if (month < 12){
        NSDateFormatter * df =[[NSDateFormatter alloc]init];
        df.dateFormat = @"M月d日";
        NSString * time = [df stringFromDate:lastDate];
        return time;
    }else if (yers >= 1){
        NSDateFormatter * df =[[NSDateFormatter alloc]init];
        df.dateFormat = @"yyyy年M月d日";
        NSString * time = [df stringFromDate:lastDate];
        return time;
    }
    return @"";
}


+ (NSString *)getDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    return [df stringFromDate:date];
}

+ (NSString *)transformFloadToTimeWithMinuteAndSecond:(float )value{
    
    int sec;
    int min;
    if (value < 60) {
        sec = (int)value;
        min = 0;
        if (sec < 10) {
            return [NSString stringWithFormat:@"00:0%d",sec];
        }
        return [NSString stringWithFormat:@"0%d:%d",min,sec];
    }
    min = (int)value / 60;
    sec = (int)value%60;
    if (sec < 10 && min < 10) {
        return [NSString stringWithFormat:@"0%d:0%d",min,sec];
    }
    if (min < 10 && sec >= 10) {
        return [NSString stringWithFormat:@"0%d:%d",min,sec];
    }
    return [NSString stringWithFormat:@"%d:%d",min,sec];
}

@end
