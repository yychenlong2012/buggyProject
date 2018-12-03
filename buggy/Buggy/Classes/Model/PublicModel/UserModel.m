//
//  UserModel.m
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "UserModel.h"
#import <TMCache.h>

@implementation UserModel

+ (instancetype)model
{
    UserModel *model = [[UserModel alloc]init];
    return model;
}

// 获取宝宝信息(内部方法)
/*
 TripsIdentifierID     = 0;
 birthday              = "2014\U5e7409\U670811\U65e5";
 bluetoothBind         = 0;
 bluetoothUUID         = "841D8684-229B-70BF-4312-E14407345772";
 header =              "<AVFile: 0x1702a43e0>";
 name =                "\U4f60\U597d\U5440";
 native =              "\U5b81\U590f,\U94f6\U5ddd\U5e02";
 post =                "<AVUser, _User, 57aac0568ac247005f4c5988, localData:{\n    \"__type\" = Pointer;\n}, estimatedData:{\n}, relationData:{\n}>";
 sex =                 "\U5c0f\U738b\U5b50";
 
 */
//归档
//
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.name  forKey:@"name"];
//    [aCoder encodeObject:self.birthday  forKey:@"birthday"];
//    [aCoder encodeObject:self.userImage  forKey:@"userImage"];
//    [aCoder encodeObject:self.bluetoothUUID  forKey:@"bluetoothUUID"];
//    [aCoder encodeObject:self.native  forKey:@"native"];
//    [aCoder encodeObject:self.sex  forKey:@"sex"];
//    [aCoder encodeObject:self.age  forKey:@"age"];
//    [aCoder encodeObject:self.weight  forKey:@"weight"];
//    [aCoder encodeObject:self.height  forKey:@"height"];
//    [aCoder encodeObject:self.heightRange  forKey:@"heightRange"];
//    
//    [aCoder encodeObject:self.weightRange  forKey:@"weightRange"];
//}
//- (void)getBabyInfo:(void(^)(AVObject *baby, NSError *error))complete
//{
//    AVUser *_user = [AVUser currentUser];
//    AVQuery *query = [AVQuery queryWithClassName:@"BabyInfo"];
//    if (_user == nil) return;
//    [query whereKey:@"post" equalTo:_user];
//    __block AVObject *babyInfo;
//    NSError *error;
//    NSArray *objects =[query findObjects:&error];
//    if (objects.count > 0) {
//        babyInfo = objects[0];
//    }else{
//        babyInfo = [AVObject objectWithClassName:@"BabyInfo"];
//    }
//    complete(babyInfo,error);
//}

//- (void)getBabyBluetoothUUID:(void(^)(NSString *bluetooth,NSString *birthday))success{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self getBabyInfo:^(AVObject *baby, NSError *error) {
//            NSString *bluetoothStr = baby[@"bluetoothUUID"] == nil ? @"":baby[@"bluetoothUUID"];
//            NSString *birthday = baby[@"birthday"] == nil ? @"":baby[@"birthday"];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                success(bluetoothStr,birthday);
//            });
//        }];
//    });
//}

//- (void)getUserInfo:(void(^)(UserModel *userModel))block;
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UserModel *model = [self getUserInfo];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            block(model);
//        });
//    });
//}

// 内部方法
//- (UserModel *)getUserInfo
//{
//    NSTimeInterval start = CACurrentMediaTime();
//    DLog(@"加载前的时间:%@",[NSDate date]);
//    NSMutableDictionary *muDicInfo = [NSMutableDictionary dictionary];
//    __block NSError *error;
//    UserModel *model = [UserModel model];
//    __block AVObject *object;
//    [self getBabyInfo:^(AVObject *baby, NSError *err) {
//        object = baby;
//        error = err;
//    }];
//    model.name = [object objectForKey:@"name"];
//    model.birthday = [object objectForKey:@"birthday"];
//    model.userImage = [object objectForKey:@"header"];
//    model.sex = [object objectForKey:@"sex"];
//    model.bluetoothUUID = [object objectForKey:@"bluetoothUUID"];
//    model.native = [object objectForKey:@"native"];
//    muDicInfo = [object dictionaryForObject];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
//    NSDate *date = [dateFormatter dateFromString:model.birthday];
//    model.age = [self getAgeSince:date];
//
//    // 查询身高
//    AVUser *_user = [AVUser currentUser];
//    AVQuery *query = [AVQuery queryWithClassName:@"BabyHeight"];
//    [query whereKey:@"post" equalTo:_user];
//    [query orderByDescending:@"date"];
//    AVObject *heightObj = [query getFirstObject:&error];
//    model.height = [heightObj objectForKey:@"height"];
//    [muDicInfo setValue:model.height forKey:@"height"];
//
//    // 查询体重
//    query = [AVQuery queryWithClassName:@"BabyWeight"];
//    [query whereKey:@"post" equalTo:_user];
//    [query orderByDescending:@"date"];
//    AVObject *weightObj = [query getFirstObject:&error];
//    if (error) {
//
//    }
//    model.weight = [weightObj objectForKey:@"weight"];
//    [muDicInfo setValue:model.weight forKey:@"weight"];
//
//
//
//     #pragma mark --- Trale的详细数据
//
//    // 查询旅程
//    query = [AVQuery queryWithClassName:@"TravelInfo"];
//    [query whereKey:@"post" equalTo:_user];
//    [query orderByDescending:@"date"];
//    AVObject *tralveObj = [query getFirstObject:&error];
//    if (error) {
//    }
//    // 在这里我将日期的判定有time 改为 date
//    NSDate *today = [tralveObj objectForKey:@"date"];
//    NSDate *dateF = [NSDate date];
//    NSDateFormatter *dataFarmatter = [[NSDateFormatter alloc] init];
//    [dataFarmatter setDateFormat:@"yyyy-MM-dd"];
//
//    BOOL isToday = [[dataFarmatter stringFromDate:today] isEqualToString:[dataFarmatter stringFromDate:dateF]];
//    model.todayMilage = isToday? [tralveObj objectForKey:@"todayMileage"]:@"0";
//    model.totalMilage = [tralveObj objectForKey:@"totalMileage"];
//    model.todayVelocity = isToday? [tralveObj objectForKey:@"averageSpeed"]:@"0";
//    [muDicInfo setValue:model.todayMilage forKey:@"todayMilage"];
//    [muDicInfo setValue:model.totalMilage forKey:@"totalMilage"];
//    [muDicInfo setValue:model.todayVelocity forKey:@"todayVelocity"];
//
//    /* 今日卡路里 */
//    model.parentsTodayKcal = isToday?[tralveObj objectForKey:@"calorieValue"] : @"0";
//    [muDicInfo setValue:model.parentsTodayKcal forKey:@"parentsTodayKcal"];
//
//    /* 查询父母体重(直接查询,查询到的是否为空，为空则变为零) */
//    query = [AVQuery queryWithClassName:@"totalCalories"];
//    [query whereKey:@"post" equalTo:_user];
//    NSError *weightError;
//    NSArray *totalCalories = [query findObjects:&weightError];
//    if (totalCalories.count > 0) {
//        AVObject *object = totalCalories[0];
//        model.parentsWeight = [object objectForKey:@"adultWeight"];
//        /* 查询总的卡路里，查询是否为空，为空则默认为零 */
//        model.parentsTotalKcal = [object objectForKey:@"totalCaloriesValue"];
//    }else{
//        model.parentsWeight = @"0";
//        model.parentsTotalKcal = @"0";
//    }
//    [muDicInfo setValue:model.parentsWeight forKey:@"adultWeight"];
//    [muDicInfo setValue:model.parentsTotalKcal forKey:@"parentsTotalKcal"];
//    DLog(@"加载后的时间%f，加载的时间%f",CACurrentMediaTime(),CACurrentMediaTime()- start);
//    return model;
//}


//- (void)updateItemInBabyInfo:(NSString *)item key:(NSString *)key complete:(void (^)(NSString * item))success
//{
//    __block AVObject *babyInfo;
//    [self getBabyInfo:^(AVObject *baby, NSError *error) {
//        babyInfo = baby;
//    }];
//    [babyInfo setObject:item forKey:key];
//    [babyInfo setObject:[AVUser currentUser] forKey:@"post"];
//    [babyInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            success(item);
//        }else{
//            NSLog(@"Error:------%@",error);
//        }
//    }];
//}
//
//- (void)updateItemsInBabyInfo:(NSDictionary *)items complete:(void(^)(NSError *error))success
//{
//    __block AVObject *babyInfo;
//    [self getBabyInfo:^(AVObject *baby, NSError *error) {
//        if (error) {
//            success(error);
//            return ;
//        }
//        babyInfo = baby;
//    }];
//    NSArray *keys = items.allKeys;
//    NSArray *values = items.allValues;
//    for (int i = 0; i < keys.count; i ++) {
//        [babyInfo setObject:values[i] forKey:keys[i]];
//    }
//    [babyInfo setObject:[AVUser currentUser] forKey:@"post"];
//    [babyInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//        }else{
//            NSLog(@"Error:------%@",error);
//        }
//        success(error);
//    }];
//}
//
//- (void)uploadData:(NSData *)data complete:(void(^)(NSError *error))block
//{
//    AVFile *file = [AVFile fileWithData:data];
//    [file saveInBackground];
//    __block AVObject *userPost;
//    [self getBabyInfo:^(AVObject *baby, NSError *error) {
//        userPost = baby;
//    }];
//    [userPost setObject:file forKey:@"header"];
//    [userPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        block(error);
//    }];
//}
//
//- (void)uploadData:(NSData *)data name:(NSString *)name
//{
//    AVFile *file = [AVFile fileWithName:name data:data];
//    [file saveInBackground];
//}
- (NSDate *)getFarmatForm:(NSString *)fromDate interval:(NSInteger)interval
{
    NSDate *date = [self getDateWithDateString:fromDate];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:-interval];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
    return newdate;
}

-(NSDate*)getDateWithDateString:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

- (NSString *)getFormatString:(NSString *)date
{
    NSMutableString *muString = [NSMutableString stringWithString:date];
    [muString replaceOccurrencesOfString:@"-0" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, date.length)];
    return muString;
}

- (NSString *)getAgeSince:(NSDate *)date
{
    if (date == nil) {
        NSLog(@"UserModel 276");
        return @"";
    }
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *fromDate = [dateFormatter dateFromString:@"2014-06-23 12:02:03"];
    NSDate *toDate = [NSDate date];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:date toDate:toDate options:0];
    NSString *age = @"";
    NSInteger year = dayComponents.day/365;
    if (year > 0) {
        age = [NSString stringWithFormat:@"%ld岁",(long)year];
    }
    NSInteger month = (dayComponents.day%365)/30;
    if (month > 0) {
        age = [NSString stringWithFormat:@"%@%zd个月",age,month];
    }
    NSInteger day = (dayComponents.day%365)%30;
    if (day > 0) {
        age = [NSString stringWithFormat:@"%@%zd天",age,day];
    }
    return age;
}
//- (BOOL)hideVersionCell{
//    AVObject *todo = [AVObject objectWithClassName:@"AppControl" objectId:kAppControlID_2_0_0];
//    AVObject *avObject = [todo fetchIfNeeded];
//    NSString *hideVersion = [avObject objectForKey:@"HideVersionCell"];
//    return [hideVersion isEqualToString:@"1"]?YES:NO;
//}
//
//- (BOOL)hideOpenIDOAuth
//{
//    AVObject *todo =[AVObject objectWithClassName:@"AppControl" objectId:kAppControlID_2_0_0];
//    AVObject *avObject = [todo fetchIfNeeded];
//    NSString *hideOpenIDOAuth = [avObject objectForKey:@"hideOpenIDOAuth"];
//    return [hideOpenIDOAuth isEqualToString:@"1"] ? YES:NO;
//}
//
//- (BOOL)hasNewVersion
//{
//    NSTimeInterval time = CACurrentMediaTime();
//    AVObject *todo =[AVObject objectWithClassName:@"AppControl" objectId:kAppControlID_2_0_0];
//    AVObject *avObject = [todo fetchIfNeeded];
//    DLog(@"获取网上的版本消耗的时间:%f",CACurrentMediaTime() - time);
//    NSString *_newver = [avObject objectForKey:@"version"];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
//    // app版本
//    NSString *_oldver = [infoDictionary objectForKey:@"CFBundleShortVersionString"];     //获取项目版本号
//    NSArray *a1 = [_oldver componentsSeparatedByString:@"."];
//    NSArray *a2 = [_newver componentsSeparatedByString:@"."];
//    for (int i = 0; i < [a1 count]; i++) {
//        if ([a2 count] > i) {
//            if ([[a1 objectAtIndex:i] floatValue] < [[a2 objectAtIndex:i] floatValue]) {
//                return YES;
//            }
//            else if ([[a1 objectAtIndex:i] floatValue] > [[a2 objectAtIndex:i] floatValue])
//            {
//                return NO;
//            }
//        }
//        else
//        {
//            return NO;
//        }
//    }
//    DLog(@"检查更新消耗的时间%f",CACurrentMediaTime() - time);
//    return [a1 count] < [a2 count];
//}

//对上面的优化
//-(void)getNewestVersion:(void (^)(AVObject *object,NSError *error))success{
//
//    AVQuery *query = [AVQuery queryWithClassName:@"AppControl"];
//
//    [query orderByDescending:@"createdAt"];
//
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//
//        success(object,error);
//    }];
//
//}

@end
