//
//  MusicActionTools.h
//  Buggy
//
//  Created by goat on 2018/6/11.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MusicListModel;

@interface MusicActionTools : NSObject
//下载歌词
+ (void)downloadMusicLrcWithName:(NSString *)musicId WithBlock:(void(^)(NSArray *lrcArray))block;

//是否已收藏
+ (void)isLiked:(NSString *)name withBlock:(void(^)(BOOL isLiked))block;

//收藏歌曲
+ (void)babyLike:(BOOL)isLike;

//下载音乐
+ (void)downLoadMusic:(musicModel *)model
             progress:(void(^)(NSInteger progress))progress
              success:(void(^)(void))success
              failure:(void(^)(NSError *error))failure;
//歌曲是否已下载
+ (BOOL)isMusicDownloaded:(musicModel *)model;
@end
