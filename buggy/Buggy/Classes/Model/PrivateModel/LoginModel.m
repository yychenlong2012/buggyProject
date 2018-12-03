//
//  LoginModel.m
//  Buggy
//
//  Created by ningwu on 16/5/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "LoginModel.h"
//#import <AVOSCloudSNS.h>
//#import <LeanCloudSocial/AVUser+SNS.h>
#import "MainModel.h"

#define kLoginToken @"kLoginToken"

@implementation LoginModel

+ (instancetype)model
{
    LoginModel *model = [[LoginModel alloc]init];
    return model;
}
- (void)loginWithLoginType:(LOGINType )login
                     error:(void(^)(NSError *error))Error
{
    switch (login) {
        case LOGIN_SinaWeibo:
        {
            [self loginWithWeibo:^(NSError *error) {
                Error(error);
            }];
        }
            break;
        case LOGIN_WeiXin:
        {
            [self loginWithWeixin:^(NSError *error) {
                Error(error);
            }];
        }
            break;
        case LOGIN_QQ:
        {
            [self loginWithQQ:^(NSError *error) {
                Error(error);
            }];
        }
            break;
        default:
            break;
    }
}
- (void)loginWithWeibo:(void (^)(NSError *error))block
{
//    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo
//                     withAppKey:WEIBOAPPKEY
//                   andAppSecret:WEIBOAPPSECREAT
//                 andRedirectURI:WEIBOREDIRECTURI];
//    [self loginWithType:AVOSCloudSNSSinaWeibo
//               platform:AVOSCloudSNSPlatformWeiBo
//                failure:^(NSError *error) {
//                block(error);
//    }];
}

- (void)loginWithWeixin:(void(^)(NSError *error))block
{
//    [AVOSCloudSNS setupPlatform:AVOSCloudSNSWeiXin
//                     withAppKey:WEIXINAPPID
//                   andAppSecret:WEIXINSECRET
//                 andRedirectURI:@""];
//    [self loginWithType:AVOSCloudSNSWeiXin
//               platform:AVOSCloudSNSPlatformWeiXin
//                failure:^(NSError *error) {
//                block(error);
//    }];
}

- (void)loginWithQQ:(void(^)(NSError *error))block
{
//    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ
//                     withAppKey:QQAPPID
//                   andAppSecret:QQAPPKEY
//                 andRedirectURI:@""];
//    [self loginWithType:AVOSCloudSNSQQ
//               platform:AVOSCloudSNSPlatformQQ
//                failure:^(NSError *error) {
//                block(error);
//    }];
}
/*
 {
     "authData":{
         "weibo":{
              "uid":"6096164785",
              "expiration_in":"701365",
              "access_token":"2.00TwsYeG88hE3D3b4a991a0e7d9M3D"
          }
      }
 }
 //            NSString *username = object[@"username"];
 //            NSString *avatar = object[@"avatar"];
 //            NSDictionary *rawUser = object[@"raw-user"]; // 性别等第三方平台返回的用户信息
 //            DLog(@"第三方登录信息：/n accessToken:%@/n username:%@/n avatar:%@/n rawUser:%@/n"
 //                 ,accessToken,username,avatar,rawUser);

 "openid": "0395BA18A5CD6255E5BA185E7BEBA242",
 *      "access_token": "12345678-SaMpLeTuo3m2avZxh5cjJmIrAfx4ZYyamdofM7IjU",
 *      "expires_in": 1382686496
 */

//- (void)loginWithType:(AVOSCloudSNSType )type platform:(NSString *)platform
//              failure:(void(^)(NSError *error))failure
//{
//    [AVOSCloudSNS logout:type];
//    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
//        if (error) {
//            failure(error);
//        } else {
//            NSLog(@"%@",object);
//            NSString *accessToken = object[@"access_token"];
//            NSDictionary *authData = @{ [platform isEqualToString:AVOSCloudSNSPlatformWeiBo] ? @"uid":@"openid":object[@"id"],
//                                       @"access_token":accessToken,
//                                        [platform isEqualToString:AVOSCloudSNSPlatformWeiBo] ? @"expiration_in":@"expires_in":@"701365"
//                                       };
//            NSLog(@"==%@",authData);
//            [AVUser loginWithAuthData:authData platform:platform block:^(AVUser *user, NSError *error) {
//                if (error) {
//                    [MBProgressHUD showError:@"登录失败，请重新再试!"];
//                    failure(error);
//                } else {
//                    [MBProgressHUD showSuccess:@"登录成功"];
//                    [MainModel model].user = user;
//                    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kLoginToken];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    failure(error);
//                }
//            }];
//        }
//    } toPlatform:type];
//}

@end
