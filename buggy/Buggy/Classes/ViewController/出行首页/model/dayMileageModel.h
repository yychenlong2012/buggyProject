//
//  dayMileageModel.h
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TravelInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface dayMileageModel : NSObject

@property (nonatomic,assign) NSInteger mileage;
@property (nonatomic,copy) NSString *traveldate;

@property (nonatomic,copy) NSString *analysis;

@property (nonatomic,copy) NSString *date;   //裁剪过后的date

@property (nonatomic,strong) NSMutableArray<TravelInfoModel*> *travelInfoArray;  //单日的出行分段记录  日里程模块用到 频率模块不用

@end

NS_ASSUME_NONNULL_END
