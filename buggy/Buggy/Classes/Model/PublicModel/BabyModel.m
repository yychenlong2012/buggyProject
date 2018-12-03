//
//  BabyModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/2/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BabyModel.h"
#import "MainModel.h"

@implementation BabyModel

+ (instancetype)manager
{
    static BabyModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BabyModel alloc] init];
    });
    return instance;
}

- (void)getBaby:(void(^)(AVObject *baby,NSError *error))complete{
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyInfo"];
    if (user == nil) return;
    [query whereKey:@"post" equalTo:user];
    __block AVObject *babyInfo;
    NSError *error;
    NSArray *objects =[query findObjects:&error];
    if (objects.count > 0) {
        babyInfo = objects[0];
    }else{
        babyInfo = [AVObject objectWithClassName:@"BabyInfo"];
    }
    complete(babyInfo,error);
}


- (void)getBabyInfo:(void(^)(BabyModel *babyModel))model{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *error;
        __block AVObject *object;
        [self getBaby:^(AVObject *baby, NSError *err) {
            object = baby;
            error = err;
            if (object == nil) {
                return ;
            }
            
            self.name = [object objectForKey:@"name"] == nil ? @"小宝宝":[object objectForKey:@"name"];
            self.birthday = [object objectForKey:@"birthday"] == nil ?@"0": [object objectForKey:@"birthday"];
            self.userImage = [object objectForKey:@"header"] == nil ? nil: [object objectForKey:@"header"];
            self.sex = [object objectForKey:@"sex"] == nil ? @"":[object objectForKey:@"sex"];
            self.bluetoothUUID = [object objectForKey:@"bluetoothUUID"] == nil ? @"": [object objectForKey:@"bluetoothUUID"];
            self.native = [object objectForKey:@"native"] == nil ? @"":[object objectForKey:@"native"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            NSDate *date = [dateFormatter dateFromString:self.birthday];
            //        if (!date) {xxxxxxxx
            //            self.age = [self getAgeSince:[NSData new]];
            //        }else{
            //        self.age = [self getAgeSince:date];
            //        }
            if (self.birthday != nil) {
                self.age = [self getAgeSince:date];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model) {
                    model(self);
                }
            });

        }];
    });
}

//更新info中的部分数据
- (void)updateItemInBabyInfo:(NSString *)item key:(NSString *)key complete:(void (^)(NSString * item))success
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block AVObject *babyInfo;
        [self getBaby:^(AVObject *baby, NSError *error) {
            babyInfo = baby;
            if (babyInfo) {
                
                [babyInfo setObject:item forKey:key];
                [babyInfo setObject:[AVUser currentUser] forKey:@"post"];
                [babyInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        if (success) {
                            success(item);
                        }
                    }else{
                        [self showErrorMessage:error];
                    }
                }];
            }
        }];
    });
}

- (void)updateItemsInBabyInfo:(NSDictionary *)items complete:(void(^)(NSError *error))success
{
    __block AVObject *babyInfo;
    [self getBaby:^(AVObject *baby, NSError *error) {
        if (error) {
            success(error);
            return ;
        }
        babyInfo = baby;
    }];
    NSArray *keys = items.allKeys;
    NSArray *values = items.allValues;
    for (int i = 0; i < keys.count; i ++) {
        [babyInfo setObject:values[i] forKey:keys[i]];
    }
    [babyInfo setObject:[AVUser currentUser] forKey:@"post"];
    [babyInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        }else{
            [self showErrorMessage:error];
        }
        success(error);
    }];
}

- (void)uploadData:(NSData *)data complete:(void(^)(NSError *error))block
{
    AVFile *file = [AVFile fileWithData:data];
    [file saveInBackground];
    __block AVObject *userPost;
    [self getBaby:^(AVObject *baby, NSError *error) {
        userPost = baby;
    }];
    [userPost setObject:file forKey:@"header"];
    [userPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            block(error);
        }else{
            [self showErrorMessage:error];
        }
    }];
}

- (void)uploadData:(NSData *)data name:(NSString *)name
{
    AVFile *file = [AVFile fileWithName:name data:data];
    [file saveInBackground];
}

- (NSString *)getAgeSince:(NSDate *)date
{
    if (date == nil) {
        NSLog(@"BabyModel 154");
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
        age = [NSString stringWithFormat:@"%@%ld个月",age,month];
    }
    NSInteger day = (dayComponents.day%365)%30;
    if (day > 0) {
        age = [NSString stringWithFormat:@"%@%ld天",age,day];
    }else{
        age = [NSString stringWithFormat:@"%@%d天",age,1];
    }
    return age;
}
@end
