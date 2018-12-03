//
//  MusicRecentViewModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicRecentViewModel.h"
#import "WNJsonModel.h"

@implementation MusicRecentViewModel

+ (void)addMusicToRecentList:(MusicListModel *)musicModel finish:(Finish)finish{
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"MusicRecent"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"musicName" equalTo:musicModel.musicName];
    AVObject *object = nil;
    NSError *error;
    object = [query getFirstObject:&error];
    if (object) {
        [object setObject:musicModel.musicName forKey:@"musicName"];
        [object setObject:musicModel.musicFiles forKey:@"musicFiles"];
//        [object setObject:@(musicModel.typeNumber) forKey:@"typeNumber"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (finish) {
                finish(succeeded,error);
            }
        }];
        return;
    }
    object = [AVObject objectWithClassName:@"MusicRecent"];
    [object setObject:user forKey:@"user"];
    [object setObject:musicModel.musicName forKey:@"musicName"];
    [object setObject:musicModel.musicFiles forKey:@"musicFiles"];
//    [object setObject:@(musicModel.typeNumber) forKey:@"typeNumber"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (finish) {
            finish(succeeded,error);
        }
    }];
}

+ (void)removeSelectedMusicFromRecentList:(MusicListModel *)musicModel finish:(Finish)finish{
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"MusicRecent"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"musicName" equalTo:musicModel.musicName];
    NSError *error;
    AVObject *object = nil;
    object = [query getFirstObject:&error];
    if (object) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                finish(NO,error);
                return;
            }
            finish(YES,error);
        }];
    }
}

+ (void)getRecentedWithPage:(NSInteger)page List:(void(^)(NSArray *datas,NSError *error))finish{
    NSInteger limit = 15;
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"MusicRecent"];
    [query selectKeys:@[@"musicFiles",@"musicName",@"typeNumber"]];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"updatedAt"];
    [query setLimit:limit];
    [query setSkip:limit * page];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query setMaxCacheAge:365 * 24 * 3600];
    __block NSMutableArray<MusicLikeModel *> *dataArray = [NSMutableArray arrayWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray<MusicLikeModel *> *objects, NSError *error) {
       
        for (NSDictionary *dic in objects) {
            
            MusicLikeModel *likeModel = [WNJsonModel modelWithDict:dic[@"localData"] className:@"MusicLikeModel"];
            [dataArray addObject:likeModel];
        }
        finish(dataArray,nil);
    }];
}

@end
