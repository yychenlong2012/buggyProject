//
//  MusicArticleViewController.m
//  Buggy
//
//  Created by goat on 2018/6/6.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicArticleViewController.h"
#import <WebKit/WebKit.h>
#import "CLImageView.h"

@interface MusicArticleViewController ()
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic,strong) UIImageView *naviBackImage;   //导航栏返回按钮
@property (nonatomic,strong) UILabel *naviLabel;   //导航栏标题
@end

@implementation MusicArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.webView];
    //创建请求
    
    //webview加载页面
    if (self.articleUrl) {
        NSURL *url = [NSURL URLWithString:self.articleUrl];
        if (url) {
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            [self.webView loadRequest:request];
        }
    }
}

-(void)dealloc{
    NSLog(@"11");
}

#pragma mark - lazy
-(WKWebView *)webView{
    if (_webView == nil) {
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,navigationH,ScreenWidth,ScreenHeight-navigationH-bottomSafeH) configuration:wkWebConfig];
    }
    return _webView;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        [_naviView addSubview:self.naviBackImage];
        [_naviView addSubview:self.naviLabel];
    }
    return _naviView;
}
-(UIImageView *)naviBackImage{
    if (_naviBackImage == nil) {
        _naviBackImage = [[CLImageView alloc] init];
        _naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        _naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        _naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _naviBackImage;
}
-(UILabel *)naviLabel{
    if (_naviLabel == nil) {
        _naviLabel = [[UILabel alloc] init];
        //        naviTitle.textColor = [UIColor colorWithHexString:@"#172058"];
        _naviLabel.textColor = kWhiteColor;
        _naviLabel.text = self.title;
        _naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _naviLabel.textAlignment = NSTextAlignmentCenter;
        _naviLabel.frame = CGRectMake((ScreenWidth-RealWidth(250))/2, 13+statusBarH, RealWidth(250), 18);
    }
    return _naviLabel;
}

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
////隐藏状态栏
////- (BOOL)prefersStatusBarHidden {
////    return YES;
////}
@end
