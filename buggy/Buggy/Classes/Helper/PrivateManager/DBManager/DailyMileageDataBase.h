//
//  DailyMileageDataBase.h
//  Buggy
//
//  Created by goat on 2018/4/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "DataBaseEngine.h"

@interface DailyMileageDataBase : DataBaseEngine
/**
 * date   20180317
 * isDesc yes 表示降序排列
 * limit  返回的数据条数
 */
- (NSArray *)selectMileageDatasLessThan:(NSString *)date isDesc:(BOOL)isDesc limit:(NSString *)limit;
-(void)deleteTable;
@end
