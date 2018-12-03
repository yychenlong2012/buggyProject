//
//  UserProtocol.m
//  Buggy
//
//  Created by ningwu on 16/6/2.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "UserProtocol.h"
#import "UserProtocolViewModel.h"
#import "CLImageView.h"
@interface UserProtocol ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewBottom;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation UserProtocol

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    self.title = NSLocalizedString(@"用户协议", nil);
    self.view.backgroundColor = kWhiteColor;
    [AYMessage showActiveViewOnView:self.view];
    self.webViewTop.constant = navigationH;
    self.webViewBottom.constant = bottomSafeH;
    KUserDefualt_Set(@(0), @"statusCode");
    self.webView.delegate = self;
    [self loadData];
    
//    NSURL *url = [NSURL URLWithString:@"http://192.168.10.106/Tp/Uploads/2018-11-21/220265424b1f6b6c97d2.html"];
//    if (url) {
//        //请求加载网页
//        //                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
////        NSString *str = KUserDefualt_Get(@"statusCode1");
////        if ([str isEqualToString:@"200"]) {
//            NSString *str = KUserDefualt_Get(@"Last-Modified");
////            [request setValue:str forHTTPHeaderField:@"If-Modified-Since"];   //Wed, 21 Nov 2018 03:51:48 GMT
//        [request setValue:@"Wed, 21 Nov 2018 03:51:48 GMT" forHTTPHeaderField:@"If-Modified-Since"];
////        }
//
//        [self.webView loadRequest:request];
//    }
}
-(void)dealloc{
    NSLog(@"111");
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//
//    NSLog(@"%@",request.allHTTPHeaderFields);
//
//    return YES;
//}

//-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    //获取status code
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)[[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request].response;
//    NSInteger statusCode = response.statusCode;
//    NSLog(@"%ld",statusCode);
//    NSString *str = [response.allHeaderFields objectForKey:@"Last-Modified"];
//    KUserDefualt_Set(str, @"Last-Modified");
//    KUserDefualt_Set(@"200", @"statusCode1");
//    NSLog(@"%@",response.allHeaderFields);
//}

- (void)loadData{
    [AYMessage hideNoContentTipView];
//    [UserProtocolViewModel requestUserProtocol:^(NSArray *list, NSError *error) {
//         [AYMessage hideActiveView];
//        if (list.count >1) {
//
//            UserProtpcolModel *object = list[1];
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:object.userProtocol.url]]];
//        }else{
//            [AYMessage showNoContentTip:NSLocalizedString(@"暂时与母星失去联系", nil) image:@"无网络" onView:self.webView viewClick:^{
//                //  [wself requestData];
//            }];
//        }
//    }];
    
    [NETWorkAPI userProtocolCallback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        [AYMessage hideActiveView];
        if ([msg isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:msg];
            if (url) {
                //请求加载网页
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [self.webView loadRequest:request];
            }
        }else{
            [AYMessage showNoContentTip:NSLocalizedString(@"暂时与母星失去联系", nil) image:@"无网络" onView:self.webView viewClick:^{
                //  [wself requestData];
            }];
        }
    }];
   
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
        naviLabel.text = NSLocalizedString(@"用户协议", nil);
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
