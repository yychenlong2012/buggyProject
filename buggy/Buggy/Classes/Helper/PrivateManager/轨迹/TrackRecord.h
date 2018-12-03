//
//  TrackRecord.h
//  Buggy
//
//  Created by 孟德林 on 16/9/28.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface TrackRecord : NSObject

/**
 *  开始时间
 */
@property (nonatomic ,strong) NSDate *startTime;
/**
 *  结束时间
 */
@property (nonatomic ,strong) NSDate *endTime;

/**
 *  主标题
 *
 *  @return
 */
- (NSString *)title;

/**
 *  次级标题
 *
 *  @return
 */
- (NSString *)subTitle;

/**
 *  添加Location
 *
 *  @param location
 */
- (void)addLocation:(CLLocation *)location;
/**
 *  坐标点的个数
 *
 *  @return
 */
- (NSInteger)numOfLocations;

/**
 *  清除字典里数据
 */
-(void)clearLocationArray;

/**
 *  开始点的位置
 *
 *  @return
 */
- (CLLocation *)startLocation;

/**
 *  结束点的位置
 *
 *  @return
 */
- (CLLocation *)endLocation;

/**
 *  所有的经纬度点集合 CLLocationCoordinate2D[]
 *
 *  @return
 */
- (CLLocationCoordinate2D *)coordinates;

/**
 *  行走的总共距离
 *
 *  @return
 */
- (CLLocationDistance)totalDistance;

/**
 *  总共持续的时间
 *
 *  @return
 */
- (NSTimeInterval)totalDuration;

@end
