//
//  NetWorkStatus.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/27.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NETWORK_TYPE_NONE = 0,
    NETWORK_TYPE_2G = 1,
    NETWORK_TYPE_3G = 2,
    NETWORK_TYPE_4G = 3,
    NETWORK_TYPE_WIFI = 5,
} NETWORK_TYPE;


@interface NetWorkStatus : NSObject

/**
 通过获取手机的信号栏上面的网络类型的标志

 @return 状态码
 */
+ (int)dataNetworkTypeFromStatusBar;


/**
 是否是wifi环境

 @return
 */
+ (BOOL)isWifiNetworkEnvironment;


/**
 是否存在有网络的情况

 @return
 */
+ (BOOL)isNetworkEnvironment;


//判断手机型号
+(NSString *)getDeviceName;
@end
