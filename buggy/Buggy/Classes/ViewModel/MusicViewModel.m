//
//  MusicViewModel.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/17.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "MusicViewModel.h"
#import "WNJsonModel.h"
@implementation MusicViewModel

/**
 获取主题数据
 
 @param themeList
 */
+ (void)requestMusicTheme:(void(^)(NSArray<MusicThemeModel *> *datas ,NSError *error))themeList{
    NSMutableArray<MusicThemeModel *> *datas = [NSMutableArray arrayWithCapacity:0];
    AVQuery *query = [AVQuery queryWithClassName:@"MusicTheme"];
    [query orderByAscending:@"themeType"];
    query.maxCacheAge = 10 * 24 * 3600;
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {   //会先查看缓存
        
        for (AVObject *ob in objects) {
            MusicThemeModel *model = [WNJsonModel modelWithDict:ob[@"localData"] className:@"MusicThemeModel"];
            [datas addObject:model];
//            NSLog(@"%@ \n,%@ \n,%@\n,%@ \n,%@ \n,%ld \n",model.themeTitle,model.themeDetails,model.themeImage,model.themeColor,model.themeType,(long)model.themeColorOpacity);
        }
        if (themeList) {
            themeList(datas,error);
        }
    }];
}

/**
 根据AVFile类去取对应的资源
 
 @param imageFile
 @param success
 @param failure
 */
+ (void)getMusicThemeImage:(AVFile *)imageFile
                   success:(void(^)(UIImage *image))success
                   failure:(void(^)(NSError *error))failure{
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            success(image);
        }
        if (error) {
            if (failure) {
                failure(error);
            }
        }
    }];
}

/**
 获取单个主题的音乐列表
 
 @param page 页数
 @param typeNumber 主题的类型
 @param musiclist
 */
+ (void)requestWithPage:(NSInteger)page typeNumber:(NSInteger)typeNumber Musiclist:(void(^)(NSArray *musicList,NSError *failure))musiclist{
    
    NSInteger limit = 15;
    NSMutableArray<MusicListModel*> *List = [NSMutableArray arrayWithCapacity:0];
    AVQuery *query = [AVQuery queryWithClassName:@"MusicList"];
    [query whereKey:@"typeNumber" equalTo:[NSNumber numberWithInteger:typeNumber]];
    [query orderByAscending:@"musicOrder"];
    [query setLimit:limit];
    [query setSkip:limit * page];   //需要跳过的对象数量
    query.maxCacheAge = 3 * 24 * 3600;
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (AVObject *ob in objects) {

            MusicListModel *model = [WNJsonModel modelWithDict:ob[@"localData"] className:@"MusicListModel"];
            
//            NSDictionary *dict = ob[@"localData"];
//            AVFile *musicfile = dict[@"musicFiles"];
//            model.musicFileName = musicfile.name;
            
            [List addObject:model];
//            NSLog(@"%@,%@,%@",model.musicName,model.musicFiles,model.musicFiles.metaData);
        }
        if (musiclist) {
            musiclist(List,error);
        }
    }];
}


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
                     failure:(void(^)(NSError *error))failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!musicFile.isDataAvailable) {
            [musicFile getDataStreamInBackgroundWithBlock:^(NSInputStream *stream, NSError *error) {
                NSLog(@"下载方法stream = %@ %@",stream,error);
                if (failure) {
                    failure(error);
                }
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(YES);
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(NO);
                    });
                }
            } progressBlock:^(NSInteger percentDone) {
                if (progress) {
                    progress(percentDone);
                }
            }];
        }else{
            DLog(@"文件已经下载过了！");
        }
    });
}
/**
下载歌曲   之后修改

@param musicFile 歌曲对应的AVFile描述
@param progress 音乐下载的进度
@param success 下载成功
@param failure 下载失败
*/
+ (void)downLoadMusicToLocal2:(AVFile *)musicFile
                    progress:(void (^)(NSInteger progress))progress
                     success:(void (^)(BOOL success))success
                     failure:(void (^)(NSError *error))failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
     
            [musicFile getDataStreamInBackgroundWithBlock:^(NSInputStream *stream, NSError *error) {
                NSLog(@"下载方法stream = %@ %@",stream,error);
                if (failure) {
                    failure(error);
                }
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(YES);
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(NO);
                    });
                }
            } progressBlock:^(NSInteger percentDone) {
                if (progress) {
                    progress(percentDone);
                }
            }];
   
    });
}

@end
