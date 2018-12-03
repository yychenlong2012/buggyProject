//
//  AYInstructionsViewModel.m
//  Buggy
//
//  Created by goat on 2017/8/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "AYInstructionsViewModel.h"
#import "AYInstructionsModel.h"
#import "WNJsonModel.h"
@implementation AYInstructionsViewModel
+ (void)requestInstructions:(RequestFinish)finish{
    __block NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0]; 
    AVQuery *query = [AVQuery queryWithClassName:@"Instruction"];

     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects > 0) {
            
            for (AVObject *ob in objects) {
                AYInstructionsModel *deviceModel = [WNJsonModel modelWithDict:ob[@"localData"] className:@"AYInstructionsModel"];
                [datas addObject:deviceModel];
            }
            if (finish) {
                finish(datas,error);
            }
        }
    }];
}
@end
