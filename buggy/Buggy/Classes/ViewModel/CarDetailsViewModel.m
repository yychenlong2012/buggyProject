//
//  CarDetailsViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarDetailsViewModel.h"
#import <AVOSCloud.h>
#import "NSDate+Mac.h"
#import "MainModel.h"
@implementation CarDetailsViewModel

+ (void)getCarKcalType:(FETCHTABLENAMETYPE)type UUID:(NSString *)UUID Model:(void(^)(CarKcalModel *carKcalModel ,NSError *error))finish{
    
//    NSString *tableName;
//    switch (type) {
//        case FETCHTABLENAME_A1:
//        {
//            tableName = @"TravelInfo";
//        }
//            break;
//        case FETCHTABLENAME_A3:
//        {
//            tableName = @"TravelInfo";
//        }
//            break;
//        default:
//            break;
//    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 查询旅程
        AVUser *_user = [AVUser currentUser];
        NSError *error;
        CarKcalModel *model = [[CarKcalModel alloc] init];
        AVQuery *query;
        
        query.cachePolicy = kAVCachePolicyNetworkElseCache;
        query.maxCacheAge = MAXFLOAT;
        query = [AVQuery queryWithClassName:@"TravelInfo"];
        [query whereKey:@"post" equalTo:_user];
        [query whereKey:@"bluetoothUUID" equalTo:UUID];
        [query orderByDescending:@"date"];
        AVObject *tralveObj = [query getFirstObject:&error];
        NSLog(@"%@",tralveObj);
        if (error) {
        }
        // 在这里我将日期的判定有time 改为 date
        NSDate *today = [tralveObj objectForKey:@"date"];
        NSDate *dateF = [NSDate date];
        NSDateFormatter *dataFarmatter = [[NSDateFormatter alloc] init];
        [dataFarmatter setDateFormat:@"yyyy-MM-dd"];
        
        BOOL isToday = [[dataFarmatter stringFromDate:today] isEqualToString:[dataFarmatter stringFromDate:dateF]];
        model.todayMilage = [NSString stringWithFormat:@"%0.2f",isToday? [[tralveObj objectForKey:@"todayMileage"] floatValue]:0];
        model.totalMilage = [tralveObj objectForKey:@"totalMileage"];
        model.todayVelocity = isToday? [tralveObj objectForKey:@"averageSpeed"]:@"0";
        
        /* 今日卡路里 */
        model.parentsTodayKcal = isToday?[tralveObj objectForKey:@"calorieValue"] : @"0";
        
        /* 查询父母体重(直接查询,查询到的是否为空，为空则变为零) */
        query = [AVQuery queryWithClassName:@"totalCalories"];
        [query whereKey:@"post" equalTo:_user];
        
        NSArray *totalCalories = [query findObjects:&error];
        if (totalCalories.count > 0) {
            AVObject *object = totalCalories[0];
            model.parentsWeight = [object objectForKey:@"adultWeight"];
            /* 查询总的卡路里，查询是否为空，为空则默认为零 */
            model.parentsTotalKcal = [object objectForKey:@"totalCaloriesValue"];
        }else{
            model.parentsWeight = @"0";
            model.parentsTotalKcal = @"0";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            DLog(@"今日里程 :%.2lf 总里程：%@ 今日平均速度：%@ 父母体重：%@ 父母今日卡路里：%@ 父母总卡路里：%@",model.todayMilage,model.totalMilage,model.todayVelocity,model.parentsWeight,model.parentsTodayKcal,model.parentsTotalKcal);
            if (finish) {
                finish(model,error);
            }
        });
    });
}

+ (void)postTravel:(NSDictionary *)param tableType:(FETCHTABLENAMETYPE )tableType complete:(CompleteHander )success{
    
    NSString *date = param[@"time"];
    NSString *bluetoothUUID = param[@"bluetoothUUID"];
    [[NSUserDefaults standardUserDefaults] setObject:bluetoothUUID forKey:BLUETOOTHUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    date = [self getFormatString:date];
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
    [muDic setValue:date forKey:@"time"];
    NSArray *keys = muDic.allKeys;
    NSArray *values = muDic.allValues;
    for (int i = 0; i < keys.count; i ++) {
        [travelInfo setObject:values[i] forKey:keys[i]];
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
+ (NSDate*)getDateWithDateString:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}
+ (NSData *)getDeviceTravelData{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0B,0xea};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//请求设备状态   开启监听
+ (NSData *)getDeviceStatus{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0c,0xe9};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//设置一键防盗
+ (NSData *)setAntiTheft{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x05,0xF0};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//取消一键防盗
+ (NSData *)setCancelAntiTheft{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x06,0xEF};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//开启智能刹车
+ (NSData *)setBraking{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0E,0xE7};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//关闭智能刹车
+ (NSData *)setRelieveBraking{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0D,0xE8};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
+ (NSData *)getBattery{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0b,0x07,0xEE};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (NSData *)setCloseDevice{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0b,0xaa,0x4b};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (NSData *)setBacklight:(BACKLIGHT_TYPE )type{
    Byte typeBy;
    switch (type) {
        case BACKLIGHT_CLOSE:
            typeBy = 0x00;
            break;
        case BACKLIGHT_ONE:
            typeBy = 0x01;
            break;
        case BACKLIGHT_TWO:
            typeBy = 0x02;
            break;
        case BACKLIGHT_THREE:
            typeBy = 0x03;
            break;
        case BACKLIGHT_FOUR:
            typeBy = 0x04;
            break;
        case BACKLIGHT_FIVE:
            typeBy = 0x05;
            break;
        case BACKLIGHT_SIX:
            typeBy = 0x06;
            break;
        default:
            break;
    }
    Byte byte[] = {0x55,0xAA,0x01,0x0b,0x09,typeBy,0 - (1 + 0x09 + 0x0b + typeBy)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

+ (NSData *)setSynchronizationTime{
    NSDate *date = [NSDate date];
    NSUInteger year = [date year];
    NSUInteger yearNew = year - 2000;
    NSUInteger mouth = [date month];
    NSUInteger day = [date day];
    NSUInteger hour = [date hour];
    NSUInteger min = [date minute];
    NSUInteger second = [date second];
    
    
    Byte yearByte = [self getByte:yearNew];
    Byte mouthByte = [self getByte:mouth];
    Byte dayByte = [self getByte:day];
    Byte hourByte = [self getByte:hour];
    Byte minByte = [self getByte:min];
    Byte secondByte = [self getByte:second];
    
    DLog(@"%hhu %hhu %hhu %hhu %hhu %hhu",yearByte,mouthByte,dayByte,hourByte,minByte,secondByte);
    Byte checkSum = 0 - (16 + yearByte + mouthByte + dayByte + hourByte + minByte + secondByte);
    Byte byte[] = {0x55,0xAA,0X06,0x0b,0x0a,yearByte,mouthByte,dayByte,hourByte,minByte,secondByte,checkSum};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (Byte)getByte:(NSUInteger)num{
    NSData *dateioero = [self convertHexStrToData:[self ToHex:num]];
    Byte *bytetim = (Byte *)[dateioero bytes];
    return bytetim[0];
}

+ (NSData *)checkAndRepairDevice{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0b,0x55,0xA0};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (NSData *)getLogInfo{
    
    Byte byte[] = {0x55,0xAA,0X00,0x0b,0x08,0xED};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (NSData *)getDeviceVersion{
    
    Byte byte[] = {0x55,0xAA,0x00,0x0b,0x0b,0xEA};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

+ (NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;  
        }
    }  
    return str;  
}

//将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}


@end
