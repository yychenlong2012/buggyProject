//
//  ScreenMgr.m
//  Buggy
//
//  Created by 孟德林 on 16/9/13.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "ScreenMgr.h"
#import "LoginVC.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"
#import "WelcomeViewController.h"

@interface ScreenMgr()

@property (nonatomic, strong) MainViewController *tabBarController;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) UIViewController *centerVC;

@end

@implementation ScreenMgr

IMP_SINGLETON

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:DIDLOGIN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstLoadApp) name:FirstLoadApp object:nil];
    }
    return self;
}

- (void)clear{
    if (_tabBarController) self.tabBarController = nil;
}

/* 进入主界面 */
- (void)showMainScreen{
    
    //转场动画
    [self.window.layer transitionWithAnimType:TransitionAnimTypeRamdom
                                      subType:TransitionSubtypesFromRamdom
                                        curve:TransitionCurveRamdom
                                     duration:1.0f];
    self.window.rootViewController = self.tabBarController;
}

/* 进入登陆界面 */
- (void)changeToLoginScreen{
    //删除之前可能存在的主页面(上一个用户退出登录)
    self.tabBarController = nil;
    
    LoginVC *loginVC = [[LoginVC alloc] init];
    loginVC.view.backgroundColor = [UIColor whiteColor];
    DYBaseNaviagtionController *nav = [[DYBaseNaviagtionController alloc]
                                       initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
}

/* 绑定界面，暂时废除 */
- (void)changeToBandingScreen{
    
    
}

/* 进入欢迎界面 */
- (void)changeToWelcomeScreen{
    
    WelcomeViewController *vc = [[WelcomeViewController alloc] init];
    self.window.rootViewController = vc;
}

/* 所有界面逻辑的起始点 */
- (void)showRightScreen{
     BOOL isfirstLoadApp = [[NSUserDefaults standardUserDefaults] objectForKey:FirstLoadApp];
//    !isfirstLoadApp? [self changeToWelcomeScreen]:([MainModel model].isLogin?[self showMainScreen]:[self changeToLoginScreen]);
    
    //是否第一次打开app
    if (!isfirstLoadApp) {
        [self changeToWelcomeScreen];
    }else{
//        [self showMainScreen];
//        return;
        NSString *token = KUserDefualt_Get(USER_LOGIN_TOKEN);
        if (token.length > 0) {  //有token
            //验证token有效性
//            [self changeToLoginScreen];
            [NETWorkAPI checkToken];
        }else{                   //无token一定没有登录
            [self changeToLoginScreen];
        }
    }
}

/* 是否已经登陆 */
- (void)didLogin{
    [self showMainScreen];
    
}
/* 第一次登陆 */
- (void)firstLoadApp{
    if (![MainModel model].isLogin) {
        [self changeToLoginScreen];
    }else{
        [self showMainScreen];
    }
}

- (UIWindow *)window{
    return [UIApplication sharedApplication].delegate.window;   //获取代理文件里创建的window
}

- (UIViewController *)centerVC{
    return self.tabBarController.selectedViewController;       //tabBar正在显示的子界面
}

- (void)changePageToWayWithIndex:(NSInteger)index{     //tabBar显示指定的子界面
    [self.tabBarController setSelectedIndex:index];
}

#pragma mark ==== setter and getter
-(MainViewController *)tabBarController{
    if (_tabBarController == nil) {
        _tabBarController = [[MainViewController alloc] init];
    }
    return _tabBarController;
}

@end
