//
//  HomeViewModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/1/20.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

typedef void(^RequestFinish)(NSArray *list,NSError *error);

@interface HomeViewModel : NSObject

+ (void)requestDeviceList:(RequestFinish)finish;    //请求设备列表

@end
