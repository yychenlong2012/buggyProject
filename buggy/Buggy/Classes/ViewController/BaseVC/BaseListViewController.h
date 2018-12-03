//
//  BaseListViewController.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/1.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "BaseVC.h"


//需要继承自BaseViewController
@interface BaseListViewController :BaseVC <UITableViewDelegate,UITableViewDataSource>

/**
 是否存在数据
 */
@property (nonatomic) BOOL existData;

/**
 是否正在上拉
 */
@property (nonatomic) BOOL isPullup;

/**
 加载第几页的数据
 */
@property (nonatomic,assign) NSInteger page;
 
/**
  tableView实例
 */
@property (nonatomic ,strong) UITableView *tableView;

/**
 重写加载数据
 */
- (void)requestDataOfPage:(NSInteger)page;

- (void)refrenshRequestData;
/**
 重写TableView,但是必须实现父类方法
 */
- (void)setupTableView;

/**
 从写无数据View,但是必须实现父类方法
 */
- (void)setupNodataView;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
