//
//  TravelInfoModel.h
//  Buggy
//
//  Created by goat on 2018/4/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelInfoModel : NSObject
@property (nonatomic,copy) NSString *starttime;
@property (nonatomic,copy) NSString *endtime;
@property (nonatomic,assign) NSInteger mileage;
@property (nonatomic,assign) NSInteger calories;
@end
