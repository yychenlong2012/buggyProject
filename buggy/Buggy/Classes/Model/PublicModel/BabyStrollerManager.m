//
//  BabyStrollerManager.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BabyStrollerManager.h"
#import "MainModel.h"
// 请求表的类型
typedef enum : NSUInteger {
    FETCHTABLENAME_A1 = 0, // A1 版车的数据模型
    FETCHTABLENAME_A3 = 1  // A2 新版车数据模型
} FETCHTABLENAMETYPE;

@implementation BabyStrollerManager

+ (void)postA1Travel:(NSDictionary *)param complete:(CompleteHander )success{
    [BabyStrollerManager postTravel:param tableType:FETCHTABLENAME_A1 complete:success];
}

+ (void)postA3Travel:(NSDictionary *)param complete:(CompleteHander )success{
    [BabyStrollerManager postTravel:param tableType:FETCHTABLENAME_A3 complete:success];
}

+ (void)postTravel:(NSDictionary *)param tableType:(FETCHTABLENAMETYPE )tableType complete:(CompleteHander )success{
    NSString *date = param[@"time"];
    NSString *bluetoothUUID = param[@"bluetoothUUID"];
    [[NSUserDefaults standardUserDefaults] setObject:bluetoothUUID forKey:BLUETOOTHUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    date = [self getFormatString:date];
    NSDate *dateD = [self getDateWithDateString:[NSString stringWithFormat:@"%@ 00:00:00",date]];
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"TravelInfo"];
    if (_user == nil) return;
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"date" equalTo:dateD];
    [query whereKey:@"bluetoothUUID" equalTo:bluetoothUUID];
    __block AVObject *travelInfo;
    NSError *error;
    NSArray *objects =[query findObjects:&error];
    
    if (objects.count > 0) {
        travelInfo = objects[0];
    }else{
        travelInfo = [AVObject objectWithClassName:@"TravelInfo"];
    }
    
    NSInteger deviceType = 0;
    if (tableType == FETCHTABLENAME_A1) {
        deviceType = 0;
    }else if (deviceType == FETCHTABLENAME_A3){
        deviceType = 1;
    }
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc]initWithDictionary:param];
    [muDic setValue:date forKey:@"date"];
    NSArray *keys = muDic.allKeys;
    NSArray *values = muDic.allValues;
    for (int i = 0; i < keys.count; i ++) {
        if (![keys[i] isEqualToString:@"calorieValue"]) {
            [travelInfo setObject:values[i] forKey:keys[i]];
        }
    }
    [travelInfo setObject:_user forKey:@"post"];
    [travelInfo setObject:dateD forKey:@"date"];
    [travelInfo setObject:bluetoothUUID forKey:@"bluetoothUUID"];
    [travelInfo setObject:@(deviceType)  forKey:@"deviceType"];
    
    [travelInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            success(param,YES);
        }else{
            DLog(@"Error:------%@",error);
            success(param,NO);
        }
    }];
}

+ (void)getTravelWithPage:(NSInteger)page complete:(void(^)(NSArray *datas))success
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"TravelInfo"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"date"];
    query.limit = 7;
    query.skip = 7 * page;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSEnumerator *enumerator = [objects reverseObjectEnumerator];
        objects = (NSMutableArray*)[enumerator allObjects];
        AVObject *latestDic = [objects lastObject];
        NSDate *latestDay = [latestDic objectForKey:@"time"];
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
        [dateFarmatter setDateFormat:@"yyyy-MM-dd"];
        BOOL isToday = [[dateFarmatter stringFromDate:latestDay] isEqualToString:[dateFarmatter stringFromDate:today]];
        if (isToday) {
            success(objects);
        }else{
            [latestDic setObject:@"0.0" forKey:@"averageSpeed"];
            [latestDic setObject:@"0.0" forKey:@"todayMileage"];
            //不要同步到后台数据库中，只是为了展示数据
            success(objects);
        }
    }];
}

+ (NSString *)getFormatString:(NSString *)date
{
    NSMutableString *muString = [NSMutableString stringWithString:date];
    [muString replaceOccurrencesOfString:@"-0" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, date.length)];
    return muString;
}

+ (NSDate*)getDateWithDateString:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

@end
