//
//  ParentsManager.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParentsManager : NSObject

+ (instancetype)manager;
/**
 *  更新父母的体重
 *
 *  @return
 */
- (void)updateParentsWeight:(NSString *)parentsWeight
                     finish:(void(^)(BOOL success))finish
                      faile:(void(^)(NSError *error))faile;


@end
