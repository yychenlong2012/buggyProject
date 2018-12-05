//
//  DYBaseNaviagtionController.m
//  DYwardrobe
//
//  Created by wuning on 15/11/30.
//  Copyright © 2015年 DY. All rights reserved.
//

#import "DYBaseNaviagtionController.h"
#import "UIImage+Additions.h"
#import "BaseVC.h"

@interface DYBaseNaviagtionController ()
@end

@implementation DYBaseNaviagtionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNaviBackground];

}

- (void)initNaviBackground
{
    
//    UIColor *color = COLOR_HEXSTRING(@"#F47686");
    UIColor *color = kClearColor;
    
    /* UINavigationBar */
    //想要设置shadowImage必须要先设置navigationBar的backgroundImage
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:color] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage imageWithColor:color];
    [self.navigationBar setBarTintColor:color];

    //返回按钮的颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    UIColor *shadowColor = [UIColor whiteColor];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    shadow.shadowOffset = CGSizeZero;
    NSDictionary *dic = @{NSForegroundColorAttributeName:shadowColor,
                          NSFontAttributeName:[UIFont systemFontOfSize:19.0f],// [UIFont fontWithName:@"Arial-BoldMT" size:18.0f],
                          NSShadowAttributeName:shadow,};
    self.navigationBar.titleTextAttributes = dic;
}

// 拦截铺push
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        
        if ([viewController isKindOfClass:NSClassFromString(@"BaseVC")]) {
            NSString *title = @"返回";
            if (self.childViewControllers.count == 1) {
                title = self.childViewControllers.firstObject.title;
            }
//            title = nil;
            BaseVC *base = (BaseVC *)viewController;
            __weak typeof(self) wself = self;
            base.navigationItem.leftBarButtonItem = [Factory costomBackBarWithTitle:title click:^{
                 [wself popViewControllerAnimated:YES];
            } isback:YES];
        }
    }
    [super pushViewController:viewController animated:animated];
}

@end
