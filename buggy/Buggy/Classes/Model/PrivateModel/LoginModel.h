//
//  LoginModel.h
//  Buggy
//
//  Created by ningwu on 16/5/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseModel.h"
//#import <AVOSCloudSNS.h>
//#import <LeanCloudSocial/AVUser+SNS.h>

typedef NS_ENUM(NSInteger, LOGINType){
    /// 新浪微博
    LOGIN_SinaWeibo  =1,
    
    /// QQ
    LOGIN_QQ         =2,
    
    /// 微信
    LOGIN_WeiXin      =3,
};

@interface LoginModel : BaseModel

+ (instancetype)model;

//- (void)loginWithLoginType:(LOGINType )login
//                     error:(void(^)(NSError *error))Error;
@end
