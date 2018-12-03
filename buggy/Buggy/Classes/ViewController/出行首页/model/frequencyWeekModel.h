//
//  frequencyWeekModel.h
//  Buggy
//
//  Created by goat on 2018/4/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface frequencyWeekModel : NSObject
@property (nonatomic,assign) NSInteger frequency;   //周频率       或者月频率
@property (nonatomic,strong) NSString *traveldate;        //周一的日期

@property (nonatomic,copy) NSString *analysis;  //周频率分析

@end
