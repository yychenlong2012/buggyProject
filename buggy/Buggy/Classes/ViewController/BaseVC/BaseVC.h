//
//  BaseVC.h
//  Buggy
//
//  Created by ningwu on 16/3/8.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud.h>
#import "MainModel.h"

@interface BaseVC : UIViewController
//@property (nonatomic ,copy)NSString *deviceModel;
//#pragma mark ==== 自定义的导航栏
//@property (nonatomic,strong) UINavigationBar *navBar;
//@property (nonatomic,strong) UINavigationItem *navItem;

#pragma mark ------ 加载动画，如果自定义只需要在内部集成就可以了---------
- (void)initLoading;

- (void)stopLoading;

- (void)initLoadingToView:(UIView *)preView;

- (void)stopLoadingToView:(UIView *)preView;

@end
