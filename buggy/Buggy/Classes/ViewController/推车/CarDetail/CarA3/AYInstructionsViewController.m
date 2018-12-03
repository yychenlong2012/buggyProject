//
//  AYInstructionsViewController.m
//  Buggy
//
//  Created by goat on 2017/8/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//
#import "AYInstructionsViewModel.h"
#import "AYInstructionsModel.h"
#import "AYInstructionsViewController.h"
#import "CLImageView.h"

#import <WebKit/WebKit.h>
@interface AYInstructionsViewController ()<WKUIDelegate>
@property (nonatomic,strong) WKWebView *changjianWebView;/**<常见问题*/
@property (nonatomic,strong) WKWebView *shiYongWebView;/**<使用说明*/
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation AYInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviView];
    [self setUI];
    [self loadData];
}
-(void)dealloc{
    NSLog(@"111");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUI{
    
    self.navigationItem.title = NSLocalizedString(@"使用说明", nil);
    
    //添加mate标签
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    WKWebView *shiYongWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) configuration:wkWebConfig];
    WKWebView *changjianWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) configuration:wkWebConfig];
    
    changjianWebView.UIDelegate = self;
    shiYongWebView.UIDelegate   = self;
    _changjianWebView = changjianWebView;
    _shiYongWebView   =  shiYongWebView;
    NSArray *views = [[NSArray alloc] initWithObjects:changjianWebView,shiYongWebView, nil];
    NSArray *titles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"常见问题", nil),NSLocalizedString(@"使用说明", nil), nil];
   AYViewPager* _viewPager = [[AYViewPager alloc] initWithFrame:CGRectMake(0, navigationH, kWidth, kHeight-navigationH-bottomSafeH)
                                             titles:titles
                                              views:views];
    [_viewPager setTabSelectedTitleColor:[UIColor grayColor]];
    [_viewPager setShowVLine:NO];
    [_viewPager setTabTitleColor:[UIColor lightGrayColor]];
    [_viewPager setTabSelectedArrowBgColor:[UIColor redColor]];
    [self.view addSubview:_viewPager];
}
//加载数据
- (void) loadData{
    [AYInstructionsViewModel requestInstructions:^(NSArray *list, NSError *error) {
        
        for (AYInstructionsModel *model in list) {
            
            if ([model.function isEqualToString:@"C"]) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.instruction_File.url]];
                [self->_changjianWebView loadRequest:request];
            }else{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.instruction_File.url]];
                [self->_shiYongWebView loadRequest:request];
            }
            
        }
    }];
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
        naviLabel.text = NSLocalizedString(@"使用说明", nil);
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
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
