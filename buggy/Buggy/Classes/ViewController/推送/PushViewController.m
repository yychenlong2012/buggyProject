//
//  PushViewController.m
//  Buggy
//
//  Created by 孟德林 on 2016/10/29.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "PushViewController.h"
#import "CacheManager.h"


@interface PushViewController ()

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic,strong) NSArray *tipsArray;

@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"宝宝小贴士";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeWebView)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.view addSubview:self.webView];
    __weak typeof(self) wself = self;
    [[CacheManager manager] getLocalData:kBABYTIPSDATA complete:^(NSObject *object) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            self->_tipsArray = @[dic[@"ChildcarePoints"],dic[@"DevelopmentSigns"],dic[@"ScienceTip"],dic[@"GrownConcern"],dic[@"ParentalInteraction"]];
            [wself.webView loadData:self->_tipsArray[wself.index] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
        }else{
            
        }
    }];
}

- (UIWebView *)webView{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
    }
    return _webView;
}

- (void)closeWebView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
