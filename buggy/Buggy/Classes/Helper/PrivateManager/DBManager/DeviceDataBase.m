//
//  DeviceDataBase.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceDataBase.h"
@implementation DeviceDataBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        [super createTable];
    }
    return self;
}

- (void)createTable{
    
    self.tableName = @"DeviceList";
    [super createTable];
    if (self.tableName) {
        [self.dataBase open];
        NSError *error;
        if (![self.dataBase tableExists:self.tableName]) {
            if ([self.dataBase createTableWithName:self.tableName columns:@[@"bluetoothBind",@"deviceType",@"bluetoothDeviceId",@"bluetoothUUID"] constraints:@[] error:&error]) {
                DLog(@"Create Ok");
            }
            if (error) {
                DLog(@"%@",[error description]);
            }
        }
        [self.dataBase close];
    }
}

- (void)addData:(NSDictionary *)data{
    [super addData:data];
    /* 是否存在相同的歌曲 */
    if ([self isExistOfMusic:data]) {
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

- (BOOL)isExistOfMusic:(NSDictionary *)data{
    [self.dataBase open];
    NSError *error;
    NSInteger count = [self.dataBase countFrom:self.tableName matchingValues:data error:&error];
    [self.dataBase close];
    if (count) {
        return YES;
    }
    return NO;
}

- (void)removeData:(NSDictionary *)data{
    [self.dataBase open];
    NSError *error;
    [self.dataBase deleteFrom:self.tableName where:@"bluetoothUUID" arguments:@[data[@"bluetoothUUID"]] error:&error];
    if (error) {
        DLog(@"删除失败");
    }else{
        DLog(@"删除成功");
    }
}



@end
