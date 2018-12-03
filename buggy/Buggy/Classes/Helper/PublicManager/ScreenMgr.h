//
//  ScreenMgr.h
//  Buggy
//
//  Created by 孟德林 on 16/9/13.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCREENMGR [ScreenMgr sharedInstance]

@interface ScreenMgr : NSObject

DEF_SINGLETON

@property (nonatomic, strong) UIViewController *currentViewController;
/**
 *  进入到主界面
 */
-(void)showMainScreen;
/**
 *  切换到登录页
 */
-(void)changeToLoginScreen;
/**
 *  （因为没有广告，方法没有实现）
 */
- (void)changeToWelcomeScreen;

/**
 *  根据条件判定，是切换到主界面还是切换到登录界面
 */
-(void)showRightScreen;

/**
 *  清理界面
 */
-(void)clear;

/**
 *  跳转到指定界面
 *
 *  @param index 界面对应的index 0.主页 1.行程 2.健康贴士 3.我的界面
 */
-(void)changePageToWayWithIndex:(NSInteger )index;

@end
