//
//  MusicRecentViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicLikeModel.h"
#import "MusicListModel.h"

typedef void(^Finish)(BOOL success,NSError *error);

@interface MusicRecentViewModel : NSObject


/**
 添加最近一次的播放记录

 @param musicModel
 @param finish
 */
+ (void)addMusicToRecentList:(MusicListModel *)musicModel
                       finish:(Finish)finish;


/**
 删除选中的音乐播放记录

 @param musicModel
 @param finish
 */
+ (void)removeSelectedMusicFromRecentList:(MusicListModel *)musicModel
                                 finish:(Finish)finish;

/**
 获取最近的播放记录列表(数据只保留10天内的数据，10天以前的通过云函数删除掉)

 @param page
 @param finish
 */
+ (void)getRecentedWithPage:(NSInteger)page
                    List:(void(^)(NSArray *datas,NSError *error))finish;

@end
