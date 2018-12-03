//
//  travelFrequencyModel.h
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface travelFrequencyModel : NSObject

@property (nonatomic,copy) NSString *frequency;    //频率
@property (nonatomic,copy) NSString *traveldate;   //第一天的日期
@property (nonatomic,copy) NSString *analysis;     //分析

@end

NS_ASSUME_NONNULL_END
