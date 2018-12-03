//
//  BabyInfoViewController.h
//  Buggy
//
//  Created by goat on 2018/5/5.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BabyModel;
@class MineNewViewController;
@interface BabyInfoViewController : UIViewController

@property (nonatomic,strong) NSString *babyId;   //babyID
@property (nonatomic,strong) babyInfoModel *babyModel;
@property (nonatomic,strong) UITableView *tableview;

@property (nonatomic,weak) MineNewViewController *lastVC;   //上一个界面
@end
