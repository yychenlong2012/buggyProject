//
//  LoginViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/1/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "LoginViewModel.h"
#import "MainModel.h"
#import "BabyModel.h"
#import "LoginModel.h"

@implementation LoginViewModel

+ (void)loginMobilePhoneWithNumber:(NSString *)number passWord:(NSString *)passWord complete:(void(^)(void))complete{
    
    [leanCloudMgr event:YOUZI_Login];
    [MainModel model].openURLType = 0;
//    if (![Check validateMobile:number]) {
//        [MBProgressHUD showError:NSLocalizedString(@"手机号正则验证不通过", nil)];
//        return;
//    }
    if (number.length != 11) {
        [MBProgressHUD showError:NSLocalizedString(@"手机号格式错误", nil)];
        return;
    }
    __weak typeof(self) wself = self;
    //登录
    [AVUser logInWithMobilePhoneNumberInBackground:number password:passWord
                                             block:^(AVUser *user, NSError *error) {
                                                 if (!error) {
                                                    
                                                     [MBProgressHUD showSuccess:NSLocalizedString(@"登录成功", nil)];
                                                     [[NSUserDefaults standardUserDefaults] setObject:user.sessionToken forKey:kLoginToken];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     [MainModel model].user = user;
                                                     [wself postLoginNoti];
                                                     if (complete) complete();
                                                 }else{
//                                                     NSLog(@"%@",error.localizedDescription);
                                                     switch (error.code) {
                                                         case 1:
                                                             [MBProgressHUD showToast:NSLocalizedString(@"登录次数已达今日上限", nil)];
                                                             break;
                                                         case 211:
                                                             [MBProgressHUD showToast:NSLocalizedString(@"手机号未注册", nil)];
                                                             break;
                                                         default:
                                                             [MBProgressHUD showError:NSLocalizedString(@"用户名或密码不正确", nil)];
                                                             break;
                                                     }
                                                 }
                                             }];
}

+ (void)loginQQcomplete:(void(^)(BOOL isNew))complete{

    [leanCloudMgr event:YOUZI_QQLogin];
    [MainModel model].openURLType = 0;
    __weak typeof(self) wself = self;
    [[LoginModel model] loginWithLoginType:LOGIN_QQ
                                     error:^(NSError *error) {
                                         [wself dealProcessingError:error complete:^(BOOL isComNew) {
                                             if (complete) complete(isComNew);
                                         }];
                                         
    }];
}

+ (void)loginWeiBocomplete:(void(^)(BOOL isNew))complete{
    
    [leanCloudMgr event:YOUZI_WeiBoLogin];
    [MainModel model].openURLType = 0;
    __weak typeof(self) wself = self;
    [[LoginModel model] loginWithLoginType:LOGIN_SinaWeibo
                                     error:^(NSError *error) {
                                         [wself dealProcessingError:error complete:^(BOOL isComNew) {
                                             if (complete) complete(isComNew);
                                         }];
    }];
}

+ (void)loginWeiXincomplete:(void(^)(BOOL isNew))complete {
    [leanCloudMgr event:YOUZI_WeiXinLogin];
    [MainModel model].openURLType = 0;
    __weak typeof(self) wself = self;
    [[LoginModel model] loginWithLoginType:LOGIN_WeiXin error:^(NSError *error) {
         [wself dealProcessingError:error complete:^(BOOL isComNew) {
             if (complete) complete(isComNew);
         }];
    }];
}

// 第三方登录回调信息，集中处理
+ (void)dealProcessingError:(NSError *)error complete:(void(^)(BOOL isComNew))complete{
    if (error) {
//        [MBProgressHUD showError:@"用户名或密码不正确"];
    }else{
        //有用户则看是否是新用户
        __weak typeof(self) wself = self;
        [[BabyModel manager] getBabyInfo:^(BabyModel *babyModel) {
//            if ([Check isNoNull:babyModel.birthday]) {
            if (babyModel.birthday.length > 1) {
                [wself postLoginNoti];
                if (complete) complete(NO);
            }else{
                if (complete) complete(YES);
            }
        }];
    }
}

+ (void)postLoginNoti
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:DIDLOGIN object:nil userInfo:nil];
    
}

@end
