//
//  TripsManager.m
//  Buggy
//
//  Created by 孟德林 on 16/9/19.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "TripsManager.h"
#import <TMCache.h>
#import "CalendarHelper.h"
@implementation TripsManager

+(void)getIsHasStorePathIdentifier:(void(^)(NSString *))success
                             faile:(void(^)(NSError *error))faile{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getBabyInfo:^(AVObject *baby, NSError *error) {
            NSString *trips = baby[@"TripsIdentifierID"];
            if (trips) {
                if (success) success(trips);
            }else{
                if (faile) faile(error);
            }
        }];
//    });
}
+(void)updateIsHasStorePathIdentifier:(NSString *)identifier
                              success:(void(^)(BOOL json))success
                                faile:(void(^)(NSError *error))faile{
    
    __block AVObject *babyInfo;
    [self getBabyInfo:^(AVObject *baby, NSError *error) {
        if (error) {
            faile(error);
            return ;
        }
        babyInfo = baby;
    }];
    [babyInfo setObject:identifier forKey:@"TripsIdentifierID"];
    [babyInfo setObject:[AVUser currentUser] forKey:@"post"];
    [babyInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            success(succeeded);
        }else{
            faile(error);
        }
    }];
}

#pragma mark --- 0 用户正在上传数据  1 结束上传数据
+(void)beginUploadLocationArray:(NSDictionary *)location
                   success:(void(^)(BOOL finish))sucess
                          faile:(void(^)(NSError *))faile{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"LocationArray"];
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"isAddLocation" equalTo:@"0"];
    __block AVObject *locationObject;
    NSError *findError;
    NSArray *objects = [query findObjects:&findError];
    if (objects.count > 0) {
        locationObject = objects[0];
        [locationObject addObject:location forKey:@"locationAssemble"];
        [locationObject setObject:_user forKey:@"post"];
//        [locationObject setObject:[CalendarHelper transformDateFormat:[NSDate new]] forKey:@"StartDate"];
        [locationObject saveInBackground];
    }else{
        locationObject = [AVObject objectWithClassName:@"LocationArray"];
        NSArray *array = @[location];
        [locationObject setObject:array forKey:@"locationAssemble"];
        [locationObject setObject:_user forKey:@"post"];
        [locationObject setObject:@"0" forKey:@"isAddLocation"];
        [locationObject setObject:[CalendarHelper transformDateFormat:[NSDate new]] forKey:@"StartDate"];
        [locationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                sucess(succeeded);
            }else{
                faile(error);
            }
        }];
    }
}

+(void)endUploadLocationArray:(CLLocation *)location
                      success:(void (^)(BOOL finish))sucess
                        faile:(void (^)(NSError *))faile{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"LocationArray"];
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"isAddLocation" equalTo:@"0"];
    NSError *findError;
    NSArray *objects = [query findObjects:&findError];
    if (objects.count > 0) {
        AVObject *locationObject = objects[0];
        [locationObject setObject:@"1" forKey:@"isAddLocation"];
        [locationObject setObject:[CalendarHelper transformDateFormat:[NSDate new]] forKey:@"endDate"];
        [locationObject setObject:_user forKey:@"post"];
        [locationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                sucess(succeeded);
            }else{
                faile(error);
            }
        }];
    }
}

+(void)getLocationArraySuccess:(void(^)(NSArray *arrayLocation,NSError *error))success{
    // 在获取的时候获取 isAddLocation值为0 （还没有完成的哪一组数据）
    AVUser *_user = [AVUser currentUser];
    AVQuery *query  =[AVQuery queryWithClassName:@"LocationArray"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"isAddLocation" equalTo:@"0"];
    NSError *findError;
    AVObject *object = [query getFirstObject:&findError];
    NSArray *array = [object objectForKey:@"locationAssemble"];
    success(array ,findError);
}

+(void)getHistoryTrackRecordWithPage:(NSInteger)page
                             suceess:(void(^)(NSArray *loctionArray)) success
                               faile:(void(^)(NSError *error))faile{
    
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"LocationArray"];
    [query whereKey:@"post" equalTo:_user];
    [query orderByDescending:@"endDate"];
    [query whereKey:@"isAddLocation" equalTo:@"1"];
    query.limit = 10;
    query.skip = 10 * page;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // 解析模型
        //        "<AVObject, LocationArray, 57ea1c47816dfa005efbe394, localData:{\n    endDate = \"2016-09-28 07:18:23 +0000\";\n    isAddLocation = 1;\n
        //        locationAssemble =     ( \"<AVGeoPoint: 0x150068620>\",\"<AVGeoPoint: 0x150068700>\",\"<AVGeoPoint: 0x150068720>\"\n);
        
        //                                post = \"<AVUser, _User, 57aac0568ac247005f4c5988,
        //                                localData:{\\n    \\\"__type\\\" = Pointer;\\n}, estimatedData:{\\n}, relationData:{\\n}>\";\n}, estimatedData:                 {\n}, relationData:{\n}>"
        if (success) {
            success(objects);
        }else{
            faile(error);
        }
    }];
}
+(void)deleteHistoryTrackRecordWith:(NSDate *)date
                           complete:(void(^)(BOOL success, NSError *error))complete{
    
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"LocationArray"];
    [query whereKey:@"post" equalTo:_user];
    [query whereKey:@"StartDate" equalTo:date];
    NSError *error;
    NSArray *objects = [query findObjects:&error];
    if (objects.count > 0) {
        AVObject *obj = [objects firstObject];
        [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            complete(succeeded,error);
        }];
    }else{
        complete(NO,error);
    }
}

+ (void)getBabyInfo:(void(^)(AVObject *baby, NSError *error))complete
{
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"BabyInfo"];
    if (_user == nil) return;
    [query whereKey:@"post" equalTo:_user];
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
@end
