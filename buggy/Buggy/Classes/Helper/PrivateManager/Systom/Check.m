//
//  Check.m
//  Buggy
//
//  Created by 孟德林 on 16/8/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "Check.h"
@implementation Check

+(BOOL)isNoNull:(NSString *)string{
    if (![string isNotNil]) {
        [MBProgressHUD showToastDown:@"内容不能为空"];
    }
    return [string isNotNil];
}

+ (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)checkPassword:(NSString *) passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,11}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
    
}

+ (BOOL)isAllNumber:(NSString *)string
{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            [MBProgressHUD showToast:@"体重必须全是数字"];
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isHaveChineseInString:(NSString *)string{
    for(NSInteger i = 0; i < [string length]; i++){
        int a = [string characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            [MBProgressHUD showToast:@"不能含有中文"];
            return YES;
        }
    }
    return NO;
}

+ (BOOL)AdultWeightIsRight:(NSString *)weight{
    
    if ([Check isNoNull:weight]) {
        if (![Check isHaveChineseInString:weight]) {
            CGFloat weiFloat = [weight floatValue];
            if (weiFloat <= 200 && weiFloat >=10) {
                return YES;
            }else{
                [MBProgressHUD showToast:@"体重过大或者过小"];
                return NO;
            }
        }else{
            return NO;
        }
    }else{
        [MBProgressHUD showToast:@"请重新输入"];
    }
    return NO;
}

+ (BOOL)DeviceName:(NSString *)name{
    if ([Check isNoNull:name]) {
        if (name.length > 15) {
            [MBProgressHUD showToast:@"设备名字太长"];
            return NO;
        }
        return YES;
    }
    [MBProgressHUD showToast:@"设备名称不能为空"];
    return NO;
}
@end
