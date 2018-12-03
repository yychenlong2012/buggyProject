//
//  TrackManager.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@class TrackManager;
@protocol TrackAnamationDeleagte <NSObject>


/**
 动画开始

 @param track 本身
 */
- (void)animationStartTrack:(TrackManager *)track;

/**
 动画完成

 @param track 本身
 */
- (void)animationEndTrack:(TrackManager *)track;

@end


@interface TrackManager : NSObject


/**
 地图的实例，弱引用
 */
@property (nonatomic ,assign) MAMapView *mapView;

@property (nonatomic ,assign) id<TrackAnamationDeleagte> deleagte;


/**
 地图的轨迹的自定义的大头针(只可以读，不可以修改)
 */
@property (nonatomic ,strong,readonly) MAPointAnnotation *annotation;

/**
 初始化

 @return
 */
- (instancetype)init;



/**
 设置 经纬度点 自己管理内存

 @param coordinates 经纬度集合
 @param count 经纬度个数
 */
- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates withCount:(NSInteger)count;


/**
 开始动画
 */
- (void)executeAnamation;


/**
 清除动画
 */
- (void)clearAnamation;

@end
