//
//  CacheManager.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "CacheManager.h"
#import <TMCache.h>
@implementation CacheManager

+ (instancetype)manager
{
    static CacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CacheManager alloc] init];
    });
    return instance;
}

- (void)saveLocalData:(id <NSCoding>)data name:(NSString *)name;
{
    AVUser *user = [AVUser currentUser];
    name = [NSString stringWithFormat:@"%@%@",name,user.objectId];
    [[TMCache sharedCache] setObject:data forKey:name block:^(TMCache *cache, NSString *key, id object) {
    }];
}

- (void)getLocalData:(NSString *)key complete:(void(^)(NSObject *object))success;
{
    AVUser *user = [AVUser currentUser];
    key = [NSString stringWithFormat:@"%@%@",key,user.objectId];
    [[TMCache sharedCache]objectForKey:key block:^(TMCache *cache, NSString *key, id object) {
        success(object);
    }];
}

- (NSString *)cachePathWithName:(NSString *)name{
    
    return [NSString stringWithFormat:@"%@/%@",[self cacheBasePath],name];
    
}

- (NSString *)cacheBasePath{
    
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

@end
