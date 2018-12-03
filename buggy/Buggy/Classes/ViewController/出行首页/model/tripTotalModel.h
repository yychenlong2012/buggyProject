//
//  tripTotalModel.h
//  Buggy
//
//  Created by goat on 2018/3/30.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tripTotalModel : NSObject
@property (nonatomic,assign) NSInteger todayMileage;    //今日出行

@property (nonatomic,assign) NSInteger frequencyWeek;   //本周频率

@property (nonatomic,copy) NSString *recommendedDate; //出行信息  一周七天 0代表无信息 1代表已出行 2代表计划出行

@property (nonatomic,copy) NSString *recommendedContent;  //tips信息
@end
