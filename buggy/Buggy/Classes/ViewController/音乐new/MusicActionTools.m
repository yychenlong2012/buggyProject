//
//  MusicActionTools.m
//  Buggy
//
//  Created by goat on 2018/6/11.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicActionTools.h"
#import "NSString+AVLeanCloud.h"
#import "NSString+AVLoader.h"
#import "AVFileHandle.h"
#import "DownLoadDataBase.h"
#import "PreferenceDataBase.h"
#import "NetWorkStatus.h"
#import "MusicListModel.h"
#import "MusicManager.h"
#import "MusicLikeViewModel.h"
#import "lrcModel.h"


@implementation MusicActionTools
#pragma mark - 下载歌词
//这里的musicName是不加任何后缀和序号的歌名
+ (void)downloadMusicLrcWithName:(NSString *)musicId WithBlock:(void(^)(NSArray *lrcArray))block{
    if (block == nil) {
        return;
    }
    //判断有无该歌词文件夹 没有则创建
    NSString * lrcCachePath = [NSString lrcCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:lrcCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:lrcCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //先查看本地有无歌词
    NSString *path = [NSString stringWithFormat:@"%@/%@.lrc",[NSString lrcCachePath],musicId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        block([self musicLrcWithPath:path]);
    }else{  //不存在则网络请求
//        AVQuery *query = [AVQuery queryWithClassName:@"MusicList"];
//        [query whereKey:@"musicId" equalTo:musicId];
//        [query selectKeys:@[@"lyric"]];
//        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//            if (error == nil && object) {
//                if (object[@"lyric"] != nil) {
//                    if ([object[@"lyric"] isKindOfClass:[AVFile class]]) {  //是否为AVFile类型
//
//                        AVFile *lyric = object[@"lyric"];
//                        [lyric getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//                            if (error == nil && data) {
//                                //获取到歌词data 存入沙盒
//                                NSString *path = [NSString lrcCachePath];
//                                path = [NSString stringWithFormat:@"%@/%@.lrc",path,musicId];
//                                if ([data writeToFile:path atomically:YES]) {
//                                    block([self musicLrcWithPath:path]);
//                                }
//                            }
//                        }];
//
//                    }else if ([object[@"lyric"] isKindOfClass:[NSString class]]) {  //是否为NSString类型  那就是歌词文件url
//
//                        NSURL *url = [NSURL URLWithString:object[@"lyric"]];
//                        if (url) {
//                            NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                            [[[AFHTTPSessionManager manager] downloadTaskWithRequest:request progress:nil destination:nil completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//                                NSLog(@"%@",filePath);
//                                NSData *data = [NSData dataWithContentsOfURL:filePath];
//                                //获取到歌词data 存入沙盒
//                                NSString *path = [NSString lrcCachePath];
//                                path = [NSString stringWithFormat:@"%@/%@.lrc",path,musicId];
//                                if ([data writeToFile:path atomically:YES]) {
//                                    block([self musicLrcWithPath:path]);
//                                }
//                            }] resume];
//                        }
//                    }
//                }
//            }
//        }];
    }
}

//获取歌词模型数组
+(NSMutableArray *)musicLrcWithPath:(NSString *)lrcPath{
    
    // 读取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    // 拿到歌词的数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    // 遍历每一句歌词,转成模型
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrclineString in lrcArray) {
        /*
         [ti:心碎了无痕]
         [ar:张学友]
         [al:]
         */// 过滤不需要的歌词的行
        if ([lrclineString hasPrefix:@"[ti:"] || [lrclineString hasPrefix:@"[ar:"] || [lrclineString hasPrefix:@"[al:"] || ![lrclineString hasPrefix:@"["]) {
            continue;
        }
        // 将歌词转成模型
        lrcModel *model = [lrcModel lrcLineWithLrclineString:lrclineString];
        [tempArray addObject:model];
    }
    return tempArray;
}


#pragma mark - 收藏歌曲
//是否已收藏
+ (void)isLiked:(NSString *)name withBlock:(void(^)(BOOL isLiked))block{
    if (block == nil) {
        return;
    }
    
    PreferenceDataBase *db = [[PreferenceDataBase alloc] init];
    block([db isExistOfPerference:@{@"musicName":name}]);
}

//加入收藏
+ (void)babyLike:(BOOL)isLike{
    if (![NetWorkStatus isNetworkEnvironment]) {
        return;
    }
    //取出当前播放的歌曲模型
    musicModel *model = MUSICMANAGER.audioArray[MUSICMANAGER.currentItemIndex];
    //是否收藏
    if (isLike == NO) {
        //从数据库中删除
        [MusicLikeViewModel removeSelectedMusicFromPreferenceDataBaseTable:model finish:^(BOOL success, NSError *error) {
            DLog(@"%@",[error description]);
        }];
        //取消收藏
        [self setCollected:NO musicName:model.musicname];
    }else{
        // 加入收藏 数据库加入
        [MusicLikeViewModel selectMusicToPreferenceDataBaseTable:model finish:^(BOOL success, NSError *error) {}];
        //新版本加入收藏
        [self setCollected:YES musicName:model.musicname];
    }
}

//新版本加入收藏 上传本地所有操作记录
+ (void)setCollected:(BOOL)isCollected musicName:(NSString *)musicName{
    //本地记录
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@isCollected.plist",KUserDefualt_Get(USER_ID_NEW)];  //KUserDefualt_Get(USER_ID_NEW)   [AVUser currentUser].username
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    
    if ([NetWorkStatus isNetworkEnvironment]) {   //有网则上传本地所有操作记录
        NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
        if (temp) {
            for (NSDictionary *dict in temp) {
                NSString *name = dict[@"musicName"];
                NSString *iscollect = dict[@"is_collected"];
                //上传
                [self setCollectWithMusicName:name isCollect:iscollect];
            }
            [temp removeAllObjects];
            [temp writeToFile:filePath atomically:YES];
        }
        [self setCollectWithMusicName:musicName isCollect:isCollected?@"1":@"0"];
    }else{  //无网 则保存到本地
        NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
        if (temp) {//有字典 则更新
            BOOL isRecode = NO;
            for (NSDictionary *dict in temp) {
                NSString *name = dict[@"musicName"];
                if ([name isEqualToString:musicName]) {
                    isRecode = YES;
                    [dict setValue:(isCollected? @"1" : @"0") forKey:@"is_collected"];
                }
            }
            if (!isRecode) {
                [temp addObject:@{@"musicName":musicName, @"is_collected": (isCollected? @"1" : @"0")}];
            }
            array = temp;
        }else{
            temp = [NSMutableArray arrayWithArray:@[@{@"musicName":musicName, @"is_collected": (isCollected? @"1" : @"0")}]];
            array = temp;
        }
        [array writeToFile:filePath atomically:YES];
    }
}

//  @[
//    @{ @"musicName":@"春",
//       @"is_collected":@"1" },
//    @{ @"musicName":@"春",
//       @"is_down":@"1" }
//   ]
//上传收藏信息
+ (void)setCollectWithMusicName:(NSString *)musicName isCollect:(NSString *)isCollect{
    NSArray *array = @[ @{ @"musicName":musicName==nil?@"":musicName,
                          @"is_collected":isCollect  } ];
    [NETWorkAPI updateMusicWithOperation:array callback:^(BOOL success, NSError * _Nullable error) {
    }];
}

#pragma mark - 下载
//musicName是数据库中音乐的名称 与文件名有一点区别
//歌曲下载后的文件名是歌曲AVFile中name
+ (void)downLoadMusic:(musicModel *)model
             progress:(void(^)(NSInteger progress))progress
              success:(void(^)(void))success
              failure:(void(^)(NSError *error))failure{
    
    //新的下载方法直接从缓存获取
    if ([MusicManager defaultPlayer].cached) {
        NSString *path = [MusicManager defaultPlayer].cacheIdName;
        if ([path isKindOfClass:[NSString class]] && [path containsString:@".metadata"]) {
            NSString *cachePath = [[path componentsSeparatedByString:@".metadata"] firstObject];
            NSLog(@"%@",cachePath);
            if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                
                NSString *fileName = @"";
                if ([model.musicname isKindOfClass:[NSString class]] && model.musicname.length > 0) {
                    fileName = model.musicname;
                }
                if (model.musicid > 0) {
                    fileName = [NSString stringWithFormat:@"%ld",(long)model.musicid];
                }
                //转移文件
                NSFileManager *manager = [NSFileManager defaultManager];
                NSString *cacheFolderPath = [NSString cacheFolderPath];
                if (![manager fileExistsAtPath:cacheFolderPath]) {
                    [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3",cacheFolderPath,fileName];
                if ([manager copyItemAtPath:cachePath toPath:filePath error:nil]) {
                    // 下载完成上传操作记录
                    [self uploadDownloadMessageWithMuiscName:model.musicname];
                    //数据库保存记录
                    DownLoadDataBase *downBD = [[DownLoadDataBase alloc] init];
                    NSString *musicImageUrl;
                    if (model.imageurl == nil || ![model.imageurl isKindOfClass:[NSString class]]) {
                        musicImageUrl = @"";
                    }else{
                        musicImageUrl = model.imageurl;
                    }
                    
                    NSDictionary *dic = @{   @"musicId":model.musicid > 0?[NSString stringWithFormat:@"%ld",model.musicid]:@"0",
                                            @"fileName":@"",
                                            @"musicName":model.musicname == nil? @"":model.musicname,
                                            @"musicUrl":model.musicurl == nil? @"":model.musicurl,
                                            @"musicImage":musicImageUrl,
                                            @"orderDate":model.musicurl == nil? @"":model.musicurl,
                                            @"time":model.time==nil?@"":model.time   };
                    [downBD addData:dic];
                    
                    //删除缓存文件
                    [manager removeItemAtPath:cachePath error:nil];
                    [manager removeItemAtPath:[MusicManager defaultPlayer].cacheIdName error:nil];
                    
                    //成功回调
                    if (success) {
                        success();
                    }
                    DLog(@"下载 = %@", [downBD selectAllDatas]);
                    return;
                }else{
                    DLog(@"下载失败");
                }
            }
        }
    }
}

//上传歌曲下载信息
+ (void)uploadDownloadMessageWithMuiscName:(NSString *)musicName{
    NSArray *array = @[ @{ @"musicName":musicName==nil?@"":musicName,
                           @"is_down":@"1"  } ];
    [NETWorkAPI updateMusicWithOperation:array callback:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

//歌曲下载后的文件名是歌曲AVFile中name   AVFile.name
//歌曲是否已下载
+ (BOOL)isMusicDownloaded:(musicModel *)model{
    if (model.musicid > 0) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",[NSString cacheFolderPath],[NSString stringWithFormat:@"%ld.mp3",model.musicid]];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (exist) {
            return YES;
        }
    }
    if ([model.musicname isKindOfClass:[NSString class]] && model.musicname.length > 0) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",[NSString cacheFolderPath],[NSString stringWithFormat:@"%@.mp3",model.musicname]];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (exist) {
            return YES;
        }
    }
    return NO;
}





//已经不需要
//如果本地有缓存 则返回缓存地址url 没有缓存则返回file  url
//-(NSURL *)getUrlWithAVFile:(AVFile *)file{
//
//    if (file == nil || ![file isKindOfClass:[AVFile class]]) {
//        return nil;
//    }
//    //查看缓存
//    NSString *path = [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"MusicCache2"];
//    NSString *name = file.name;
//    path = [NSString stringWithFormat:@"%@/%@",path,name];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        return [NSURL fileURLWithPath:path];
//    }
//    //返回file、的url
//    return [NSURL URLWithString:file.url];
//}
@end
