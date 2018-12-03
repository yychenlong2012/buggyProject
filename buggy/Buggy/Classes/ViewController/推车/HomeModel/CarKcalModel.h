//
//  CarKcalModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"

@interface CarKcalModel : BaseModel

#pragma mark === 推车信息

@property (nonatomic, strong)NSString *todayMilage;   // 今天的里程
@property (nonatomic, strong)NSString *todayVelocity; // 今天的速度
@property (nonatomic, strong)NSString *totalMilage;   // 总里程

#pragma mark --- 父母信息
@property (nonatomic ,strong)NSString *parentsWeight;    //父(母)体重
@property (nonatomic ,strong)NSString *parentsTodayKcal; // 父(母)今日卡路里
@property (nonatomic ,strong)NSString *parentsTotalKcal; // 父母总的卡路里


@end
