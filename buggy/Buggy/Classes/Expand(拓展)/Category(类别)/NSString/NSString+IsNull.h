//
//  NSString+IsNull.h
//  CarWins
//
//  Created by zheng on 16/4/28.
//  Copyright © 2016年 CarWins Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IsNull)

/**
 *  判断当前字符串是否为空串
 *
 *  @return YES/NO
 */
+ (BOOL)isNull:(NSString *)obejct;

/**
 *  自动转换当前字符串为nil时返回@""
 *
 *  @return NSString
 */
+ (NSString *)convertNull:(NSString *)obejct;

@end
