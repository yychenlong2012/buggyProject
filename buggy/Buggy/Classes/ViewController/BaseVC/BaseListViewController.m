//
//  BaseListViewController.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/1.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import <MJRefresh.h>
#import "BaseListViewController.h"
#import "DataStatusView.h"
@interface BaseListViewController ()

@property (nonatomic ,strong) DataStatusView *dataStatusView;

@end

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPullup = false;
    self.page = 0;
    self.existData = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self requestDataOfPage:self.page];
    [self refrenshRequestData];
}

- (void)setupUI{
    [self setupTableView];
}

- (void)setExistData:(BOOL)existData{
    _existData = existData;
    if (_existData) {
        if (self.view.subviews) {
            [_dataStatusView removeFromSuperview];
        }
    }else{
        if (_dataStatusView == nil) {
            [self setupNodataView];
        }
    }
}

- (void)setupTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController?64:0, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    // 设置刷新控件
    
    __weak typeof(self) wself = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself refrenshRequestData ];
    }];
    
}
- (void)setupNodataView{
    _dataStatusView = [[DataStatusView alloc] initWithFrame:self.view.bounds];
    __weak typeof(self) wself = self;
    _dataStatusView.reload = ^(){
        [wself requestDataOfPage:wself.page];
    };
    [self.view addSubview:_dataStatusView];
}

#pragma mrak === 需要重写以下方法
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[UITableViewCell alloc] init];
}

/// 判断是否划到最后一行
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (row < 0|| section<0) {
        return;
    }
    NSInteger sectionRow = [tableView numberOfRowsInSection:section];
    if ((sectionRow -1) == row && !_isPullup) {
        _isPullup = YES;
        self.page ++;
        if (self.page > 10) {
            return;
        }
        [self requestDataOfPage:self.page];
    }
}

@end
