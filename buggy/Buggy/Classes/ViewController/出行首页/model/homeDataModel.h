//
//  homeDataModel.h
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "punchHeaderImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface homeDataModel : NSObject

@property (nonatomic,copy) NSString *recommendedContent;   //首页tips数据
@property (nonatomic,assign) NSInteger punchCount;         //打卡人数
@property (nonatomic,strong) NSArray *headerUrl;           //打卡人头像数组
@property (nonatomic,copy) NSString *recommendedDate;      //本周打卡信息
@property (nonatomic,copy) NSString *todayMileage;         //日里程
@property (nonatomic,assign) NSInteger frequencyWeek;      //周频率

@end

NS_ASSUME_NONNULL_END
