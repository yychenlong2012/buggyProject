//
//  HealthModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/2/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "HealthModel.h"
@implementation HealthModel

+ (instancetype)manager
{
    static HealthModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthModel alloc] init];
    });
    return instance;
}

- (void)getTodayHeightAndWeight:(void(^)(HealthModel *model,NSError *error))complement{
    
//    NSTimeInterval time = CACurrentMediaTime();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSError *error;
        // 查询身高
        AVUser *user = [AVUser currentUser];
        AVQuery *query = [AVQuery queryWithClassName:@"BabyHeight"];
        [query whereKey:@"post" equalTo:user];
        [query orderByDescending:@"date"];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                self.height = [object objectForKey:@"height"];
                if (complement) {
                    complement(self,error);
                }
            }
            
        }];
//        AVObject *heightObj = [query getFirstObject:&error];
//        self.height = [heightObj objectForKey:@"height"];
        
        // 查询体重
        query = [AVQuery queryWithClassName:@"BabyWeight"];
        [query whereKey:@"post" equalTo:user];
        [query orderByDescending:@"date"];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                self.weight = [object objectForKey:@"weight"];
                [self getHeathState:[BabyModel manager].birthday gender:[BabyModel manager].sex complete:^(NSArray *array) {
                    if (array.count > 0) {
                        AVObject *object = [array firstObject];
                        self.heightRange = object[@"heightRange"];
                        self.weightRange = object[@"weightRange"];
                    }
                    if (complement) {
                        complement(self,error);
                    }
                }];
            }
        }];
        

//        AVObject *weightObj = [query getFirstObject:&error];
//        self.weight = [weightObj objectForKey:@"weight"];
//        [self getHeathState:[BabyModel manager].birthday gender:[BabyModel manager].sex complete:^(NSArray *array) {
//            if (array.count > 0) {
//                AVObject *object = [array firstObject];
//                self.heightRange = object[@"heightRange"];
//                self.weightRange = object[@"weightRange"];
//            }
//            if (complement) {
//                complement(self,error);
//            }
//        }];
    });
//    DLog(@"加载体重和身高消耗的时间:%f",CACurrentMediaTime() - time);
}

+ (void)postWeight:(NSString *)weight date:(NSString *)date complete:(void(^)(NSString *weight, NSString *date))success
{
    date = [self getFormatString:date];
    NSDate *dateD = [self getDateWithDateString:[NSString stringWithFormat:@"%@ 00:00:00",date]];
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyWeight"];
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"date" equalTo:dateD];
    __block AVObject *weightInfo;
    NSError *error;
    NSArray *objects =[query findObjects:&error];
    if (objects.count > 0) {
        weightInfo = objects[0];
    }else{
        weightInfo = [AVObject objectWithClassName:@"BabyWeight"];
    }
    [weightInfo setObject:weight forKey:@"weight"];
    [weightInfo setObject:date forKey:@"time"];
    [weightInfo setObject:_user forKey:@"post"];
    [weightInfo setObject:dateD forKey:@"date"];
    [weightInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            success(weight,date);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

+ (void)getWeightStartDate:(NSString *)date complete:(void(^)(NSArray *dates))success
{
    NSDate *nowDate = [self getDateWithDateString:date];
    NSDate *sincenDate = [self getFarmatForm:date interval:30];
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyWeight"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"date"];
    [query whereKey:@"date" lessThanOrEqualTo:nowDate];
    [query whereKey:@"date" greaterThanOrEqualTo:sincenDate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"DATES-----%@",objects);
        if (objects.count == 0) {
            [self showErrorMessage:error];
        }else{
            success(objects);
        }
    }];
}

+ (void)getWeightWithPage:(NSInteger)Page complete:(void(^)(NSArray *dates))success
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyWeight"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"date"];
    query.skip = 10 * Page;
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count >0 && error.code == 0) {
            NSEnumerator *enumerator = [objects reverseObjectEnumerator];
            objects = (NSMutableArray*)[enumerator allObjects];
            success(objects);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

+ (void)deleteWeight:(NSDate *)date complete:(void(^)(NSError *error))block
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyWeight"];
    [query whereKey:@"date" equalTo:date];
    [query whereKey:@"post" equalTo:_user];
    NSArray *objects = [query findObjects];
    NSError *error;
    if (objects.count > 0) {
        AVObject *obj = [objects firstObject];
        [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                block(error);
            }else{
                [self showErrorMessage:error];
            }
        }];
    }else{
        block(error);
    }
}


#pragma mark -- Height
+ (void)postHeight:(NSString *)height date:(NSString *)date complete:(void(^)(NSString *height, NSString *date))success
{
    date = [self getFormatString:date];
    NSDate *dateD = [self getDateWithDateString:[NSString stringWithFormat:@"%@ 00:00:00",date]];
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyHeight"];
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"date" equalTo:dateD];
    __block AVObject *heightInfo;
    NSError *error;
    NSArray *objects =[query findObjects:&error];
    if (objects.count > 0) {
        heightInfo = objects[0];
    }else{
        heightInfo = [AVObject objectWithClassName:@"BabyHeight"];
    }
    [heightInfo setObject:height forKey:@"height"];
    [heightInfo setObject:date forKey:@"time"];
    [heightInfo setObject:_user forKey:@"post"];
    [heightInfo setObject:dateD forKey:@"date"];
    [heightInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            success(height,date);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

+ (void)getHeightStartDate:(NSString *)date complete:(void(^)(NSArray *dates))success{
    
    
};

+ (void)getHeightWithPage:(NSInteger)page complete:(void(^)(NSArray *dates))success
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyHeight"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"date"];
    query.limit = 10;
    query.skip = 10 * page;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0 ) {
            NSEnumerator *enumerator = [objects reverseObjectEnumerator];
            objects = (NSMutableArray*)[enumerator allObjects];
            success(objects);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

- (void)getHeathState:(NSString *)age gender:(NSString *)gender complete:(void(^)(NSArray *array))success
{
    if (age.length == 0 || gender.length == 0) {
        success(nil);
        return;
    }
    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date = [dateF dateFromString:age];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *fromDate = [dateFormatter dateFromString:@"2014-06-23 12:02:03"];
    NSDate *toDate = [NSDate date];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:date toDate:toDate options:0];
    NSString *param;
    NSInteger year = dayComponents.day/365;
    
    param = [NSString stringWithFormat:@"%ld",(long)year];
    
    NSInteger month = (dayComponents.day%365)/30;
    param = [NSString stringWithFormat:@"%@-%ld",param,(long)month];
    AVQuery *query = [AVQuery queryWithClassName:@"HealthState"];
    [query whereKey:@"age" equalTo:param];
    [query whereKey:@"sex" equalTo:gender];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && error.code == 0) {
            success(objects);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

+ (void)deleteHeight:(NSDate *)date complete:(void(^)(NSError *error))block
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyHeight"];
    [query whereKey:@"date" equalTo:date];
    [query whereKey:@"post" equalTo:_user];
    NSArray *objects = [query findObjects];
    NSError *error;
    if (objects.count > 0) {
        AVObject *obj = [objects firstObject];
        [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                 block(error);
            }else{
                [self showErrorMessage:error];
            }
        }];
    }else{
        block(error);
    }
}

+ (NSDate *)getFarmatForm:(NSString *)fromDate interval:(NSInteger)interval
{
    NSDate *date = [self getDateWithDateString:fromDate];
    //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:-interval];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
    return newdate;
}

+ (NSDate*)getDateWithDateString:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

+ (NSString *)getFormatString:(NSString *)date
{
    NSMutableString *muString = [NSMutableString stringWithString:date];
    [muString replaceOccurrencesOfString:@"-0" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, date.length)];
    return muString;
}

//如果字符串为NULL就转化为“”
- (NSString *)weight{
    
    if ([NSString isNull:_weight]) {
         return @"0";
    }
    return [NSString convertNull:_weight];
}

- (NSString *)weightRange{
    return [NSString convertNull:_weightRange];
}

- (NSString *)height{
    if ([NSString isNull:_height]) {
        return @"0";
    }
    return [NSString convertNull:_height];
}

- (NSString *)heightRange{
    return [NSString convertNull:_heightRange];
}
@end
