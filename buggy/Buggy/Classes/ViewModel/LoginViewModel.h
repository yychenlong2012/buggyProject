//
//  LoginViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/1/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewModel : NSObject

+ (void)loginMobilePhoneWithNumber:(NSString *)number
                          passWord:(NSString *)passWord
                          complete:(void(^)(void))complete;

+ (void)loginQQcomplete:(void(^)(BOOL isNew))complete;

+ (void)loginWeiBocomplete:(void(^)(BOOL isNew))complete;

+ (void)loginWeiXincomplete:(void(^)(BOOL isNew))complete;

@end
