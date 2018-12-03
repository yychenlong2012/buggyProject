//
//  HealthModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/2/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"
#import "BabyModel.h"
@interface HealthModel : BaseModel

@property (nonatomic, copy)NSString *weight;        //今日宝宝体重
@property (nonatomic, copy)NSString *height;        //今日的身高
@property (nonatomic, copy)NSString *heightRange;   // 身高范围
@property (nonatomic, copy)NSString *weightRange;   // 体重范围

+ (instancetype)manager;

/**
 获取今天的身高和体重，并且获取对应的身高和范围
 
 @param complement 完成的回调
 */
- (void)getTodayHeightAndWeight:(void(^)(HealthModel *model,NSError *error))complement;

#pragma mark --- 体重
/**
 *  更新体重对象
 *
 *  @param weight  体重
 *  @param date    在什么时间更新的体重
 *  @param success 成功的回调，包含体重和日期
 */
+ (void)postWeight:(NSString *)weight date:(NSString *)date complete:(void(^)(NSString *weight, NSString *date))success;

/**
 *  根据日期拿体重
 *
 *  @param date    开始日期
 *  @param success 一个月的信息
 */
+ (void)getWeightStartDate:(NSString *)date complete:(void(^)(NSArray *dates))success;

/**
 *  根据page数获取体重
 *
 *  @param page    页面数
 *  @param success 体重数据（一次10个）
 */
+ (void)getWeightWithPage:(NSInteger)page complete:(void(^)(NSArray *dates))success;


#pragma mark --- 健康

/**
 *  根据年龄、性别获取健康数据
 *
 *  @param age     年龄
 *  @param gender  性别
 *  @param success 健康数据
 */
- (void)getHeathState:(NSString *)age gender:(NSString *)gender complete:(void(^)(NSArray *array))success;

#pragma mark --- 身高

/**
 上传身高，附加时间
 
 @param weight 身高
 @param date 日期
 @param success 成功的回调，包含身高和日期
 */
+ (void)postHeight:(NSString *)weight date:(NSString *)date complete:(void(^)(NSString *weight, NSString *date))success;


/**
 根据指定日期获取身高数据（默认获得身高 1个月数据）
 
 @param date 指定的日期
 @param success 成功回调的数组
 */
+ (void)getHeightStartDate:(NSString *)date complete:(void(^)(NSArray *dates))success;



/**
 根据页码数获取身高数据
 
 @param page 指定的页码
 @param success 成功回调的数组
 */
+ (void)getHeightWithPage:(NSInteger)page complete:(void(^)(NSArray *dates))success;


/**
 删除某一天体重
 
 @param date 删除的日期
 @param block
 */
+ (void)deleteWeight:(NSDate *)date complete:(void(^)(NSError *error))block;


/**
 删除某一天身高
 
 @param date 删除的日期
 @param block
 */
+ (void)deleteHeight:(NSDate *)date complete:(void(^)(NSError *error))block;




@end
