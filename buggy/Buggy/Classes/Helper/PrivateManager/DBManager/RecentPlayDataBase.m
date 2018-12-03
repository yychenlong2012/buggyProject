//
//  RecentPlayDataBase.m
//  Buggy
//
//  Created by goat on 2017/10/17.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "RecentPlayDataBase.h"

#define maxDataCount 40    //最大的保存个数

@implementation RecentPlayDataBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
    }
    return self;
}

- (void)createTable{
    
    self.tableName = @"RecentPlayList";    //最近播放数据库
    [super createTable];
    if (self.tableName) {
        [self.dataBase open];
        NSError *error;
        if (![self.dataBase tableExists:self.tableName]) {
            if ([self.dataBase createTableWithName:self.tableName columns:@[@"musicName",@"musicUrl"] constraints:@[] error:&error]) {
                DLog(@"数据库创建成功");
            }
            if (error) {
                DLog(@"%@",[error description]);
            }
        }else{  //存在数据表
        
            //添加字段musicImage
//            if (![self.dataBase columnExists:@"musicImage" inTableWithName:@"RecentPlayList"]){    //判断数据表是否含有musicImage字段
//                
//                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"RecentPlayList",@"musicImage"];
//                BOOL worked = [self.dataBase executeUpdate:alertStr];
//                if(worked){
//                    NSLog(@"插入musicImage成功");
//                }else{
//                    NSLog(@"插入musicImage失败");
//                }
//            }

        }
        [self.dataBase close];
    }
}

- (void)addData:(NSDictionary *)data{
    [super addData:data];
    
    //在插入之前 先删除重复的记录
    NSString *name = data[@"musicName"];
    [self removeData:@{@"musicName":name}];
//    NSArray *TotalArray1 = [self selectAllDatas];
//    for (NSDictionary *dict in TotalArray1) {
//        NSString *name = dict[@"musicName"];
//        if ([name isEqualToString:data[@"musicName"]]) {
//            //删除重复
//            [self removeData:@{@"musicName":name}];
//        }
//    }
    
    //再插入一条数据之前 先判断数据库中有多少数据  多于指定条数 则删除后面的保存新的
    NSArray *TotalArray2 = [self selectAllDatas];
    if (TotalArray2.count >= maxDataCount) {
        //删除最后一条数据
        NSDictionary *dict = [TotalArray2 firstObject];
        NSDictionary *dic = @{@"musicName":dict[@"musicName"]};
        [self removeData:dic];
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

- (BOOL)isExistOfPerference:(NSDictionary *)data{
    [self.dataBase open];
    NSError *error;
    
    //根据歌名作为查询条件   之前的查询条件就是data 没必要
    NSDictionary *dict = @{ @"musicName":data[@"musicName"] };
    NSUInteger count = [self.dataBase count:nil from:self.tableName matchingValues:dict error:&error];
    [self.dataBase close];
    if (count > 0) {
        return YES;
    }
    return NO;
}

- (NSInteger)numberOfPerference{
    [self.dataBase open];
    NSError *error;
    NSUInteger number = [self.dataBase countFrom:self.tableName error:&error];
    if (!error) {
        return number;
    }
    DLog(@"%lu",(unsigned long)number);
    return 0;
}

- (void)removeData:(NSDictionary *)data{
    
    [super removeData:data];
}



@end
