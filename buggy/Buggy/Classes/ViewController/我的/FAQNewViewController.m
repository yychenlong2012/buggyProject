//
//  FAQNewViewController.m
//  Buggy
//
//  Created by goat on 2018/11/2.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "FAQNewViewController.h"
#import <WebKit/WebKit.h>
#import "CLImageView.h"
#import "CLLabel.h"
@interface FAQNewViewController ()<WKUIDelegate>
@property (nonatomic,strong) WKWebView *webview;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation FAQNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"常见问题", nil);
    [self.view addSubview:self.naviView];
    /*   wkwebview设置字体大小    */
    //    //创建网页配置对象
    //    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //    // 创建设置对象
    //    WKPreferences *preference = [[WKPreferences alloc]init];
    //    // 设置字体大小(最小的字体大小)
    //    preference.minimumFontSize = 40;
    //    // 设置偏好设置对象
    //    config.preferences = preference;
    //    // 创建WKWebView
    //    self.webview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64) configuration:config];
    
    //添加mate标签
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) configuration:wkWebConfig];
    [self.view addSubview:self.webview];
    self.webview.UIDelegate = self;
    
    [self requestFunctionInstructionURL];
}

//获取功能介绍html文件的url
-(void)requestFunctionInstructionURL{
    
    [NETWorkAPI instructionsCallback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        if ([msg isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:msg];
            if (url) {
                //请求加载网页
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.webview loadRequest:request];
            }
        }
    }];
//    AVQuery *query = [AVQuery queryWithClassName:@"Instruction"];
//    [query whereKey:@"function" equalTo:@"problem"];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        if (error == nil && object) {
//            AVFile *file = object[@"instruction_File"];
//            if (file != nil && [file isKindOfClass:[AVFile class]]) {
//                //请求加载网页
//                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:file.url]];
//                [self.webview loadRequest:request];
//            }
//        }
//    }];
}

#pragma mark - webViewDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [AYMessage showActiveViewOnView:self.view];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [AYMessage showNoContentTip:NSLocalizedString(@"暂时与母星失去联系", nil) image:NSLocalizedString(@"无网络", nil) onView:webView viewClick:^{
        //  [wself requestData];
    }];
    [AYMessage hideActiveView];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [AYMessage hideNoContentTipView];
    [AYMessage hideActiveView];
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [_naviView addSubview:naviBackImage];
        
        UILabel *naviLabel = [[UILabel alloc] init];
        naviLabel.textColor = kWhiteColor;
        naviLabel.text = NSLocalizedString(@"功能介绍", nil);
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
        
//        CLImageView *webBackImage = [[CLImageView alloc] init];
//        webBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
//        webBackImage.frame = CGRectMake(ScreenWidth-35, 13+statusBarH, 20, 20);
//        webBackImage.userInteractionEnabled = YES;
//        [webBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
//            [wself.webview goBack];
//        }];
//        [_naviView addSubview:webBackImage];
        
        CLLabel *webBackLabel = [[CLLabel alloc] init];
        webBackLabel.textAlignment = NSTextAlignmentRight;
        webBackLabel.frame = CGRectMake(ScreenWidth-115, 13+statusBarH, 100, 20);
        webBackLabel.userInteractionEnabled = YES;
        webBackLabel.text = @"上一页";
        webBackLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        webBackLabel.textColor = kWhiteColor;
        [webBackLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.webview goBack];
        }];
        [_naviView addSubview:webBackLabel];
    }
    return _naviView;
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

@end
