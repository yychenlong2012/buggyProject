//
//  CacheManager.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (instancetype)manager;

- (void)saveLocalData:(id <NSCoding>)data name:(NSString *)name;

- (void)getLocalData:(NSString *)key complete:(void(^)(NSObject *object))success;

- (NSString *)cachePathWithName:(NSString *)name;


@end
