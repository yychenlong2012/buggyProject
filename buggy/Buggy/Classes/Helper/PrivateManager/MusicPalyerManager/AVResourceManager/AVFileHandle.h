//
//  AVFileHandle.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+AVLoader.h"
#import "NSURL+AVLoader.h"
@interface AVFileHandle : NSObject

/**
 创建临时文件

 @return
 */
+ (BOOL)createTempFile;


/**
 往临时文件写入数据

 @param data 写入的数据
 */
+ (void)writeTempFileData:(NSData *)data;


/**
 读取临时文件数据

 @param offset 起始位置
 @param length 长度
 @return
 */
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length;


/**
 保存临时文件到缓存文件夹
 
 @param name
 */

+ (void)cacheTempFileWithFileName:(NSString *)name;

/**
 是否存在缓存文件 存在: 返回文件路径 不存在: 返回nil

 @param url
 @return
 */
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url;
+ (NSString *)downloadFileExistsWithName:(NSString *)name;
+ (NSString *)cacheFileExistsWithName:(NSString *)name;
/**
 清空缓存文件
 
 @return
 */
+ (BOOL)clearCache;



#pragma mark --- 根据LeanCloud业务扩展


/**
 将缓存的文件移动到指定的下载的目录下

 @param name 文件姓名（小池.mp3）
 @param path 文件路径
 @param complete
 */
+ (void)loadCacheFileWithFileName:(NSString *)name fromCachePath:(NSString *)path success:(void(^)(NSString *cacheAbsolutelyPath,BOOL finish))complete;
+ (void)loadCacheFile2WithFileName:(NSString *)name fromCachePath:(NSString *)path success:(void(^)(NSString *cacheAbsolutelyPath,BOOL finish))complete;

/**
 检测下载的目录下是否存在该文件

 @param filename 文件姓名
 @return
 */
+ (NSString *)loadFileExistsWithFileName:(NSString *)filename;


/**
 生成硬链接

 @param fileUrl 其实文件路径
 @param expand  扩展
 @return 返回最终的硬连接
 */
+ (NSString *)hardLinkFromUrl:(NSString *)fileUrl withExpand:(NSString *)expand;

@end
