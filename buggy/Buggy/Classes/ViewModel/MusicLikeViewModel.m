//
//  MusicLikeModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicLikeViewModel.h"
#import "WNJsonModel.h"
#import "PreferenceDataBase.h"
#import "NetWorkStatus.h"


@implementation MusicLikeViewModel

#pragma mark --- LeanCloud

//喜欢
//+ (void)selectMusicToLikeList:(MusicListModel *)musicModel finish:(Finish)finish{
//
//    AVUser *user = [AVUser currentUser];
//    AVQuery *query = [AVQuery queryWithClassName:@"Music_relate_user"];
//    [query whereKey:@"post_user" equalTo:user];
//    [query whereKey:@"musicName" equalTo:musicModel.musicName];
//
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//
//        @synchronized (self) {
//            if (object) {   //查到了说明已经有记录了
//                [object setObject:@"1" forKey:@"is_collected"];
//                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//
//                    if (finish) {
//                        finish(succeeded,error);
//                    }
//                }];
//            }else
//            {   //这下面绝大部分情况不会调用  因为能够点击收藏 那肯定有网 并且一定在播放界面  只有在收藏列表里面才可能运行下面的代码
//                if (error != nil && error.code == 101) {
//                    object = [AVObject objectWithClassName:@"Music_relate_user"];
//                    [object setObject:user forKey:@"post_user"];
//                    [object setObject:musicModel.musicName forKey:@"musicName"];
//                    [object setObject:@"1" forKey:@"is_collected"];
//                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        NSLog(@"上传操作 错误信息 = %@ 正确信息 = %d",error,succeeded);
//                        if (finish) {
//                            finish(succeeded,error);
//                        }
//                    }];
//
//                }
//            }
//
//        }
//    }];
//}
//之前的版本是直接移除那条记录  现在是直接更新是否收藏的那个字段   不喜欢
//+ (void)removeSelectedMusicFromLikeList:(MusicListModel *)musicModel finish:(Finish)finish{
//
//    AVUser *user = [AVUser currentUser];
//    AVQuery *query = [AVQuery queryWithClassName:@"Music_relate_user"];
//    [query whereKey:@"post_user" equalTo:user];
//    [query whereKey:@"musicName" equalTo:musicModel.musicName];
//    NSError *error;
//    AVObject *object = nil;
//    object = [query getFirstObject:&error];
//    if (object) {
//        [object setObject:@"0" forKey:@"is_collected"];
//        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                finish(NO,error);
//            }else{
//                finish(YES,error);
//            }
//        }];
//    }
//}

+ (void)getLikelWithPage:(NSInteger)page List:(void(^)(NSArray *datas,NSError *error))finish{
    /* LocalData */
    PreferenceDataBase *dataBase = [[PreferenceDataBase alloc] init];
    dataBase.where = @"musicName";
    
    //无网络则读取数据库中的数据   不管有无网络都调用本地数据
//    if (![NetWorkStatus isNetworkEnvironment]) {
    
    NSArray *DBArray = [dataBase selectAllDatas];
    NSMutableArray<musicModel *> *dataArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in DBArray) {
        
          //MusicListModel
        musicModel *model = [[musicModel alloc] init];
        
        if (dict[@"musicName"]) {
            model.musicname = dict[@"musicName"];
        }
        
        if (dict[@"musicUrl"]) {
            model.musicurl = dict[@"musicUrl"];
//            NSString *url = dict[@"musicUrl"];
//            AVFile *file = [AVFile fileWithURL:url];
//            model.musicFiles = file;
        }
        
        if ([dict[@"musicImage"] isKindOfClass:[NSNull class]]) {
            
        }else{
            model.imageurl = dict[@"musicImage"];
//            AVFile *musicImage = [AVFile fileWithURL:dict[@"musicImage"]];
//            model.musicImage = musicImage;
        }
        
        if (dict[@"time"]) {
            model.time = dict[@"time"];
        }
    
        if (dict[@"musicId"] != nil && ![dict[@"musicId"] isKindOfClass:[NSNull class]]) {
            model.musicid = [dict[@"musicId"] integerValue];
        }
        [dataArray addObject:model];
    }
    finish(dataArray,nil);
    return;
//    }
    
    //以下网络数据不用获取了  没有音乐文件
    /* LeanCloud 数据 */
    /*
    NSInteger limit = 15;
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"Music_relate_user"];
    [query selectKeys:@[@"musicFiles",@"musicName"]];   //要获得那两个字段
    [query whereKey:@"post_user" equalTo:user];             //筛选条件
    [query orderByDescending:@"createdAt"];
    [query setLimit:limit];
    [query setSkip:limit * page];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query setMaxCacheAge:365 * 24 * 3600];
    __block NSMutableArray<MusicLikeModel *> *dataArray2 = [NSMutableArray arrayWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray<MusicLikeModel *> *objects, NSError *error) {
        for (NSDictionary *dic in objects) {
            MusicLikeModel *likeModel = [WNJsonModel modelWithDict:dic[@"localData"] className:@"MusicLikeModel"];
            [dataArray addObject:likeModel];
            //每次请求leancloud的数据都会保存到数据库
            //            NSDictionary *dic = @{@"musicName":likeModel.musicName,@"musicUrl":kStringConvertNull(likeModel.musicFiles.url),@"typeNumber":@(likeModel.typeNumber)};
            NSLog(@"%@",likeModel.musicFiles);
            if (likeModel.musicFiles != nil) {
                NSDictionary *dic = @{@"musicName":likeModel.musicName,@"musicUrl":likeModel.musicFiles.url};
                [dataBase addData:dic];
            }
        }
        finish(dataArray,nil);
    }];

     */
    
//    NSInteger limit = 15;
//    AVUser *user = [AVUser currentUser];
////    AVQuery *query = [AVQuery queryWithClassName:@"MusicPrefer"];
////    [query selectKeys:@[@"musicFiles",@"musicName",@"typeNumber"]];
//    AVQuery *query = [AVQuery queryWithClassName:@"Music_relate_user"];
//    [query selectKeys:@[@"musicFiles",@"musicName"]];
//    [query whereKey:@"user" equalTo:user];
//    [query orderByDescending:@"createdAt"];
//    [query setLimit:limit];
//    [query setSkip:limit * page];
//    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
//    [query setMaxCacheAge:365 * 24 * 3600];
//    __block NSMutableArray<MusicLikeModel *> *dataArray = [NSMutableArray arrayWithCapacity:0];
//    [query findObjectsInBackgroundWithBlock:^(NSArray<MusicLikeModel *> *objects, NSError *error) {
//        for (NSDictionary *dic in objects) {
//            MusicLikeModel *likeModel = [WNJsonModel modelWithDict:dic[@"localData"] className:@"MusicLikeModel"];
//            [dataArray addObject:likeModel];
//            //每次请求leancloud的数据都会保存到数据库 
////            NSDictionary *dic = @{@"musicName":likeModel.musicName,@"musicUrl":kStringConvertNull(likeModel.musicFiles.url),@"typeNumber":@(likeModel.typeNumber)};
//            NSDictionary *dic = @{@"musicName":likeModel.musicName,@"musicUrl":kStringConvertNull(likeModel.musicFiles.url)};
//            [dataBase addData:dic];
//        }
//        finish(dataArray,nil);
//    }];
}

#pragma mark -- DataBase 

+ (void)selectMusicToPreferenceDataBaseTable:(musicModel *)musicModel finish:(Finish)finish{

    NSString *url;
//    if (musicModel.musicFiles && [musicModel.musicFiles isKindOfClass:[AVFile class]]) {
//        url = musicModel.musicFiles.url == nil ? @"" : musicModel.musicFiles.url;
//    }else{
        if (musicModel.musicurl && [musicModel.musicurl isKindOfClass:[NSString class]]) {
            url = musicModel.musicurl;
        }else{
            url = @"";
        }
//    }
    
    NSString *image;
//    if (musicModel.musicImage && [musicModel.musicImage isKindOfClass:[AVFile class]]) {
//        image = musicModel.musicImage.url == nil ? @"" : musicModel.musicImage.url;
//    }else{
        if (musicModel.imageurl) {
            image = musicModel.imageurl;
        }else{
            image = @"";
        }
//    }
    
    NSString *time;
    if (musicModel.time == nil) {
        time = @"";
    }else{
        time = musicModel.time;
    }
    
    NSString *musicId;
    if (musicModel.musicid == 0) {
        musicId = @"0";
    }else{
        musicId = [NSString stringWithFormat:@"%ld",musicModel.musicid];
    }
    
    NSDictionary *dic = @{ @"musicId":musicId,
                          @"musicName":musicModel.musicname == nil ? @"" : musicModel.musicname,
                           @"musicUrl":url,
                           @"musicImage":image,
                           @"time":time
//                          @"typeNumber":@(musicModel.typeNumber),
                          };
    PreferenceDataBase *dataBase = [[PreferenceDataBase alloc] init];
    [dataBase addData:dic];
    finish(YES,nil);
}

+ (void)removeSelectedMusicFromPreferenceDataBaseTable:(musicModel *)musicModel finish:(Finish)finish{
    
    NSDictionary *dic = @{@"musicName":musicModel.musicname == nil ? @"" : musicModel.musicname
//                          @"typeNumber":@(musicModel.typeNumber),
//                          @"musicUrl" :musicModel.musicFiles.url == nil ? @"" : musicModel.musicFiles.url
                         };
    PreferenceDataBase *dataBase = [[PreferenceDataBase alloc] init];
    [dataBase removeData:dic];
    finish(YES,nil);
}

+ (void)getpRreferenceListWithPage:(NSInteger)page List:(void (^)(NSArray *array, NSError *error))finish{
    
    PreferenceDataBase *dataBase = [[PreferenceDataBase alloc] init];
    NSArray *array = [dataBase selectAllDatas];
    if (array.count == 0) {
        DLog(@"用户喜好列表为空");
        finish(nil,nil);
    }else{
        finish(array,nil);
    }
}

@end
