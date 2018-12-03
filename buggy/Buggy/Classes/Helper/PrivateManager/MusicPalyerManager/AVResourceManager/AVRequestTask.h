//
//  AVRequestTask.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFileHandle.h"

#define RequestTimeout 10.0

@class AVRequestTask;
@protocol AVRequestTaskDelegate <NSObject>

@required

/**
 更新缓存进度的代理方法
 */
- (void)requestTaskDidUpdateCache;  // 更新缓存进度代理方法

@optional

/**
 收到加载任务响应
 */
- (void)requestTaskDidReceiveResponse;

/**
 收到文件已经加载完成

 @param cache 是否做缓存
 */
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache;


/**
 获取数据失败

 @param error 错误的理由
 */
- (void)requestTaskDidFailWithError:(NSError *)error;

@end


@interface AVRequestTask : NSObject

@property (nonatomic ,weak) id<AVRequestTaskDelegate> delegate;

/**
 请求的网址
 */
@property (nonatomic ,strong) NSURL *requestURL;

/**
 请求的起始位置
 */
@property (nonatomic ,assign) NSUInteger requestOffset;

/**
 文件长度
 */
@property (nonatomic ,assign) NSUInteger fileLength;

/**
 缓冲的长度
 */
@property (nonatomic ,assign) NSUInteger cacheLength;

/**
 是否缓存文件
 */
@property (nonatomic ,assign) BOOL cache;

/**
 是否取消请求
 */
@property (nonatomic ,assign) BOOL cancle;

/**
 开始请求
 */
- (void)start;

@end
