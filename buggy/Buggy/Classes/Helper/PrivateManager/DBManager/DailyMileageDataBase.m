//
//  DailyMileageDataBase.m
//  Buggy
//
//  Created by goat on 2018/4/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "DailyMileageDataBase.h"

@implementation DailyMileageDataBase

//日里程的数据库
- (instancetype)init{
    if (self = [super init]) {
        [self createTable];
    }
    return self;
}


- (void)createTable{
    
    self.tableName = @"DailyMileageList";
    [super createTable];  //父类未做事
    if (self.tableName) {
        [self.dataBase open];
        NSError *error;
        if (![self.dataBase tableExists:self.tableName]) {
            if ([self.dataBase createTableWithName:self.tableName columns:@[@"date",@"mileage",@"userId"] constraints:@[] error:&error]) {
                DLog(@"Create Ok");
            }
            if (error) {
                DLog(@"%@",[error description]);
            }
        }
        [self.dataBase close];
    }
}
/**
 * date   20180317
 * isDesc yes 表示降序排列
 * limit  返回的数据条数
 */
- (NSArray *)selectMileageDatasLessThan:(NSString *)date isDesc:(BOOL)isDesc limit:(NSString *)limit{
    [self.dataBase open];
    NSError *error;
    
    NSString *sql = [NSString stringWithFormat:@"select mileage, date from DailyMileageList where userId = '%@' and date < '%@' order by date %@ limit %@;",KUserDefualt_Get(USER_ID_NEW),date,isDesc==YES ? @"desc":@"asc",limit];

    FMResultSet *datas = [self.dataBase executeQuery:sql];
    
    NSMutableArray *array = [NSMutableArray array];
    while ([datas next]) {
        NSString *mileage = [datas stringForColumn:@"mileage"];
        NSString *date = [datas stringForColumn:@"date"];
        [array addObject:@{@"mileage":mileage,
                           @"date":date
                           }];
    }

    [self.dataBase close];
    if (error) {
        DLog(@"查询失败%@",error);
        return nil;
    }
    return array;
}
- (void)addData:(NSDictionary *)data{
    [super addData:data];
    /* 是否存在相同的记录 */
    if ([self isExistOfMileage:data]) {
        DLog(@"已经有添加记录了");
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

- (BOOL)isExistOfMileage:(NSDictionary *)data{
    [self.dataBase open];
    NSError *error;
    NSDictionary *values = @{@"date":data[@"date"],
                             @"userId":data[@"userId"]
                             };
    NSInteger count = [self.dataBase countFrom:self.tableName matchingValues:values error:&error];
    [self.dataBase close];
    if (count) {
        return YES;
    }
    return NO;
}

-(void)deleteTable{
    [self.dataBase open];
//    BOOL isSeccess = [self.dataBase executeUpdate:@"delete from DailyMileageList;"];
//    NSLog(@"%d",isSeccess);
    [self.dataBase close];
}


@end
