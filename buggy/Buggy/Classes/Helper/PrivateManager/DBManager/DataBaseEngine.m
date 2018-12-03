//
//  DataBaseEngine.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DataBaseEngine.h"
#import <FMResultSet+FMDBHelpers.h>
#import "CacheManager.h"
#import <sqlite3.h>
#import "MusicListModel.h"
@implementation DataBaseEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDataBase];
    }
    return self;
}

- (void)createDataBase{
    
    NSString *name = [NSString stringWithFormat:@"Buggy_Music.db"];
    NSString *path = [[CacheManager manager] cachePathWithName:name];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        self.dataBase = [FMDatabase databaseWithPath:path];
        [self.dataBase setShouldCacheStatements:YES];
    }else{
        self.dataBase = [FMDatabase databaseWithPath:path];
    }
}

- (void)createTable{}

- (BOOL)dropTable{
    [self.dataBase open];
    if ([self.dataBase tableExists:self.tableName]) {
        NSError *error = nil;
        if ([self.dataBase dropTableIfExistsWithName:self.tableName error:&error]) {
            DLog(@"Drop -%@- Success",self.tableName);
            return YES;
        }
        if (error) {
            DLog(@"Drop Fail:%@",error);
            return NO;
        }
    }
    [self.dataBase close];
    return NO;
    
}



- (NSArray *)selectAllDatas{
    [self.dataBase open];
    NSError *error;
    NSArray *datas;
    datas = [self.dataBase selectAllFrom:self.tableName orderBy:nil error:&error];
    [self.dataBase close];
    if (error) {
        DLog(@"查询失败%@",error);
        return nil;
    }
    return datas;
}

- (void)addData:(NSDictionary *)data{
    
}

- (void)addBatchDatas:(NSArray *)datas{
    [self.dataBase open];
    NSArray *coleumns = [[datas firstObject] allKeys];
    NSError *error = nil;
    NSMutableArray *needEdit = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSDictionary *dic in datas) {
        if ([self.dataBase insertInto:self.tableName columns:coleumns values:@[[dic allValues]] error:&error]) {
            DLog(@"Add Success");
        }
        if (error) {
            if (error.code == SQLITE_CONSTRAINT) {
                [needEdit addObject:dic];
            }
            DLog(@"%@",[error description]);
        }
    }
    [self.dataBase close];
    [self editBatchDatas:needEdit];
}

- (void)editBatchDatas:(NSArray *)datas{
    [self.dataBase open];
    for (NSDictionary *dic in datas) {
        NSString *where = [NSString stringWithFormat:@"%@ = '%@'",self.where,dic[self.where]];
        NSError *error;
        if ([self.dataBase update:self.tableName values:dic where:where arguments:nil error:&error]) {
            DLog(@"Edite Ok");
        }
        if (error) {
            DLog(@"%@",error);
        }
    }
    [self.dataBase close];
}

- (void)editData:(NSArray *)data{
    [self.dataBase open];
}

- (void)removeDatas:(NSArray *)datas{
    [self.dataBase open];
    
}

- (void)removeData:(NSDictionary *)data{
    [self.dataBase open];
    NSError *error;
    if ([self.dataBase deleteFrom:self.tableName matchingValues:data error:&error] == 1) {
        DLog(@"删除成功");
    }
    if (error) {
        DLog(@"删除失败");
    }
    [self.dataBase close];
}
@end
