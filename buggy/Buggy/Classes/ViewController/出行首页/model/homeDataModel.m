//
//  homeDataModel.m
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "homeDataModel.h"

@implementation homeDataModel

+ (NSDictionary *)objectClassInArray{
    return @{
             @"headerUrl" : @"punchHeaderImage"
             };
}


//可以在这里设置默认值，可以在生成模型时将数据转化成想要的格式
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if (oldValue == nil || [oldValue isKindOfClass:[NSNull class]]) {
        if ([property.name isEqualToString:@"recommendedContent"]) {
            return @"";
        }else if([property.name isEqualToString:@"punchCount"]){
            return 0;
        }else if([property.name isEqualToString:@"headerUrl"]){
            return nil;
        }else if([property.name isEqualToString:@"recommendedDate"]){
            return @"0000000";
        }else if([property.name isEqualToString:@"todayMileage"]){
            return @"0";
        }else if([property.name isEqualToString:@"frequencyWeek"]){
            return 0;
        }
    }
    return oldValue;
}


@end
