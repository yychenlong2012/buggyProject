//
//  FeedBackManager.h
//  Buggy
//
//  Created by 孟德林 on 16/10/9.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedBackManager : NSObject

/**
 *  用户反馈一些问题
 *
 *  @param things  反馈的内容
 *  @param success 反馈成功
 *  @param faile   反馈失败
 */
+ (void)feedBackWithSomeThings:(NSString *)things
                       success:(void(^)(BOOL sucess))success
                         faile:(void(^)(NSError *faile))faile;


@end
