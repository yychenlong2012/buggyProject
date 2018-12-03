//
//  NSObject+ShowErrorMessage.h
//  Buggy
//
//  Created by goat on 2017/8/8.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ShowErrorMessage)
- (void) showErrorMessage:(NSError *)error;
+ (void)showErrorMessage:(NSError *)error;


/**
 *  用Json字典实例化数据实体
 *
 *  @param dict 字典
 *
 *  @return 数据实体
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 *  在未定义的情况下调用该方法
 *
 *  @param value value description
 *  @param key
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end
