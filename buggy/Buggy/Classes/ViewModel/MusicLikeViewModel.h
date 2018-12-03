//
//  MusicLikeModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicLikeModel.h"
#import "MusicListModel.h"
typedef void(^Finish)(BOOL success,NSError *error);

@interface MusicLikeViewModel : NSObject

+ (void)selectMusicToLikeList:(MusicListModel *)musicModel
                       finish:(Finish)finish;

+ (void)removeSelectedMusicFromLikeList:(MusicListModel *)musicModel
                                 finish:(Finish)finish;

+ (void)getLikelWithPage:(NSInteger)page
                    List:(void(^)(NSArray *datas,NSError *error))finish;


/**
 将选中的歌曲信息添加到数据库中

 @param musicModel 选中的歌曲信息
 @param finish
 */
+ (void)selectMusicToPreferenceDataBaseTable:(musicModel *)musicModel finish:(Finish)finish;


/**
 删除选中的歌曲

 @param musicModel 选中的歌曲信息
 @param finish
 */
+ (void)removeSelectedMusicFromPreferenceDataBaseTable:(musicModel *)musicModel finish:(Finish)finish;


/**
 分页获取数据库数据信息(基本上用不到)
 
 @param page
 @param finish
 */
+ (void)getpRreferenceListWithPage:(NSInteger)page List:(void (^)(NSArray *array, NSError *error))finish;

@end
