//
//  CarKcalModel.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarKcalModel.h"
#import "MainModel.h"
@implementation CarKcalModel

- (NSString *)todayVelocity{
    
    if ( _todayVelocity.length == 0) {
        return @"0.0";
    }
    return _todayVelocity;
}

- (NSString *)totalMilage{

    if (_totalMilage.length == 0) {
        return @"0.0";
    }
    return _totalMilage;
}

- (NSString *)parentsWeight{
    
    if (_parentsWeight.length == 0) {
        if (![MainModel model].isHaveNetWork) {
            return KUserDefualt_Get(@"parentsWeight");
        }
        return @"0";
    }
    return _parentsWeight;
}

- (NSString *)parentsTodayKcal{
    if (_parentsTodayKcal.length == 0) {
        return @"0.0";
    }
    return _parentsTodayKcal;
}

- (NSString *)parentsTotalKcal{
    if (_parentsTotalKcal.length == 0) {
        return @"0.0";
    }
    return _parentsTotalKcal;
}
@end
