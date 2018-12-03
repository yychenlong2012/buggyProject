//
//  dateModel.h
//  Buggy
//
//  Created by goat on 2018/3/31.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TravelInfoModel;

@interface dateModel : NSObject
@property (nonatomic,assign) NSInteger mileage;   //当日里程
@property (nonatomic,copy) NSString *date;

@property (nonatomic,copy) NSString *analysis;   //出行分析

@property (nonatomic,strong) NSMutableArray<TravelInfoModel*> *travelInfoArray;  //单日的出行分段记录  日里程模块用到 频率模块不用
@end
