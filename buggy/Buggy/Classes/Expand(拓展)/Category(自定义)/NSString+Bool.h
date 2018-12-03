//
//  NSString+Bool.h
//  ccyCard
//
//  Created by ileo on 14-4-8.
//  Copyright (c) 2014年 mudi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bool)

- (BOOL)isCarNo;
-(BOOL)isTel;
-(BOOL)isEmail;
-(BOOL)isDeviceCode;
-(BOOL)isDevice;
-(BOOL)isNotNil;
-(BOOL)isPWD;
-(BOOL)isCode;
-(BOOL)isIDCard;
-(BOOL)isNumOrsASC;

@end
