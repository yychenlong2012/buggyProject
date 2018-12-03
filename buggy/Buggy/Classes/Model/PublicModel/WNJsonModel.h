//
//  WNJsonModel.h
//  Buggy
//
//  Created by wuning on 16/5/26.
//  Copyright © 2016年 ningwu. All rights reserved.
//

/*
 
 Model 和 NSDictionary的相互转换 （在此 要model的属性 和 NSDictionary的key保持一致， 也可做自定约定规则 可以让 model的属性匹配到key上。默认保持一致）
 
 */

#import <Foundation/Foundation.h>

@interface WNJsonModel : NSObject
/*!
 * @brief 把对象（Model）转换成字典
 * @param model 模型对象
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithModel:(id)model;

/*!
 * @brief 获取Model的所有属性名称
 * @param model 模型对象
 * @return 返回模型中的所有属性值
 */
+ (NSArray *)propertiesInModel:(id)model;

/*!
 * @brief 把字典转换成模型，模型类名为className
 * @param dict 字典对象
 * @param className 类名
 * @return 返回数据模型对象
 */
+ (id)modelWithDict:(NSDictionary *)dict className:(NSString *)className;

@end
