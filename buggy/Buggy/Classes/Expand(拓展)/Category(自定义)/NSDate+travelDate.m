//
//  NSDate+travelDate.m
//  Buggy
//
//  Created by goat on 2018/6/26.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "NSDate+travelDate.h"

@implementation NSDate (travelDate)

//输出格式 2018-06-26 00：00：00
+(NSDate *)getCurrentDate{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [NSString stringWithFormat:@"%@ 00:00:00",[form stringFromDate:[NSDate date]]];
    form.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [form dateFromString:currentDate];
}
@end
