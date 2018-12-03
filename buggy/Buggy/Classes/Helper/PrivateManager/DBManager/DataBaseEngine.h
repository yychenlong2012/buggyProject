//
//  DataBaseEngine.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import <FMDBHelpers.h>
#import <FMDatabaseAdditions.h>

@interface DataBaseEngine : NSObject

@property (nonatomic ,copy) NSString *tableName;
@property (nonatomic ,strong) FMDatabase *dataBase;

@property (nonatomic ,copy) NSString *orderBy;   //顺序
@property (nonatomic ,copy) NSString *where;
@property (nonatomic ,copy) NSArray *arguments;

@property (nonatomic ,assign) NSInteger limit;
@property (nonatomic ,assign) NSInteger offset;


// 表的全局操作
- (void)createDataBase;
- (void)createTable;
- (BOOL)dropTable;

// 增
- (void)addData:(NSDictionary *)data;
- (void)addBatchDatas:(NSArray *)datas;

// 删
- (void)removeDatas:(NSArray *)datas;
- (void)removeData:(NSDictionary *)data;

// 改
- (void)editData:(NSArray *)data;
- (void)editBatchDatas:(NSArray *)datas;

// 查
- (NSArray *)selectAllDatas;

@end
