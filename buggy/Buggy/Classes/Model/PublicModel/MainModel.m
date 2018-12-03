//
//  MainModel.m
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "MainModel.h"
#import "ScreenMgr.h"
//#import <AVOSCloudSNS.h>

@implementation MainModel

+ (instancetype)model{
    static MainModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MainModel alloc] init];
    });
    return instance;
}

- (void)logout{
    self.userModel = nil;
    self.userImage = nil;
    [SCREENMGR clear];
//    [AVUser logOut];  //清除缓存用户对象
//    [AVUser currentUser];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoginToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLogin{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginToken];
    return token.length > 0? YES : NO;
}

- (void)showLoginVC{
    [SCREENMGR changeToLoginScreen];
}

- (NSString *)getCurrentLocalVersion{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

- (NSString *)getFormatString:(NSString *)date{
    NSString *fromatString;
    return fromatString;
}
@end
