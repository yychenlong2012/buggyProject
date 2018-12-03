//
//  KVCHelper.h
//  CarCare
//
//  Created by ileo on 14-8-30.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVCHelper : NSObject

/**
 *  监测subject的keyPath属性的变化 改变了就调用change方法
 */
-(id)initWithSubject:(id)subject forKeyPath:(NSString *)keyPath change:(void(^)(void))change;

@end
