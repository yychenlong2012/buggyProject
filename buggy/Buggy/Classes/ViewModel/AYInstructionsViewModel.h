//
//  AYInstructionsViewModel.h
//  Buggy
//
//  Created by goat on 2017/8/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^RequestFinish)(NSArray *list,NSError *error);
@interface AYInstructionsViewModel : NSObject
/**
   使用说明
 */
+ (void)requestInstructions:(RequestFinish)finish;
@end
