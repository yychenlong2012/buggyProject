//
//  Check.h
//  Buggy
//
//  Created by 孟德林 on 16/8/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Bool.h"
@interface Check : NSObject

/**
 *  判断内容是否为空
 *
 *  @param string 字符串内容
 *
 *  @return
 */
+(BOOL)isNoNull:(NSString *)string;
/**
 *  检验号码
 *
 *  @param mobileNum 号码
 *
 *  @return YES or NO
 */
+ (BOOL)validateMobile:(NSString *)mobileNum;

/**
 *  正则匹配用户密码6-11位数字和字母组合
 *
 *  @param passWord
 *
 *  @return
 */
+ (BOOL)checkPassword:(NSString *) passWord;


/**
 是否是正确的成人体重

 @param string 成人体重

 @return
 */
+ (BOOL)AdultWeightIsRight:(NSString *)weight;


/**
 是否是全为数字

 @param string 字符串

 @return
 */
+ (BOOL)isAllNumber:(NSString *)string;

/* 是否含有中文 */
+ (BOOL)isHaveChineseInString:(NSString *)string;


/**
 设备名称是否为空，或者超过15个字节

 @param name
 @return 
 */
+ (BOOL)DeviceName:(NSString *)name;
@end
