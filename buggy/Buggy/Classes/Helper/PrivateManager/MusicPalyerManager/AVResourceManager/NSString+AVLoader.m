//
//  NSString+AVLoader.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "NSString+AVLoader.h"

@implementation NSString (AVLoader)

+ (NSString *)tempFilePath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp3"];
}

//歌曲下载文件存放的位置
+ (NSString *)cacheFolderPath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"MusicCache%@",KUserDefualt_Get(USER_ID_NEW)]];
}

//歌词缓存路径
+ (NSString *)lrcCachePath{
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"lrcCache%@",KUserDefualt_Get(USER_ID_NEW)]];
}

//歌曲缓存文件存放位置
//  /var/mobile/Containers/Data/Application/A826F4F3-5868-48D7-9272-1653F46EFC7D/Documents/MusicCache2
+ (NSString *)cacheFolderPath2 {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"MusicCache2"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    return [[url.path componentsSeparatedByString:@"/"] lastObject];
}

@end
