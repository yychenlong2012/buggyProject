//
//  NetworkAPI.h
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "homeDataModel.h"
#import "punchListModel.h"
#import "babyInfoModel.h"
#import "userInfoModel.h"
#import "DeviceModel.h"
#import <UMShare/UMShare.h>


#define NETWorkAPI [NetworkAPI shareInstance]
#define USER_LOGIN_TOKEN @"USER_LOGIN_TOKEN"       //用户登录token
#define USER_REFRESH_TOKEN @"USER_REFRESH_TOKEN"   //用户刷新token
#define THIRD_PARTY_LOGIN_TYPE @"THIRD_PARTY_LOGIN_TYPE"     //第三方登录平台标识
#define USER_ID_NEW @"USER_ID_NEW"            //用户唯一标识
#define CACHE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/musicInfoCache"]   //缓存文件夹路径

typedef enum : NSUInteger {
    WEEK_TYPE = 1,                  // 周频率
    MONTH_TYPE                      // 月频率
} FREQUENCY_TYPE;      //周、月频率

typedef enum : NSUInteger {
    UPLOAD_BABY_SEX = 1,                  // 性别
    UPLOAD_BABY_NAME,                     // 名字
    UPLOAD_BABY_BIRTHDAY,                 // 生日
    UPLOAD_BABY_HEADER                    // 头像
} BABY_INFO_TYPE;      //操作类型

typedef enum : NSUInteger {
    UPLOAD_USER_NAME = 1,            // 名字
    UPLOAD_USER_WEIGHT,              // 体重
    UPLOAD_USER_HEADER               // 头像
} USER_INFO_TYPE;      //操作类型

typedef enum : NSUInteger {
    SCENE_MUSIC_LULL = 1,            // 哄睡
    SCENE_MUSIC_PACIFY,              // 安抚
    SCENE_MUSIC_SONG,                // 儿歌
    SCENE_MUSIC_STORY                // 故事
} SCENE_MUSIC_TYPE;      //操作类型


typedef void(^HomeDataBlock)(homeDataModel * _Nullable model, NSError * _Nullable error);    //首页数据返回block
typedef void(^ModelBlock)(id _Nullable model, NSError * _Nullable error);
typedef void(^DataListBlock)(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error);
typedef void(^stringDataBlock)(NSString * _Nullable msg, NSError * _Nullable error);
typedef void(^statusBlock)(BOOL success, NSError * _Nullable error);
typedef void(^appControlBlock)(NSString * _Nullable version, BOOL isHidenVersionCell, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface NetworkAPI : NSObject
@property (nonatomic,strong) userInfoModel *userInfo;
@property (nonatomic,strong) NSMutableArray <DeviceModel *>*deviceArray;  //已绑定的推车信息
@property (nonatomic,strong) AFHTTPSessionManager * manager;

+(instancetype)shareInstance;

//重新设置token字段
-(void)resetHTTPHeader;

#pragma mark - 登录注册
//验证登录状态
-(void)checkToken;
//手机登录
-(void)loginWithMobilePhone:(NSString *)phone password:(NSString *)password callback:(statusBlock _Nonnull)callback;
//手机注册
-(void)registerWithMobilePhone:(NSString *)phone password:(NSString *)password callback:(statusBlock _Nonnull)callback;
//重置密码
-(void)resetPassword:(NSString *)password mobilePhone:(NSString *)phone callback:(statusBlock _Nonnull)callback;
//退出登录
-(void)logoutWithCallback:(statusBlock _Nonnull)callback;

#pragma mark - 微信登录
-(void)getWeiXInCode;
//请求微信token
-(void)requestWeiXinTokenAndIdWithCode:(NSString *)code;
#pragma mark - QQ登录
-(void)loginWithQQ;
#pragma mark - 微博登录
-(void)loginWithWeiBo;
//第三方登录
- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType homeDataCallback:(HomeDataBlock _Nonnull)homeDataCallback;
#pragma mark - 上传天气
-(void)uploadWeahter:(NSString *)weather airQuality:(NSString *)airQuality callback:(statusBlock _Nonnull)callback;

#pragma mark - 首页
-(void)requestHomeData:(HomeDataBlock)homeData;
//打卡列表
-(void)requestPunchListWithPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData;
//用户历史打卡记录
-(void)requestUserHistoryPunchWithYear:(NSString *)year month:(NSString *)month callBcak:(DataListBlock _Nonnull)listData;
//周分析   @"2016-05-02"
-(void)requsetTravelWeekAnalyzeWithDate:(NSString *)date callback:(stringDataBlock _Nonnull)callback;
//日里程
-(void)requestDayMileageWithPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData;
//日里程分段数据 @"2018-11-03"
-(void)requestDayMileageSubsWithPage:(NSString *)page pageNum:(NSString *)pageNum date:(NSString *)date callback:(DataListBlock _Nonnull)listData;
//周频率 月频率
-(void)requestWeekAndMonthFrequency:(FREQUENCY_TYPE)type page:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData;

#pragma mark - 音乐
//请求轮播图数据
-(void)requestBannerDatacallback:(DataListBlock _Nonnull)callback;

//热门歌单
-(void)requestHotMusiccallback:(DataListBlock _Nonnull)callback;

//推荐歌单
-(void)requestRecommendMusiccallback:(DataListBlock _Nonnull)callback;

//全部歌单
-(void)requestAllMusicPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)callback;

//场景音乐
-(void)requestSceneMusicPage:(NSString *)page pageNum:(NSString *)pageNum musicType:(NSInteger)musicType callback:(DataListBlock _Nonnull)callback;

//专辑音乐  album该转接所在的表名 MusicStory
-(void)requestAlbumMusicPage:(NSString *)page pageNum:(NSString *)pageNum musicType:(NSString *)musicType album:(NSString *)album callback:(DataListBlock _Nonnull)callback;

//  @[
//    @{ @"musicName":@"春",
//       @"is_collected":@"1" },
//    @{ @"musicName":@"春",
//       @"is_down":@"1" }
//   ]
//收藏与下载操作
-(void)updateMusicWithOperation:(NSArray *)array callback:(statusBlock _Nonnull)callback;

#pragma mark - 个人中心
//用户信息
-(void)requestUserDataCallback:(ModelBlock _Nonnull)callback;

//修改用户信息   nickName或者header
-(void)updateUserInfoWithOptionType:(USER_INFO_TYPE)optionType optionValue:(id)optionValue callback:(statusBlock _Nonnull)callback;

//添加宝贝
-(void)addBabyInfoWithModel:(babyInfoModel *)model header:(NSData *)headerData callback:(DataListBlock _Nonnull)callback;

//baby信息
-(void)requestBabyInfoWithId:(NSString *)Id callback:(ModelBlock _Nonnull)callback;

//baby列表
-(void)requestBabyListcallback:(DataListBlock _Nonnull)callback;

//  @{ @"objectId":@"572d9e6679df540060b2afa4",
//@"birthday":@"2018-9-11" }
//修改baby信息  name/sex/birthday/header
-(void)updateBabyInfoWithId:(NSString *)Id optionType:(BABY_INFO_TYPE)type optionValue:(id)optionValue callback:(statusBlock _Nonnull)callback;

//删除baby信息  572d9e6679df540060b2afa4
-(void)deleteBabyWithId:(NSString *)Id callback:(statusBlock _Nonnull)callback;

#pragma mark - 推车
//请求已绑定的推车列表
-(void)requestDeviceListCallback:(DataListBlock _Nonnull)callback;

//修改设备名称
-(void)updateDeviceName:(NSString *)name Id:(NSString *)Id callback:(statusBlock _Nonnull)callback;

//绑定设备
-(void)bindDeviceWithDict:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback;

//解除绑定
-(void)deleteDeviceWithId:(NSString *)Id callback:(statusBlock _Nonnull)callback;

#pragma mark - 推行数据
//获取用户推行信息，推车界面
-(void)requestUserTravelInfoCallback:(ModelBlock _Nonnull)callback;

//上传今日里程
//-(void)uploadTodayMileage:(NSInteger)mileage callback:(statusBlock)callback;

//上传平均速度 今日里程 总里程
-(void)uploadAverageSpeed:(CGFloat)speed todayMileage:(NSInteger)todayMileage totalMileage:(CGFloat)totalMileage callback:(statusBlock _Nonnull)callback;

//上传分段里程
-(void)uploadTravelOnce:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback;

//获取最新一条分段数据
-(void)requestNewestMileageDataCallback:(stringDataBlock)callback;

//上传推车睡眠次数
-(void)uploadDeviceSleepTimes:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback;

//上传刹车灵敏度
-(void)uploadDeviceSensitivity:(NSString *)sensitivity callback:(statusBlock _Nonnull)callback;
//一键修复信息
-(void)uploadDeviceRepairData:(NSString *)deviceIdf deviceAddress:(NSString *)deviceAddress repair:(NSString *)repair bleUUID:(NSString *)bleUUID callback:(statusBlock _Nonnull)callback;
#pragma mark - 其他
//用户反馈
-(void)userFeedBackWithMsg:(NSString *)msg callback:(statusBlock _Nonnull)callback;

//使用说明
-(void)instructionsCallback:(stringDataBlock _Nonnull)callback;

//用户协议
-(void)userProtocolCallback:(stringDataBlock _Nonnull)callback;

//获取app_control数据
-(void)requestAppControlCallback:(appControlBlock _Nonnull)callback;

//获取设备类型列表
-(void)requestDeviceTypeList:(DataListBlock _Nonnull)callback;
//崩溃信息
-(void)uploadCrashLogData:(NSDictionary *)dict imageData:(NSData *)imageData;
@end

NS_ASSUME_NONNULL_END
