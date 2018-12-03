//
//  CarA4PushDataModel.h
//  Buggy
//
//  Created by goat on 2018/5/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarA4PushDataModel : NSObject
@property(nonatomic,strong) NSDate *startTime;   //开始推行时间
@property(nonatomic,strong) NSDate *endTime;     //结束推行时间
@property(nonatomic,assign) NSInteger mileage;   //推行距离
@property(nonatomic,assign) NSInteger useTime;   //实际推行耗时

-(instancetype)initWithStartTime:(NSDate *)start endTime:(NSDate *)end mileage:(NSInteger)mileage useTime:(NSInteger)useTime;
@end
