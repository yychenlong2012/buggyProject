//
//  WelcomeViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/3/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "WelcomeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WelcomeViewController ()<UIScrollViewDelegate>
@property (nonatomic ,strong) UIScrollView *scrollView;
@property (nonatomic ,strong) NSArray *imageArray;
@property (nonatomic ,strong) UIPageControl *pagecontrol;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //底部背景
    UIImageView *bottomImage = [[UIImageView alloc] init];
    bottomImage.image = ImageNamed(@"引导背景");
    bottomImage.frame = CGRectMake(0, ScreenHeight-bottomSafeH-RealWidth(81), ScreenWidth, RealWidth(81));
    [self.view addSubview:bottomImage];
    
    //scrollview
    [self.view addSubview:self.scrollView];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //引导页
    for (NSInteger i =0; i < 4; i ++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = kWhiteColor;
        view.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight-statusBarH-bottomSafeH-RealWidth(81));
        [self.scrollView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = ImageNamed(self.imageArray[i]);
        imageView.frame = CGRectMake(0, 0, RealWidth(310), RealWidth(530));
        imageView.center = view.center;
        imageView.left = (ScreenWidth-RealWidth(310))/2;
        [view addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleToFill;
        if (i == 3) {    //这个按钮覆盖在引导页第四张图片开始体验按钮的上面，
            UIButton *button = [Factory  buttonEmptyWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/5) click:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLoadApp];
                [[NSNotificationCenter defaultCenter] postNotificationName:FirstLoadApp object:nil];    //发送一个通知到screenMgr界面 提示引导页结束
            } onView:nil];
            button.backgroundColor = [UIColor clearColor];
            [view addSubview:button];
            button.bottom = view.height;
        }
    }
    
    //pagecontrol
    self.pagecontrol = [[UIPageControl alloc] init];
    self.pagecontrol.frame = CGRectMake(0, 0, 200, 20);
    self.pagecontrol.centerX = ScreenWidth/2;
    self.pagecontrol.bottom = bottomImage.top - 20;
    self.pagecontrol.numberOfPages = 4;
    self.pagecontrol.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#E04E63"];
    self.pagecontrol.pageIndicatorTintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    
    [self.view addSubview:self.pagecontrol];
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-bottomSafeH-RealWidth(81))];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(4 * ScreenWidth, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (NSArray *)imageArray{
    return @[@"welcome1",@"welcome2",@"welcome3",@"welcome4"];
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX < scrollView.width/2) {
        self.pagecontrol.currentPage = 0;
        return;
    }
    if (offsetX >= scrollView.width/2 && offsetX < scrollView.width*1.5) {
        self.pagecontrol.currentPage = 1;
        return;
    }
    if (offsetX >= scrollView.width*1.5 && offsetX < scrollView.width*2.5) {
        self.pagecontrol.currentPage = 2;
        return;
    }
    if (offsetX >= scrollView.width*2.5) {
        self.pagecontrol.currentPage = 3;
        return;
    }
}
@end
