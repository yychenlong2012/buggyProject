//
//  TripsManager.h
//  Buggy
//
//  Created by 孟德林 on 16/9/19.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseModel.h"
#import <AVOSCloud.h>

@interface TripsManager : BaseModel

#pragma mark ---  行程主页
/**
 *  获取里程是否已经在记录的标识符
 *
 *  @param success 成功获取字符串
 */
+(void)getIsHasStorePathIdentifier:(void(^)(NSString *))success
                             faile:(void(^)(NSError *error))faile;
/**
 *  更新标识符
 *
 *  @param indentifier 更新到数据库的标示符
 */
+(void)updateIsHasStorePathIdentifier:(NSString *)identifier
                              success:(void(^)(BOOL json))success
                                faile:(void(^)(NSError *error))faile;

/**
 *  开始上传经纬点数据，并添加开始时间
 *
 *  @param array   经纬度坐标集合
 *  @param sucess  成功
 *  @param error   失败
 */
+(void)beginUploadLocationArray:(NSDictionary *)location
                        success:(void(^)(BOOL finish))sucess
                          faile:(void(^)(NSError *))faile;
/**
 *  结束上传经纬点数据，并添加结束时间
 *
 *  @param location
 *  @param sucess
 *  @param error
 */
+(void)endUploadLocationArray:(CLLocation *)location
                        success:(void (^)(BOOL finish))sucess
                          faile:(void (^)(NSError *))faile;


/**
 *  获取经纬度坐标(实时获取最近一次的经纬度坐标)
 *
 *  @param success 成功
 */
+(void)getLocationArraySuccess:(void(^)(NSArray *arrayLocation,
                                        NSError *error))success;


#pragma mark -----查询历史行程

/**
 *  查询历史行程
 *
 *  @param page    页码数
 *  @param success 成功获取数组
 *  @param faile   失败返回错误信息
 */
+(void)getHistoryTrackRecordWithPage:(NSInteger)page
                             suceess:(void(^)(NSArray *loctionArray)) success
                               faile:(void(^)(NSError *error))faile;



#pragma mark ----删除行程

/**
 *  删除某条行程
 *
 *  @param date     根据日期删除
 *  @param complete 完成回调
 */
+(void)deleteHistoryTrackRecordWith:(NSDate *)date
                           complete:(void(^)(BOOL success, NSError *error))complete;
@end
