//
//  AppDelegate.m
//  Buggy
//
//  Created by ningwu on 16/2/22.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "AppDelegate.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "AlertActionSheetMgr.h"
#import "ScreenMgr.h"
#import "MonitorCrash.h"
#import "DYBaseNaviagtionController.h"
#import "PushViewController.h"
#import "BlueToothManager.h"
#import "MainViewController.h"
#import "NetWorkStatus.h"
#import "MusicManager.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+COSAdtions.h"
#import "DYBaseNaviagtionController.h"
#import "CLKeyChain.h"
#import <mach-o/dyld.h>
#import "LoginVC.h"
#import <UMShare/UMShare.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>

@interface AppDelegate ()
@property (strong, nonatomic) NSDictionary *infoDic;

@end

@implementation AppDelegate
{
    UIBackgroundTaskIdentifier _bgTaskId;   //后台任务ID
}

//App每次启动都会有一个随机的偏移值
long calculate(void) {
    long s = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            long slide = _dyld_get_image_vmaddr_slide(i);
            s = slide;
            break;
        }
    }
    return s;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    LoginVC *loginVC = [[LoginVC alloc] init];
    loginVC.view.backgroundColor = [UIColor whiteColor];
    DYBaseNaviagtionController *nav = [[DYBaseNaviagtionController alloc]
                                       initWithRootViewController:loginVC];
    self.window.rootViewController = nav;

//#if DEBUG
//    [MonitorCrash monitorCrashExchangeMethod];
//    [MonitorCrash monitorCrash];
//#endif
    [BLEMANAGER CL_initializeCentralManager];    //初始化蓝牙管理者
    self.infoDic = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    [self configureAPIKey];        //第三方key
    // U-Share 平台设置
    [UMConfigure initWithAppkey:UMAppKey channel:@"App Store"];
    [self configUSharePlatforms];
    [SCREENMGR showRightScreen];   //初始界面
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.window makeKeyAndVisible];
    
    [self AFNReachability];
    
    //将沙盒中保存的异常信息发给服务器
    [self uploadCrashLog];
    
    //设置异常回调函数
    NSSetUncaughtExceptionHandler(handleException);
    return YES;
}

/**
 *  异常回调
 */
void handleException(NSException *exception){
    //1.用户id

    //2.设备型号
    NSString *deviceName = [NetWorkStatus getDeviceName];
    //3.系统版本
    NSString *OSVersion = [NSString stringWithFormat:@"iOS %@",[UIDevice currentDevice].systemVersion];
    //4.崩溃名
    NSString *exceptionName = [exception name];
    //5.崩溃原因
    NSString *reason = [exception reason];
    //6.函数调用栈信息
    NSArray *array = [exception callStackSymbols]; //调用栈信息
    UIViewController *topViewController = [UIViewController presentingVC];
    if (topViewController != nil && [topViewController isKindOfClass:[MainViewController class]]) {
        MainViewController *vc = (MainViewController *)topViewController;
        if ([vc.selectedViewController isKindOfClass:[DYBaseNaviagtionController class]]) {
            DYBaseNaviagtionController *naviVC = vc.selectedViewController;
            topViewController = naviVC.topViewController;
        }
    }
    NSString *callStackStr = [NSString stringWithFormat:@"当前界面%@\n调用栈",[topViewController class]];
    for (NSString *str in array) {
        callStackStr = [NSString stringWithFormat:@"%@\n%@",callStackStr,str];
    }
    //7.崩溃前画面
    UIViewController *vc = [UIViewController presentingVC];
    UIGraphicsBeginImageContextWithOptions(vc.view.frame.size, NO, [UIScreen mainScreen].scale);
    [vc.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"finalPicture.png"];
    BOOL result =[UIImagePNGRepresentation(snapshotImage) writeToFile:filePath atomically:YES]; // 保存成功会返回YES
    //8.崩溃前网络状态
    int network = [NetWorkStatus dataNetworkTypeFromStatusBar];
    NSString *networkType = @"none";
    switch (network) {
        case 0:
            networkType = @"NETWORK_TYPE_NONE";
            break;
        case 1:
            networkType = @"NETWORK_TYPE_2G";
            break;
        case 2:
            networkType = @"NETWORK_TYPE_3G";
            break;
        case 3:
            networkType = @"NETWORK_TYPE_4G";
            break;
        case 5:
            networkType = @"NETWORK_TYPE_WIFI";
    }
    //9.崩溃前蓝牙状态
    BOOL isConnected = BLEMANAGER.currentPeripheral==nil?NO:YES;
    //10.崩溃时间
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *crashTime = [form stringFromDate:[NSDate date]];
    //11.app版本
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *AppVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    //12.设备唯一标识
    NSString *identifier = [CLKeyChain getDeviceIDInKeychain];
    //13.偏移
    NSString *slide = [NSString stringWithFormat:@"%ld",calculate()];
    //保存本地
    NSDictionary *dict = @{  @"deviceName":deviceName==nil?@"":deviceName,
                            @"OSVersion":OSVersion==nil?@"":OSVersion,
                            @"exceptionName":exceptionName==nil?@"":exceptionName,
                            @"reason":reason==nil?@"":reason,
                            @"callStackSymbols":callStackStr==nil?@"":callStackStr,
                            @"finalPicture":result==YES?@"finalPicture.png":@"",
                            @"networkType":networkType,
                            @"bluetooth":isConnected==YES?@"已连接":@"未连接",
                            @"crashTime":crashTime==nil?@"":crashTime,
                            @"AppVersion":AppVersion==nil?@"":[NSString stringWithFormat:@"iOS_APP_%@",AppVersion],
                            @"uniqueIdentifier":identifier==nil?@"":identifier,
                             @"slide":slide==nil?@"":slide
                           };
    NSString *path = [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crash_log.plist"];
    [dict writeToFile:path atomically:YES];
    
    exit(0);// 杀死程序
}


//上传崩溃日志
-(void)uploadCrashLog{
    NSString *path = [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crash_log.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dict == nil) {
        return;
    }
    NSString *imageName = dict[@"finalPicture"];
    NSString *imagePath = [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    NSData *imageData;
    if (imageName!=nil && ![imageName isEqualToString:@""]) {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        if (image) {
            imageData = [image compressImageWithImage:image aimWidth:414 aimLength:1024*200 accuracyOfLength:1024];
        }
    }
    NSDictionary *prame = @{  @"crash_log":@{
                                     @"crashTime":dict[@"crashTime"],
                                     @"deviceName":dict[@"deviceName"],
                                     @"AppVersion":dict[@"AppVersion"],
                                     @"callStackSymbols":dict[@"callStackSymbols"],
                                     @"bluetooth":dict[@"bluetooth"],
                                     @"OSVersion":dict[@"OSVersion"],
                                     @"reason":dict[@"reason"],
                                     @"networkType":dict[@"networkType"],
                                     @"slide":dict[@"slide"],
                                     @"userId":KUserDefualt_Get(USER_ID_NEW)==nil?@"":KUserDefualt_Get(USER_ID_NEW),
                                     @"isProcessed":@"",
                                     @"exceptionName":dict[@"exceptionName"],
                                     @"uniqueIdentifier":dict[@"uniqueIdentifier"]
                                     }
                             };
    [NETWorkAPI uploadCrashLogData:prame imageData:imageData];
    //清空数据
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}


- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WEIXINAPPID appSecret:WEIXINSECRET redirectURL:@"http://mobile.umeng.com/social"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    /*设置QQ平台的appID*/
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAPPID appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:WEIBOAPPKEY  appSecret:WEIBOAPPSECREAT redirectURL:WEIBOREDIRECTURI];
}


#pragma mark === 处理推送和注册第三方
- (void)initHomeVC{
    [SCREENMGR showMainScreen];
    if (self.infoDic) {
        [self pushSpecifiedVCWithInfo:self.infoDic];
    }
}

//注册appy
- (void)configureAPIKey{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:WEIBOAPPKEY];
    [WXApi registerApp:WEIXINAPPID];
//    [AMapServices sharedServices].apiKey = AMAP;
}

#pragma mark - 第三方回调url
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
//    return [self openURLTypeWithUrl:url];
    
    //友盟
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

// iOS9.0及其以下版本
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
//    return [self openURLTypeWithUrl:url];
    
    //友盟
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

// 大于iOS9.0版本
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    
//    return [self openURLTypeWithUrl:url];
    
    //友盟
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

//- (BOOL)openURLTypeWithUrl:(NSURL *)url{
////    switch ([MainModel model].openURLType) {       // 1、2、3 分别是用来分享时的回调  而 0 是用来 第三方快捷登陆的
//    switch ([KUserDefualt_Get(THIRD_PARTY_LOGIN_TYPE) integerValue]) {       // 1、2、3 分别是用来分享时的回调  而 0 是用来 第三方快捷登陆的
//        case 1:{
//            return [TencentOAuth HandleOpenURL:url];
//        }break;
//        case 2:{
//            return [WXApi handleOpenURL:url delegate:self];
//        }break;
//        case 3:{
//            return [WeiboSDK handleOpenURL:url delegate:self];
//        }break;
//        default:{
//            return NO;
////            return [AVOSCloudSNS handleOpenURL:url];
//        }break;
//    }
//}


#pragma mark === 处理推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

    //cleanCloud处理deviceToken
//    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:deviceToken];
//    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//
//            NSMutableString *deviceTokenString = [NSMutableString string];
//            const char *bytes = deviceToken.bytes;
//            NSInteger iCount = deviceToken.length;
//            for (NSInteger i = 0; i < iCount; i++) {
//                [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
//            }
//
//            //将deviceToken上传到用户表 和用户绑定 做定点推送
//            AVUser *user = [AVUser currentUser];
//
//            [user setObject:deviceTokenString forKey:@"deviceToken"];
//            [user setObject:@"iOS" forKey:@"deviceType"];
//
//            [user saveInBackground];
//        }
//    }];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DLog(@"RemoteNotifications is failed and error:%@",error);
}

/*此方法的调用时，MainViewController已经被初始化，
 所以我们已经可以在MainViewController注册推送消息的监听，
 用于展示对应的视图
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    DLog(@"---ReceiveRemoteNotification---%@",userInfo[@"aps"][@"category"]);
    if (![MainModel model].isLogin) {
        [SCREENMGR changeToLoginScreen];
    }else{
        [self pushSpecifiedVCWithInfo:userInfo];
    }
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}
- (void)pushSpecifiedVCWithInfo:(NSDictionary *)userInfo{
    UIViewController *vc = self.window.rootViewController;
    [ALERTACTIONSHEETMGR createFromVC:vc withAlertType:TYPE_ALERTVC_ALERT withTitle:nil withMessage:userInfo[@"aps"][@"alert"] withCanCelTitle:NSLocalizedString(@"取消",nil) withRedBtnTitle:nil withOtherBtnTitle:NSLocalizedString(@"去看看",nil) clickIndexBlock:^(NSInteger index) {
        if (index == 0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        if (index == 2) {
            PushViewController *push = [[PushViewController alloc] init];
            push.index =  [userInfo[@"aps"][@"category"] integerValue];
            [vc presentViewController:[[DYBaseNaviagtionController alloc]initWithRootViewController:push]
                             animated:YES
                           completion:^{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//                [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            }];
        }
    }];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


#pragma mark --- 音乐播放控制模块

/* 成为第一响应者 */
- (BOOL)canBecomeFirstResponder{
    return YES;
}

//接收远程事件
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        {
            [MUSICMANAGER pause];
        }
            break;
        case UIEventSubtypeRemoteControlPause:
        {
            [MUSICMANAGER pause];
        }
            break;
        case UIEventSubtypeRemoteControlNextTrack:
        {
            [MUSICMANAGER next];
        }
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
        {
            [MUSICMANAGER previous];
        }
            break;
        default:
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // 开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    /*
     以上的部分只能暂时实现进入后台播放一段时间(几分钟)。
     但是不能持续播放网络音乐，如果播放，需要申请后台任务ID
     */
    _bgTaskId=[AppDelegate backgroundplayerID:_bgTaskId];
}

+(UIBackgroundTaskIdentifier )backgroundplayerID:(UIBackgroundTaskIdentifier)backTaskID{
    
    // 设置并激活音频会话类别
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    // 允许应用程序接受远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // 设置后台任务ID
    UIBackgroundTaskIdentifier newtaskID = UIBackgroundTaskInvalid;
    newtaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    if (newtaskID != UIBackgroundTaskInvalid && backTaskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskID];
    }
    return newtaskID;
}

//使用AFN框架来检测网络状态的改变
-(void)AFNReachability
{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown     = 未知
     AFNetworkReachabilityStatusNotReachable   = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
                [MainModel model].isHaveNetWork = NO;
                [MainModel model].networkStatus =AFNetworkReachabilityStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
                [MBProgressHUD showToast:NSLocalizedString(@"网络未连接",nil)];
                [MainModel model].isHaveNetWork = NO;
                [MainModel model].networkStatus =AFNetworkReachabilityStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
                [MainModel model].isHaveNetWork = YES;
                [MainModel model].networkStatus =AFNetworkReachabilityStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
                [MainModel model].isHaveNetWork = YES;
                [MainModel model].networkStatus =AFNetworkReachabilityStatusReachableViaWiFi;
                break;
            default:
                NETWorkAPI.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
                break;
        }
    }];
    
    //3.开始监听
    [manager startMonitoring];
}
/*
 switch (netStatus) {
 case ZPAFNetworkReachabilityStatusUnknown:
 [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
 break;
 case ZPAFNetworkReachabilityStatusNotReachable:
 [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
 break;
 case ZPAFNetworkReachabilityStatusReachableViaWWAN: [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
 break;
 case ZPAFNetworkReachabilityStatusReachableViaWiFi:
 [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
 break;
 default:
 // [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
 break;
 */
@end
