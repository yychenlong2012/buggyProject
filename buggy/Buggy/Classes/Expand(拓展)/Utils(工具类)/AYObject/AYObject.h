//
//  CWParentModel.h
//  CarWins
//
//  Created by zrg on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AYObject : NSObject


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
