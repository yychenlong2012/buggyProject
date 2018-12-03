//
//  FAQViewController.m
//  Buggy
//
//  Created by goat on 2017/11/14.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "FAQViewController.h"
#import "FAQTableViewCell.h"
#import "AYInstructionsViewController.h"
#import "CLImageView.h"

@interface FAQViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view
@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.naviView];
    self.title = NSLocalizedString(@"常见问题",nil);
    [self.view addSubview:self.tableview];
}

-(void)dealloc{
    NSLog(@"111");
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStylePlain];
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.dataSource = self;
        _tableview.delegate = self;
    }
    return _tableview;
}

-(NSArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithArray:@[  @{    @"title":NSLocalizedString(@"绑定设备方法",nil),
                                                           @"detail":NSLocalizedString(@"打开“三爸育儿”APP，点击首页【添加设备】或【+】跳转搜索界面，绑定名称为“3POMELOS_A3_BLE”的设备",nil),
                                                           @"isSelect":@"0",
                                                           @"height":@"44"},
                                                        
                                                        @{ @"title":NSLocalizedString(@"蓝牙搜索不到",nil),
                                                           @"detail":NSLocalizedString(@"每辆推车同时只能连接一部手机，且连接后其他手机无法搜索到此推车蓝牙，所以请检查是否该推车与其他手机连接或者将推车电源重启，然后重新搜索蓝牙",nil),
                                                           @"isSelect":@"0",
                                                           @"height":@"44" },
                                                        
                                                        @{ @"title":NSLocalizedString(@"绑定设备失败",nil),
                                                           @"detail":NSLocalizedString(@"绑定推车时需要与系统后台服务器进行网络连接，因此请您保持网络顺畅，用4G信号可能更好哦",nil),
                                                           @"isSelect":@"0",
                                                           @"height":@"44" },
                                                        
                                                        @{ @"title":NSLocalizedString(@"同步数据失败",nil),
                                                           @"detail":NSLocalizedString(@"请依次排查：电源是否开启，蓝牙是否进入睡眠状态（触碰感应区唤醒），蓝牙是否开启时间过长（重新开启）",nil),
                                                           @"isSelect":@"0",
                                                           @"height":@"44" }
                                                        ]];
  
    }
    return _dataArray;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }
    
    if (section == 1) {
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        NSDictionary *dict = self.dataArray[indexPath.row];
        NSString *height = dict[@"height"];
        NSString *isSelect = dict[@"isSelect"];
        
        if ([isSelect isEqualToString:@"0"]) {
            return 44;
        }else{
            return height.floatValue + 54;
        }
    }
    
    if (indexPath.section == 1) {
        return RealHeight(100);
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, ScreenWidth, 50);
    v.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentLeft;
    label.frame = CGRectMake(15, 9.5, ScreenWidth, 25);
    [v addSubview:label];

    if (section == 0) {
        label.text = NSLocalizedString(@"蓝牙问题",nil);
    }else{
        label.text = NSLocalizedString(@"其他问题",nil);
    }
    
    return v;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FAQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bluetooth"];
        
        if (cell == nil) {
            cell = [[FAQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bluetooth"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *dict = self.dataArray[indexPath.row];
        cell.title.text = dict[@"title"];
        cell.detail.text = dict[@"detail"];
        NSString *height = dict[@"height"];
        cell.detail.height = height.floatValue;
        if ([dict[@"isSelect"] isEqualToString:@"0"]) {
            cell.detail.hidden = YES;
        }else{
            cell.detail.hidden = NO;
        }

        return cell;
    }else{
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bluetooth"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bluetooth"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        CGFloat margin = (ScreenWidth - RealWidth(200))/3;
        UIImageView *left = [[UIImageView alloc] init];
        left.image = [UIImage imageNamed:@"Pomelos_A3"];
        left.frame = CGRectMake(margin, 0, RealWidth(100), RealWidth(100));
        [cell.contentView addSubview:left];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftClick)];
        left.userInteractionEnabled = YES;
        [left addGestureRecognizer:tap];
        
        UIImageView *right = [[UIImageView alloc] init];
        right.image = [UIImage imageNamed:@"Pomelos_G"];
        right.frame = CGRectMake(ScreenWidth/2 + margin/2, 0, RealWidth(100), RealWidth(100));
        [cell.contentView addSubview:right];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.dataArray[indexPath.row]];
        FAQTableViewCell *cell = (FAQTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.25 animations:^{
            cell.arrow.transform = CGAffineTransformRotate(cell.arrow.transform, M_PI);
        }];
        
        if ([dict[@"isSelect"] isEqualToString:@"0"]) {
            [dict setValue:@"1" forKey:@"isSelect"];
        }else{
            [dict setValue:@"0" forKey:@"isSelect"];
        }
        
        //计算cell高度
        NSString *height = dict[@"height"];
        NSString *text = dict[@"detail"];
        if (height.floatValue > 44) {
            //计算过了
        }else{
            CGFloat height = [self getHeightWithText:text];
            [dict setValue:[NSString stringWithFormat:@"%f",height] forKey:@"height"];
        }
        
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:dict];
        [self.tableview reloadData];
//        [self.tableview layoutIfNeeded];
    }
    
    if (indexPath.section == 1) {
        
    }
}

-(void)leftClick{
    AYInstructionsViewController *VC = [AYInstructionsViewController new];
    [self.navigationController pushViewController:VC animated:YES];
}

-(CGFloat)getHeightWithText:(NSString *)text{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];    //描述字体的大小
    label.textAlignment = NSTextAlignmentLeft;
//    label.frame = CGRectMake(0, 0, ScreenWidth-45, 1000);
    label.numberOfLines = 0;
    label.text = text;
    
    CGSize size = [label sizeThatFits:CGSizeMake(ScreenWidth-45, 1000)];
    return size.height;
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
        naviLabel.text = NSLocalizedString(@"常见问题", nil);
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
