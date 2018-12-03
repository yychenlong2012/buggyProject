//
//  UserProtocolViewModel.m
//  Buggy
//
//  Created by goat on 2017/8/14.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "UserProtocolViewModel.h"
#import "WNJsonModel.h"
@implementation UserProtocolViewModel
//用户协议
+ (void)requestUserProtocol:(RequestFinish)finish{
    __block NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
    AVQuery *query = [AVQuery queryWithClassName:@"UserProtocol"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects > 0) {
            for (AVObject *ob in objects) {
                UserProtpcolModel *deviceModel = [WNJsonModel modelWithDict:ob[@"localData"] className:@"UserProtpcolModel"];
                [datas addObject:deviceModel];
            }
            if (finish) {
                finish(datas,error);
            }
        }
    }];
}
@end

@implementation UserProtpcolModel


@end
