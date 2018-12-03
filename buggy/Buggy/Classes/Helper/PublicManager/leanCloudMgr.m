//
//  leanCloudMgr.m
//  Buggy
//
//  Created by 孟德林 on 16/8/18.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "leanCloudMgr.h"

@implementation leanCloudMgr

+ (void)initEvent{
    AVObject *analyticsObject = [AVObject objectWithClassName:@"AnalyticsObject"];
    [analyticsObject setObject:@"Register" forKey:YOUZI_Register];
    [analyticsObject setObject:@"BandingDevice" forKey:YOUZI_BandingDevice];
}

+ (void)event:(NSString *)event_id{
    
    [AVAnalytics event:event_id];
}

+ (void)stopAnalyticsEvent{
    
    [AVAnalytics setAnalyticsEnabled:NO];
}

+ (void)beginLogPageView:(NSString *)event_id{
    
    [AVAnalytics beginLogPageView:event_id];
}

+ (void)endLogPageView:(NSString *)event_id{
    
    [AVAnalytics endLogPageView:event_id];
}

@end
