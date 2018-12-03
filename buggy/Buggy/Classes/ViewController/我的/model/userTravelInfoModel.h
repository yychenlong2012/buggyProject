//
//  userTravelInfoModel.h
//  Buggy
//
//  Created by goat on 2018/11/15.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface userTravelInfoModel : NSObject

@property (nonatomic,copy) NSString *todaycalories;
@property (nonatomic,copy) NSString *todaymileage;
@property (nonatomic,copy) NSString *totalcalories;
@property (nonatomic,copy) NSString *totalmileage;
@property (nonatomic,copy) NSString *weight;

@property (nonatomic,copy) NSString *todayvelocity;
@end

NS_ASSUME_NONNULL_END
