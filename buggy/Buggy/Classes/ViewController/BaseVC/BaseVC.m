//
//  BaseVC.m
//  Buggy
//
//  Created by ningwu on 16/3/8.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseVC.h"

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kClearColor] forBarMetrics:UIBarMetricsDefault];  //[Theme mainNavColor]
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:kClearColor];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark ==== 设置自定义导航栏

//- (void)setupNav{
//    [self.view addSubview:self.navBar];
//    _navBar.items = @[self.navItem];
//}

//- (void)setTitle:(NSString *)title{
//    self.navItem.title = title;
//    [super setTitle:title];
//}

//
//-(UINavigationBar *)navBar{
//    
//    if (_navBar == nil) {
//        _navBar =  [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
//        _navBar.backgroundColor = [UIColor purpleColor];
//        _navBar.barTintColor = [UIColor yellowColor];
//        _navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor]};
//        _navBar.tintColor = [UIColor orangeColor];
//    }
//    return _navBar;
//}
//
//- (UINavigationItem *)navItem{
//    if (_navItem == nil) {
//        _navItem = [[UINavigationItem alloc] init];
//    }
//    return _navItem;
//}
#pragma mark ====  加载动画
- (void)initLoading
{
    [MBProgressHUD showLoadingNormal];
}

- (void)stopLoading
{
    [MBProgressHUD dismissLoading];
}

- (void)initLoadingToView:(UIView *)preView
{
    [MBProgressHUD showLoadingNormaltoView:preView];
}

- (void)stopLoadingToView:(UIView *)preView
{
    [MBProgressHUD dismissLoadingView:preView];
}
@end
