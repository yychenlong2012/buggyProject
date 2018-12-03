//
//  UserModel.h
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseModel.h"
#import <AVOSCloud.h>

@interface UserModel : BaseModel<NSCoding>

//#pragma mark --- 孩子信息
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *birthday;
@property (nonatomic, strong)AVFile *userImage;
@property (nonatomic, strong)NSString *bluetoothUUID; // 绑定蓝牙设备的UUID号
@property (nonatomic, strong)NSString *native;
@property (nonatomic, strong)NSString *sex;
@property (nonatomic, strong)NSString *age;           //今日年龄

@property (nonatomic, strong)NSString *weight;        //今日宝宝体重
@property (nonatomic, strong)NSString *height;        //今日的身高
@property (nonatomic, strong)NSString *heightRange;   // 身高范围
@property (nonatomic, strong)NSString *weightRange;   // 体重范围


#pragma mark === 推车信息
@property (nonatomic, strong)NSString *todayMilage;   // 今天的里程
@property (nonatomic, strong)NSString *todayVelocity; // 今天的速度
@property (nonatomic, strong)NSString *totalMilage;   // 总里程

#pragma mark --- 父母信息
@property (nonatomic ,strong)NSString *parentsWeight;    //父(母)体重
@property (nonatomic ,strong)NSString *parentsTodayKcal; // 父(母)今日卡路里
@property (nonatomic ,strong)NSString *parentsTotalKcal; // 父母总的卡路里
//

+ (instancetype)model;
///**
// *  获取用户所有信息
// *
// *  @param block 回调的是以UserModel为基本模型的对象
// */
 - (void)getUserInfo:(void(^)(UserModel *userModel))block;
//
//
///**
// 获取用户部分信息(bluetooth,birthday)
//
// @param success 回调成功
// */
//- (void)getBabyBluetoothUUID:(void(^)(NSString *bluetooth,NSString *birthday))success;
//
///*
// 更新某个属性 param
// item:  更新属性的值
// key:   更新属性的key
// complete:  完成的block
// */
//- (void)updateItemInBabyInfo:(NSString *)item key:(NSString *)key complete:(void (^)(NSString * item))success ;
///*
// 更新多个属性 param
// item:  更新属性的字典 例： @{@"name":@"sangeyoui",@"sex":@"小公举",@"header",filePath}
// key:   更新属性的key
// complete:  完成的block
// */
//- (void)updateItemsInBabyInfo:(NSDictionary *)items complete:(void(^)(NSError *error))success;
//
//
///**
// *  上传文件
// *
// *  @param data  文件流
// *  @param block 回调是否失败
// */
//- (void)uploadData:(NSData *)data complete:(void(^)(NSError *error))block;
//- (void)uploadData:(NSData *)data name:(NSString *)name;
//- (NSString *)getAgeSince:(NSDate *)date;

/**
 *  是否隐藏其他登录界面
 *
 *  @return
 */
- (BOOL)hideOpenIDOAuth;

/**
 *  是否有最新的版本
 *
 *  @return
 */
- (BOOL)hasNewVersion;

/**
 *  是否隐藏版本更新提示
 *
 *  @return
 */
- (BOOL)hideVersionCell;
-(void)getNewestVersion:(void (^)(AVObject *object,NSError *error))success;

@end
