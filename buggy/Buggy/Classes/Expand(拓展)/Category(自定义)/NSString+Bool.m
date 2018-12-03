//
//  NSString+Bool.m
//  ccyCard
//
//  Created by ileo on 14-4-8.
//  Copyright (c) 2014年 mudi. All rights reserved.
//

#import "NSString+Bool.h"

@implementation NSString (Bool)
//验证车牌号
- (BOOL)isCarNo
{
    NSString * carNoRegex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z_0-9]{5}$";
    NSPredicate * carNoTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", carNoRegex];
    return [carNoTest evaluateWithObject:self];
}
-(BOOL)isTel{
    NSString *telRegex = @"^[1][3-8]\\d{9}$";
    NSPredicate *telTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telRegex];
    return [telTest evaluateWithObject:self];
}

-(BOOL)isEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL)isDeviceCode{
//    NSString *emailRegex = @"^[\\d]{12,21}$";
    NSString *emailRegex = @"^[0-9]{4}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL)isDevice{
    NSString *emailRegex = @"^[0-9]{15}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isNotNil
{
    if (self == nil || (id)self == [NSNull null] || [self isEqualToString:@""])
        return NO;
    return YES;
}

-(BOOL)isCode{
    NSString *codeRegex = @"\\d{4,6}";
    NSPredicate *codeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", codeRegex];
    return [codeTest evaluateWithObject:self];
}

-(BOOL)isPWD{
    NSString *emailRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,13}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL)isIDCard{
    NSString *idCardRegex = @"(^\\d{15}$)|(^\\d{17}([0-9]|X)$)";
    NSPredicate *idCardTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", idCardRegex];
    return [idCardTest evaluateWithObject:self];
}

-(BOOL)isNumOrsASC{
    NSString *numOrBigASC = @"\\w+";
    NSPredicate *numOrBigASCTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numOrBigASC];
    return [numOrBigASCTest evaluateWithObject:self];
}

@end