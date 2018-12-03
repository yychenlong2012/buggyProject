//
//  MainModel.h
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseModel.h"
#import "UserModel.h"

                /*************************************用户管理类*************************************/

#define kLoginToken @"kLoginToken"
@interface MainModel : BaseModel

@property (nonatomic, strong)UIViewController *rootVC;
//@property (nonatomic, strong) AVUser *user;                   //该模型所属的用户
@property (nonatomic) BOOL isLogin;                           //是否登录
@property (nonatomic, strong)UserModel *userModel;            //用户信息模型
@property (nonatomic, strong)UIImage *userImage;
@property (nonatomic, assign)NSInteger openURLType;             //0 登录 1 QQ分享 2 微信分享 3微博分享
@property (nonatomic, assign) MUSIC_TYPENUMBER musicTypeNumber; //音乐播放库的序列号
@property (nonatomic, assign)BOOL isHaveNetWork; /**<是否有网络*/
@property (nonatomic, assign)AFNetworkReachabilityStatus networkStatus; //网络类型
/*
 车的基本信息
 1、根据选择车的类型不同，这些设备的属性值也不想通过
 2、可以监听这些设备的属性（KVO）
 */
@property (nonatomic) BOOL   isContectDevice;           // 是否连接上设备(废弃)
@property (nonatomic,strong) NSArray *peripheralsArray; // 所有设备的集合
@property (nonatomic,copy)   NSString *bluetoothUUID;   // 当前蓝牙的UUID
@property (nonatomic,copy)   NSString *blueToothName;   // 当前蓝牙的姓名

+ (instancetype)model;

- (void)logout;

- (void)showLoginVC;

- (NSString *)getCurrentLocalVersion;

- (NSString *)getFormatString:(NSString *)date;

@end
