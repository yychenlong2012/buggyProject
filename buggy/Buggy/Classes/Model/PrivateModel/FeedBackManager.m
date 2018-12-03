//
//  FeedBackManager.m
//  Buggy
//
//  Created by 孟德林 on 16/10/9.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "FeedBackManager.h"
#import <AVOSCloud.h>
#import "BabyModel.h"
@implementation FeedBackManager

//+ (void)feedBackWithSomeThings:(NSString *)things
//                       success:(void(^)(BOOL sucess))success
//                         faile:(void(^)(NSError *faile))faile{
//    AVUser *_user = [AVUser currentUser];
//    AVQuery *query = [AVQuery queryWithClassName:@"FeedBack"];
//    [query whereKey:@"user" equalTo:_user];
//    [query whereKey:@"date" equalTo:[NSDate new]];
//    __block AVObject *feedBack;
//    NSError *error;
//    NSArray *objects = [query findObjects:&error];
//    if (objects.count > 0) {
//        feedBack = objects[0];
//    }else{
//        feedBack = [AVObject objectWithClassName:@"FeedBack"];
//    }
//    [feedBack setObject:things forKey:@"feedBackContent"];
//    [feedBack setObject:[NSDate new] forKey:@"date"];
//    [feedBack setObject:([BabyModel manager].name == nil? @"" :[BabyModel manager].name) forKey:@"userName"];
//    [feedBack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            success(succeeded);
//        }
//        if (error) faile(error);
//    }];
//}

+ (void)feedBackWithSomeThings:(NSString *)things
                       success:(void(^)(BOOL sucess))success
                         faile:(void(^)(NSError *faile))faile{
    NSString *nickName = [[AVUser currentUser] objectForKey:@"nickName"];
    
    AVObject *obj = [AVObject objectWithClassName:@"FeedBack"];
    [obj setObject:[AVUser currentUser] forKey:@"user"];
    [obj setObject:things forKey:@"feedBackContent"];
    [obj setObject:[NSDate new] forKey:@"date"];
    [obj setObject:nickName forKey:@"userName"];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            if (success) {
               success(succeeded);
            }
        }
        if (error){
            if (faile) {
                faile(error);
            }
        }
    }];
}
@end
