//
//  NSString+IsNull.m
//  CarWins
//
//  Created by zheng on 16/4/28.
//  Copyright © 2016年 CarWins Inc. All rights reserved.
//

#import "NSString+IsNull.h"

@implementation NSString (IsNull)

+ (BOOL)isNull:(NSString *)obejct
{
    // 判断是否为空串
    if ([obejct isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([obejct isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (obejct == nil){
        return YES;
    }
    else if (kStringByObject(obejct).length == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)convertNull:(NSString *)obejct
{
    // 转换空串
    if ([NSString isNull:obejct]) {
        return @"";
    }
    return obejct;
}

@end
