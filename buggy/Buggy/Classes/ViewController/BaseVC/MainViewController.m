//
//  MainViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/1/19.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MainViewController.h"
#import "BaseVC.h"
#import "LoginVC.h"
#import "DYBaseNaviagtionController.h"
@interface MainViewController ()

@property (nonatomic,readonly) UIWindow *window;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UITabBar appearance] setTranslucent:NO];   //iOS12 二级界面pop回主界面时，底部tabbar按钮闪动，这里设置为NO即可
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOut) name:DIDLOGINOUT object:nil];
    [self setChildrenViewContrllers];
}

-(void)didLoginOut{
    LoginVC *login = [[LoginVC alloc] init];
    [self presentViewController:[[DYBaseNaviagtionController alloc] initWithRootViewController:login]
                    animated:YES
                  completion:nil];
}

#pragma mark ==== 设置 tabbar

- (void)setChildrenViewContrllers{
    self.tabBar.tintColor = [Theme mainTabbarColor];
    //添加子控制器
    self.viewControllers  = [self getChildrenViewControllers];
}

#pragma mark ==== 初始化UI视图

- (NSArray *)getChildrenViewControllers{
    NSMutableArray *childrenViewControllers = [NSMutableArray arrayWithCapacity:4];
    NSArray *dicArray = @[
//                        @{@"className":@"HomeViewController",@"title":NSLocalizedString(@"首页", nil),@"imageName":@"home"},
//                        @{@"className":@"MusicViewController",@"title":NSLocalizedString(@"音乐", nil),@"imageName":@"music"},
                        @{@"className":@"TripAndMusicViewController",@"title":NSLocalizedString(@"首页", nil),@"imageName":@"home"},
                        @{@"className":@"MusicMainViewController",@"title":NSLocalizedString(@"音乐", nil),@"imageName":@"music"},
//                        @{@"className":@"HealthTipsViewController",@"title":NSLocalizedString(@"健康", nil),@"imageName":@"healthtips"},
                        @{@"className":@"MineNewViewController",@"title":NSLocalizedString(@"我的", nil),@"imageName":@"mine"},
                        ];
    for (NSDictionary *dic in dicArray) {
        [childrenViewControllers addObject:[self controller:dic]];
    }
    return childrenViewControllers;
}

- (DYBaseNaviagtionController *)controller:(NSDictionary *)dic{
 
    if (dic) {
        Class class = NSClassFromString(dic[@"className"]);
        BaseVC *vc = [[class alloc] init];    //多态，父类指针指向子类对象
//        vc.title = dic[@"title"];
        vc.tabBarItem.title = dic[@"title"];
        NSString *imagename = [NSString stringWithFormat:@"tabbar_%@",dic[@"imageName"]];
        NSString *selectImageName = [NSString stringWithFormat:@"tabbar_%@_fill",dic[@"imageName"]];
        vc.tabBarItem.image = ImageNamed(imagename);
        vc.tabBarItem.selectedImage  = [ImageNamed(selectImageName) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:FONT_DEFAULT_Light(11)}
                                     forState:UIControlStateNormal];
        DYBaseNaviagtionController *nav = [[DYBaseNaviagtionController alloc] initWithRootViewController:vc];
        return nav;
    }
    return [[DYBaseNaviagtionController alloc] initWithRootViewController:[UIViewController new]];
}

@end
