//
//  NSString+AVLoader.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AVLoader)

/**
 *  临时文件路径
 */
+ (NSString *)tempFilePath;


//歌词缓存路径
+ (NSString *)lrcCachePath;
/**
 *  缓存文件夹路径
 */
+ (NSString *)cacheFolderPath;
+ (NSString *)cacheFolderPath2;

/**
 *  获取网址中的文件名
 */
+ (NSString *)fileNameWithURL:(NSURL *)url;

@end
