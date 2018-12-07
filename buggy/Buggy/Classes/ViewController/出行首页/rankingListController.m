//
//  rankingListController.m
//  Buggy
//
//  Created by goat on 2018/5/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "rankingListController.h"
#import "rankTableViewCell.h"
#import "CLImageView.h"

@interface rankingListController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray<punchListModel *> *dataArray;
@property (nonatomic,assign) NSInteger currentPage;        //数据当前页码

@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@property (nonatomic,strong) UIImageView *naviBackImage;   //导航栏返回按钮
@end

@implementation rankingListController
//排行榜
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.naviBackImage];
    [self.view addSubview:self.tableview];
    [self.tableview.mj_header beginRefreshing];
    
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)dealloc{
    NSLog(@"111");
}

//
-(void)requestData:(NSInteger)page{
    [NETWorkAPI requestPunchListWithPage:integerToStr(page) pageNum:@"20" callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        [self.tableview.mj_footer endRefreshing];
        [self.tableview.mj_header endRefreshing];
        if ([modelArray isKindOfClass:[NSArray class]] && modelArray.count > 0) {
            [self.dataArray addObjectsFromArray:modelArray];
            [self.tableview reloadData];
        }
        
        if (currentPage >= 0 && currentPage < 10000) {
            self.currentPage = currentPage;
        }
    }];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{return 70;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{return self.dataArray.count;}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    rankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[rankTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    punchListModel *model = self.dataArray[indexPath.row];

    cell.userName.text = model.nickname;
    NSURL *url = [NSURL URLWithString:model.headerurl];
    if (url != nil) {
       [cell.userIcon sd_setImageWithURL:url placeholderImage:ImageNamed(@"home_default")];
    }
    //时间
//    cell.time.text = [self getTheIntervalWithDate1:object[@"lastPunchTime"] date2:[NSDate date]];
    cell.time.text = model.time_value;
    return cell;
}

//获得两时间间隔
-(NSString *)getTheIntervalWithDate1:(NSDate *)date1 date2:(NSDate *)date2{
    if (date1 == nil || date2 == nil) {
        return @"";
    }
    NSCalendar *chineseClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    //从一个日期里面把这些内容取出来
    NSDateComponents *cps = [chineseClendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    //时间间隔
    NSInteger Hour = [cps hour];
    NSInteger Min = [cps minute];
    
    NSString *str;
    if (Hour == 0 && Min == 0) {
        str = @"刚刚打卡";
    }else if (Hour == 0){
        str = [NSString stringWithFormat:@"%ld分钟前打卡",(long)Min];
    }else{
        str = [NSString stringWithFormat:@"%ld小时前打卡",(long)Hour];
    }
    return str;
}


#pragma mark - lazy
-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-bottomSafeH-navigationH) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        __weak typeof(self) wself = self;
        _tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{   //刷新
            wself.currentPage = 1;
            [wself.dataArray removeAllObjects];
            [wself requestData:wself.currentPage];
        }];
        _tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{   //加载
            if (wself.currentPage > 0) {
                wself.currentPage++;
                [wself requestData:wself.currentPage];
            }else{
                [wself.tableview.mj_footer endRefreshing];
            }
        }];
    }
    return _tableview;
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        
        UILabel *naviTitle = [[UILabel alloc] init];
        //        naviTitle.textColor = [UIColor colorWithHexString:@"#172058"];
        naviTitle.textColor = kWhiteColor;
        naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        form.dateFormat = @"yyyy M月";
        naviTitle.text = [form stringFromDate:[NSDate date]];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviTitle];
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
