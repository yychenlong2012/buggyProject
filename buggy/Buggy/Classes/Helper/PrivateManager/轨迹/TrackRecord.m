//
//  TrackRecord.m
//  Buggy
//
//  Created by 孟德林 on 16/9/28.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "TrackRecord.h"
#import <AVOSCloud.h>
@interface TrackRecord()

@property (nonatomic ,strong) NSMutableArray *locationsArray;

@property (nonatomic ,assign) double distance;

@property (nonatomic ,assign) CLLocationCoordinate2D *coords;

@end

@implementation TrackRecord

-(instancetype)init{
    self = [super init];
    if (self) {
        _locationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//// NSCoding 协议 解码
//- (instancetype)initWithCoder:(NSCoder *)aDecoder{
//    self = [super init];
//    if (self) {
//        self.locationsArray = [aDecoder decodeObjectForKey:@"locations"];
//    }
//    return self;
//}
//
//// 编码
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.locationsArray forKey:@"location"];
//}


-(CLLocation *)startLocation
{
    return [self.locationsArray firstObject];
}


-(CLLocation *)endLocation
{
    return [self.locationsArray lastObject];
}

-(void)addLocation:(CLLocation *)location
{
    [self.locationsArray addObject:location];
}

-(void)clearLocationArray{
    if (self.locationsArray.count != 0) {
        [self.locationsArray removeAllObjects];
    }
}

-(CLLocationCoordinate2D *)coordinates{
    
    if (self.coords != NULL) {
        free(self.coords);
        self.coords = NULL;
    }
    self.coords = (CLLocationCoordinate2D *)malloc(self.locationsArray.count * sizeof(CLLocationCoordinate2D));
    for (NSInteger i = 0; i < self.locationsArray.count; i ++) {
        CLLocation *location = self.locationsArray[i];
        self.coords[i] = location.coordinate;
    }
    return self.coords;
}


- (NSString *)title
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    AVUser *_user = [AVUser currentUser];
    return _user.objectId;
}


-(NSString *)subTitle{
    return [NSString stringWithFormat:@"坐标点数:%ld, 行驶距离:%.2fm, 消耗时间:%.2fs",
            self.locationsArray.count,[self totalDistance],[self totalDuration]];
}


- (CLLocationDistance)totalDistance{
    CLLocationDistance distance = 0;
    if (self.locationsArray.count > 1) {
        CLLocation *startLocation = [self.locationsArray firstObject];
        for (CLLocation *location in self.locationsArray) {
            distance += [location distanceFromLocation:startLocation];
            startLocation = location;
        }
    }
    return distance;
}


- (NSTimeInterval)totalDuration{
    return [self.endTime timeIntervalSinceDate:self.startTime];
}


- (NSInteger)numOfLocations{
    return self.locationsArray.count;
}
@end
