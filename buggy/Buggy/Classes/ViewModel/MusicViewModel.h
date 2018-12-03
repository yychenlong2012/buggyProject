//
//  MusicViewModel.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/17.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud.h>
#import "MusicListModel.h"
#import "MusicThemeModel.h"
@interface MusicViewModel : NSObject

/**
 获取主题数据

 @param themeList
 */
+ (void)requestMusicTheme:(void(^)(NSArray<MusicThemeModel *> *datas ,NSError *error))themeList;


/**
 根据AVFile类去取对应的资源

 @param imageFile
 @param success
 @param failure 
 */
+ (void)getMusicThemeImage:(AVFile *)imageFile
                   success:(void(^)(UIImage *image))success
                   failure:(void(^)(NSError *error))failure;

/**
 获取单个主题的音乐列表

 @param page 页数
 @param typeNumber 主题的类型
 @param musiclist
 */
+ (void)requestWithPage:(NSInteger)page typeNumber:(NSInteger)typeNumber
              Musiclist:(void(^)(NSArray *musicList,NSError *failure))musiclist;


/**
 下载歌曲

 @param musicFile 歌曲对应的AVFile描述
 @param progress 音乐下载的进度
 @param success 下载成功
 @param failure 下载失败
 */
+ (void)downLoadMusicToLocal:(AVFile *)musicFile
                    progress:(void (^)(NSInteger progress))progress
                     success:(void(^)(BOOL success))success
                     failure:(void(^)(NSError *error))failure;
+ (void)downLoadMusicToLocal2:(AVFile *)musicFile
                    progress:(void (^)(NSInteger progress))progress
                     success:(void(^)(BOOL success))success
                     failure:(void(^)(NSError *error))failure;

@end
