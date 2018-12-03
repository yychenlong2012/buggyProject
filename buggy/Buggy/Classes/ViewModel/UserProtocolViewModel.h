//
//  UserProtocolViewModel.h
//  Buggy
//
//  Created by goat on 2017/8/14.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^RequestFinish)(NSArray *list,NSError *error);
@interface UserProtocolViewModel : NSObject
/**
 使用说明
 */
+ (void)requestUserProtocol:(RequestFinish)finish;
@end

@interface UserProtpcolModel : NSObject
@property (nonatomic,strong) AVFile *userProtocol;/**<用户协议*/
@end
