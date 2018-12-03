//
//  MineNewViewController.h
//  Buggy
//
//  Created by goat on 2018/5/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BaseVC.h"
@interface MineNewViewController : BaseVC

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray<babyInfoModel *> *babyArray;    //宝宝数据

@end
