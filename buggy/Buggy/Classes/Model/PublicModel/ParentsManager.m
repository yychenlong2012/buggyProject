//
//  ParentsManager.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "ParentsManager.h"

@implementation ParentsManager

+ (instancetype)manager
{
    static ParentsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ParentsManager alloc] init];
    });
    return instance;
}

- (void)updateParentsWeight:(NSString *)parentsWeight
                     finish:(void(^)(BOOL success))finish
                      faile:(void(^)(NSError *error))faile
{
    // 先查询，如果不存在,再创建新创建
    AVUser *_user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"totalCalories"];
    [query whereKey:@"post" equalTo:_user];
    __block AVObject *totalCalories;
    NSArray *objects = [query findObjects];
    if (objects.count > 0) {
        totalCalories = objects[0];
    }else{
        totalCalories = [AVObject objectWithClassName:@"totalCalories"];
    }
    [totalCalories setObject:parentsWeight forKey:@"adultWeight"];
    [totalCalories setObject:_user forKey:@"post"];
    [totalCalories setObject:_user.objectId forKey:@"postId"];
    [totalCalories saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            finish(succeeded);
        }
        if (error) faile(error);
    }];
}

@end
