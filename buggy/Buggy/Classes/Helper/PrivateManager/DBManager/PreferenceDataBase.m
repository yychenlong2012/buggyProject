//
//  PreferenceDataBase.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "PreferenceDataBase.h"

@implementation PreferenceDataBase

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createTable];
    }
    return self;
}

- (void)createTable{
    
    self.tableName = [NSString stringWithFormat:@"PreferenceList%@",KUserDefualt_Get(USER_ID_NEW)];
    [super createTable];
    if (self.tableName) {
        [self.dataBase open];
        NSError *error;
        if (![self.dataBase tableExists:self.tableName]) {
            if ([self.dataBase createTableWithName:self.tableName columns:@[@"musicName",@"musicUrl",@"musicImage"] constraints:@[] error:&error]) {
                DLog(@"PreferenceTable Create OK");
            }
            if (error) {
                DLog(@"%@",[error description]);
            }
        }else{  //存在数据表
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
            
            //添加字段time  2018 6月12号
            if (![self.dataBase columnExists:@"time" inTableWithName:self.tableName]){    //判断数据表是否含有musicImage字段
                
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",self.tableName,@"time"];
                BOOL worked = [self.dataBase executeUpdate:alertStr];
                if(worked){
                    NSLog(@"插入time成功");
                }else{
                    NSLog(@"插入time失败");
                }
            }
            //添加字段musicId  2018 6月12号
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
    /* 再插入一条数据之前判断是否已经存在 */
    if ([self isExistOfPerference:data]) {
        
        DLog(@"该条喜好数据已经存在了");
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
    
//    [self.dataBase open];
//    NSError *error;
//    NSString *where = [NSString stringWithFormat:@"%@ = '%@' AND %@ = '%@'",@"musicName",data[@"musicName"],@"typeNumber",data[@"typeNumber"]];
//   NSInteger num = [self.dataBase deleteFrom:self.tableName where:where arguments:[data allValues] error:&error];
//    if (error) {
//        DLog(@"删除失败了");
//    }
//    [self.dataBase close];
}

@end
