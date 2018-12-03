//
//  CarA4PushDataModel.m
//  Buggy
//
//  Created by goat on 2018/5/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "CarA4PushDataModel.h"

@implementation CarA4PushDataModel

-(instancetype)initWithStartTime:(NSDate *)start endTime:(NSDate *)end mileage:(NSInteger)mileage useTime:(NSInteger)useTime{
    if (self = [super init]) {
        
        self.startTime = start;
        self.endTime = end;
        self.mileage = mileage;
        self.useTime = useTime;
    }
    return self;
}
@end
