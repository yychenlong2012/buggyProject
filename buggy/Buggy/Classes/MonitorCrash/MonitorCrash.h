//
//  MonitorCrash.h
//  MonitorCrash
//  该框架核心是runtime中的方法交换和NSException
//  参考链接：http://www.jianshu.com/p/b25b05ef170d
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#ifdef DEBUG
#define MonitorCrashLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define MonitorCrashLog(...)
#endif

#define MonitorCrashNotification @"MonitorCrashNotification"
//user can ignore below define
#define AvoidCrashDefaultReturnNil  @"This framework default is to return nil to avoid crash."
#define AvoidCrashDefaultIgnore     @"This framework default is to ignore this operation to avoid crash."
//category
#import "NSObject+MonitorCrash.h"

#import "NSArray+MonitorCrash.h"
#import "NSMutableArray+MonitorCrash.h"

#import "NSDictionary+MonitorCrash.h"
#import "NSMutableDictionary+MonitorCrash.h"

#import "NSString+MonitorCrash.h"
#import "NSMutableString+MonitorCrash.h"

#import "NSAttributedString+MonitorCrash.h"
#import "NSMutableAttributedString+MonitorCrash.h"

@interface MonitorCrash : NSObject

/**
 开始监听通知
 */
+ (void)monitorCrash;
    
/**
 交换类方法

 @param currentClass 当前要交换的类
 @param oldMethod 老方法
 @param newMethod 新方法
 */
+ (void)exchangeClassMethod:(Class)currentClass oldMethod:(SEL)oldMethod newMethod:(SEL)newMethod;
    
/**
 交换实例方法

 @param currentClass 当前要交换的类
 @param oldMethod 老方法
 @param newMethod 新方法
 */
+ (void)exchangeInstanceMethod:(Class)currentClass oldMethod:(SEL)oldMethod newMethod:(SEL)newMethod;
  
/**
 展示Crash崩溃信息

 @param exception 异常
 @param shouldDo 用户应该做什么
 */
+ (void)showErrorWithException:(NSException *)exception shouldDo:(NSString *)shouldDo;
@end
