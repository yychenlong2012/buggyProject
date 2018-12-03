//
//  leanCloudMgr.h
//  Buggy
//
//  Created by 孟德林 on 16/8/18.
//  Copyright © 2016年 ningwu. All rights reserved.
//

//#define SETIDENTIFIER(string) (static NSString * const string = [NSString stringWithFormat:@"%@",string])

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

// 注册
static NSString * const YOUZI_Register = @"YOUZI_Register";

// 绑定蓝牙设备号
static NSString * const YOUZI_BandingDevice = @"YOUZI_BandingDevice";
static NSString * const YOUZI_DeleBanding = @"YOUZI_DeleBanding";


// 登录
static NSString * const YOUZI_Login = @"YOUZI_Login";
static NSString * const YOUZI_Loginout = @"YOUZI_Loginout";
static NSString * const YOUZI_QQLogin = @"YOUZI_QQLogin";
static NSString * const YOUZI_WeiXinLogin = @"YOUZI_WeiXinLogin";
static NSString * const YOUZI_WeiBoLogin = @"YOUZI_WeiBoLogin";

//首页
static NSString * const YOUZI_PhoneUpLoad = @"YOUZI_PhoneUpLoad";
static NSString * const YOUZI_FindHeight = @"YOUZI_FindHeight";
static NSString * const YOUZI_FindWeight = @"YOUZI_FindWeight";
static NSString * const YOUZI_FindTravel = @"YOUZI_FindTravel";
static NSString * const YOUZI_DditBabyInfo = @"YOUZI_DditBabyInfo";
static NSString * const YOUZI_BabyTips = @"YOUZI_BabyTips";

// 界面统计
static NSString * const YOUZI_Home = @"YOUZI_Home";

//设置
static NSString * const YOUZI_SetSex = @"YOUZI_SetSex";
static NSString * const YOUZI_SetBirthday = @"YOUZI_SetBirthday";
static NSString * const YOUZI_SetNative = @"YOUZI_SetNative";

//添加
static NSString * const YOUZI_AddHeight = @"YOUZI_AddHeight";
static NSString * const YOUZI_AddWeight = @"YOUZI_AddWeight";

//分享

static NSString * const YOUZI_ShareWeChatMoments = @"YOUZI_ShareWeChatMoments";
static NSString * const YOUZI_ShareWeChatFriends = @"YOUZI_ShareWeChatFriends";
static NSString * const YOUZI_ShareQQ = @"YOUZI_ShareQQ";
static NSString * const YOUZI_ShareSina = @"YOUZI_ShareSina";

@interface leanCloudMgr : NSObject

+ (void)initEvent;

/**
 *  简单事件统计
 *
 *  @param event_id 事件的标识符
 */
+ (void)event:(NSString *)event_id;

/**
 *  结束统计
 */
+ (void)stopAnalyticsEvent;

/**
 *  开始登录某界面
 */
+ (void)beginLogPageView:(NSString *)event_id;

/**
 *  结束登录某界面
 */
+ (void)endLogPageView:(NSString *)event_id;

@end
