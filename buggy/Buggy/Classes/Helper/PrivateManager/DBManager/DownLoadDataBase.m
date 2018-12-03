//
//  DownLoadDataBase.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DownLoadDataBase.h"

@implementation DownLoadDataBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
    }
    return self;
}

//fileName是AVFile中的name   而musicName是该歌曲在数据库中的名字 没有mp3后缀等多余文字
- (void)createTable{
    self.tableName = [NSString stringWithFormat:@"DownLoadMusicList%@",KUserDefualt_Get(USER_ID_NEW)];    //表名
    [super createTable];
    if (self.tableName) {
        [self.dataBase open];
        NSError *error;
        if (![self.dataBase tableExists:self.tableName]) {
            if ([self.dataBase createTableWithName:self.tableName columns:@[@"musicName",@"musicUrl",@"musicImage",@"orderDate"] constraints:@[] error:&error]) {
                DLog(@"Create OK");
            }
            if (error) {
                DLog(@"%@",[error description]);
            }
        }else{ //存在数据表
            //添加字段musicImage
            if (![self.dataBase columnExists:@"musicImage" inTableWithName:self.tableName]){    //判断数据表是否含有musicImage字段
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",self.tableName,@"musicImage"];
                BOOL worked = [self.dataBase executeUpdate:alertStr];
                if(worked){
                    NSLog(@"插入musicImage成功");
                }else{
                    NSLog(@"插入musicImage失败");
                }
            }
            //添加字段fileName  文件的名称
            if (![self.dataBase columnExists:@"fileName" inTableWithName:self.tableName]){    //判断数据表是否含有fileName字段
                
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",self.tableName,@"fileName"];
                BOOL worked = [self.dataBase executeUpdate:alertStr];
                if(worked){
                    NSLog(@"插入fileName成功");
                }else{
                    NSLog(@"插入fileName失败");
                }
            }
            //添加字段time   时长
            if (![self.dataBase columnExists:@"time" inTableWithName:self.tableName]){    //判断数据表是否含有time字段
                
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",self.tableName,@"time"];
                BOOL worked = [self.dataBase executeUpdate:alertStr];
                if(worked){
                    NSLog(@"插入time成功");
                }else{
                    NSLog(@"插入time失败");
                }
            }
            //添加字段musicId   歌曲唯一标识
            if (![self.dataBase columnExists:@"musicId" inTableWithName:self.tableName]){    //判断数据表是否含有musicId字段
                
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",self.tableName,@"musicId"];
                BOOL worked = [self.dataBase executeUpdate:alertStr];
                if(worked){
                    NSLog(@"插入musicId成功");
                }else{
                    NSLog(@"插入musicId失败");
                }
            }
        }
        [self.dataBase close];
    }
}

- (void)addData:(NSDictionary *)data{
    [super addData:data];
    /* 再插入之前先搜索一下是否已经存在相同的歌曲 */
    if ([self isExistOfMusic:data]) {
   
//        NSAssert(![self isExistOfMusic:data], @"该数据已经存在了！");
        DLog(@"对不起，已经下载过了！");
        return;
    }
    [self.dataBase open];
    NSArray *array = [data allKeys];
    NSError *error = nil;
    
    if ([self.dataBase insertInto:self.tableName columns:array values:@[[data allValues]] error:&error]) {
        DLog(@"插入成功");
    }
    if (error) {
        DLog(@"%@",[error description]);
    }
    [self.dataBase close];
}

- (BOOL)isExistOfMusic:(NSDictionary *)data {
    
    NSDictionary *dic = @{@"musicName":data[@"musicName"],@"musicUrl":data[@"musicUrl"]};
    [self.dataBase open];
    NSError *error;
    NSInteger count = [self.dataBase countFrom:self.tableName matchingValues:dic error:&error];
    [self.dataBase close];
    if (count > 0) {
        return YES;
    }
    return NO;
}

@end
