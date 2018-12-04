//
//  CONSTS.h
//  writer
//
//  Created by wuning on 15-1-8.
//  Copyright (c) 2015年 writer. All rights reserved.
//

#ifndef buggy_CONSTS_h
#define buggy_CONSTS_h

//商用版
#define LeanCloudID @"1R2oS0W0U9dJGveftbxOHGy3-gzGzoHsz"
#define LeanCloudClientKey @"Pf2Gper3lCPI0neKo0EKWdLN"

// LeanCloud
//#ifdef DEBUG
////测试版
//#define LeanCloudID @"prnPRaln6v5xwNqUkQu5sFUA-gzGzoHsz"
//#define LeanCloudClientKey @"zQodN3qR7OOVjizMfqTI3LXE"
//#else
////商用版
//#define LeanCloudID @"1R2oS0W0U9dJGveftbxOHGy3-gzGzoHsz"
//#define LeanCloudClientKey @"Pf2Gper3lCPI0neKo0EKWdLN"
//#endif


//心知天气请求密钥
#define XinZhiAPIKey @"1limijcgcsj4vjqd"
#define XinZhiUserID @"U7054AA301"

//友盟APPKey
#define UMAppKey @"5c06431bb465f51edc000022"


// 微博
#define WEIBOAPPKEY @"3074598193"
#define WEIBOAPPSECREAT @"811403f7ef7c35ff14478b960e7188ba"
#define WEIBOREDIRECTURI @"http://sns.whalecloud.com/sina2/callback"

// 微信
#define WEIXINAPPID @"wxe4636c9399ddee3f"
#define WEIXINSECRET @"ef46c5de4156f80d4fc4f7c52cacd657"

// qq
#define QQAPPID @"1105156999"
#define QQAPPKEY @"fxd38ZT4LsU5RbFP"

// 高德
#define AMAP @"4f98bb0f7459ff72eac6aa5dface0b15"

//失败提示
#define GETDATAERROR @"获取网络数据失败 稍后再试！"

//通知
#define kTURNTOHOMEVC @"kTURNTOHOMEVC"
#define kCONNECTDEVICE @"kCONNECTDEVICE"   // 连接设备
#define kACCESSESEQUIPMENTLIST @"kACCESSESEQUIPMENTLIST" //获取设备列表
#define DIDLOGIN @"DIDLOGIN"               // 已经登录
#define DIDLOGINOUT  @"DIDLOGINOUT"        // 退出登录
#define kREQUESTBABYINFODATA @"kREQUESTBABYINFODATA"  //请求baby数据
#define kRECIEVEWEIGHT @"kRECIEVEWEIGHT"   // 接收体重
#define kRECIEVETRAVLE @"kRECIEVETRAVLE"   // 接收旅程
#define kRefreshScan   @"kRefreshScan"     // 重新扫描蓝牙设备
#define kDeviceIsDisconnect @"kDeviceIsDisconnect"//设备已经断开

//缓存的key
#define kBABYINFODATA @"kBABYINFODATA"     // baby的用户信息
#define kBABYHEIGHTDATA @"kBABYHEIGHTDATA" // baby的身高信息
#define kBABYWEIGHTDATA @"kBABYWEIGHTDATA" // baby的体重信息
#define kBABYTRAVELINFO @"kBABYTRAVELINFO" // baby的旅行信息
#define kBABYTIPSDATA @"kBABYTIPSDATA"     // baby的提示信息
#define kBABYALLTIPSDATA @"kBABYALLTIPSDATA" //baby的所有的提示信息
#define kBABYHealth @"kBABYHealth"         /*<baby的健康信息*/ 

typedef enum : NSUInteger {
    MUSIC_TYPENUMBER_CHILDRENSONG = 1, // 精品儿歌
    MUSIC_TYPENUMBER_ANCIENTPOETRY,    // 经典古诗
    MUSIC_TYPENUMBER_STORY,            // 儿童故事
    MUSIC_TYPENUMBER_ENGLISH,          // 启蒙英语
    MUSIC_TYPENUMBER_SANZIJING,        // 三字经
    MUSIC_TYPENUMBER_VEHICULAR,        // 车载音乐
    
    MUSIC_TYPENUMBER_LIKE,             // 宝宝喜欢
    MUSIC_TYPENUMBER_LOCAL,            // 本地音乐
    MUSIC_TYPENUMBER_HISTORY,          // 播放记录
    MUSIC_TYPENUMBER_HOTRECOMMENT      // 热门推荐
} MUSIC_TYPENUMBER;

typedef enum : NSUInteger {
    LOCAL_PLAYER = 1,                  // 来自本地播放
    NETWORK_PLAYER,                    // 来自网络播放
    VEHICLE_PLAYER                     // 来自婴儿车自带音乐播放
    
} PLAYERFROMTYPE;

/* 音乐本地缓存  */
static NSString *const MusicPlayerStatus = @"MusicPlayerStatus"; // 音乐播放的状态
static NSString *const MusicPlayerVolume = @"MusicPlayerVolume"; // 音乐播放的音量
static NSString *const MusicSelectDeviceMode = @"MusicSelectDeviceMode"; //设备的播放的模式

//新的音乐类型
typedef enum : NSUInteger {
//    MUSIC_WATER = 1,        // 羊水音
    MUSIC_SLEEP       = 1,            // 哄睡
    MUSIC_PACIFY      = 2,            // 安抚
    MUSIC_CHILDSOON   = 3,            // 儿歌
    MUSIC_STORY       = 4,            // 故事
} NEW_MUSIC_TYPE;

#define kPARENTSTOUSERINFO @"kParentsToReloadUserinfo" // 从新更新用户信息
#define kBABYIMAGE @"kBABYIMAGE"  // baby图片
#define DeviceData @"DeviceData"  // G设备信息
#define A3DEVICEDATA @"A3DeviceData" // A3设备信息
#define KA3Version @"KA3Version" // A3设版本号
//版本  每次更新 需要在表中 新建一行 并且更新
#define kAppControlID_1_3_3 @"57b421e18ac24700643af8a5"
#define kAppControlID_2_0_0 @"58175fed5bbb500059b1f3b2"


// 蒙版
#define FirstCouponBoard_iPhone @"firstCouponBoard_iPhone"
#define FirstHomeCouponBoard_iPhone @"firstHomeCouponBoard_iPhone"

// 是否第一次加载APP
#define FirstLoadApp @"kFirstLoadApp"

// 扫描时间间隔
#define ScanDuration 3
#define BLUETOOTHUUID @"BLUETOOTHUUID" // 最新的一次连接的设备的UUID


// A3 设备的参数

#define BRAKINGSTATUS @"BrakingStatus" // 刹车状态
#define AntiTheftStatus @"AntiTheftStatus" // 防盗状态
#endif
