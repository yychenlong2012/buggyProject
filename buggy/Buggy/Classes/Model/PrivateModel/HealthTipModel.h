//
//  HealthTipModel.h
//  Buggy
//
//  Created by ningwu on 16/6/6.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseModel.h"
//#import <AVOSCloud.h>

@interface HealthTipModel : BaseModel
/**
 *  根据宝宝的日期获取对应的提示内容
 *
 *  @param date     宝宝的日期
 *  @param complete 获取成功
 */
- (void)getTips:(NSString *)date block:(void(^)(NSDictionary *dic,NSError *error))complete;

/**
 *  获取宝宝所有的日期的提示内容
 *
 *  @param success 获取成功(webView界面的提示信息，单个的提示信息，返回的错误信息)
 */
- (void)getTipsSuccess:(void(^)(NSDictionary *dicWebData,NSArray *TipsPreviewArray,NSError *error))success;

/**
 *  将日期格式设置为（9-9-9）格式
 *
 *  @param date 日期格式
 *
 *  @return 返回固定格式的字符串
 */
- (NSString *)setUnderlineAgeTypeWithDate:(NSString *)date;
@end
