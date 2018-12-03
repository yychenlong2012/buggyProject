//
//  BabyStrollerManager.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/21.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteHander)(NSDictionary *dic,BOOL success);

@interface BabyStrollerManager : NSObject

/**
 更新A1推车信息

 @param param A1推车信息
 @param success 成功
 */
+ (void)postA1Travel:(NSDictionary *)param complete:(CompleteHander )success;


/**
 更新A3推车信息

 @param param A3推车信息
 @param success 成功
 */
+ (void)postA3Travel:(NSDictionary *)param complete:(CompleteHander )success;

/**
 获取推车信息

 @param page 根据page
 @param success 成功
 */
+ (void)getTravelWithPage:(NSInteger)page complete:(void(^)(NSArray *datas))success;
 

@end
