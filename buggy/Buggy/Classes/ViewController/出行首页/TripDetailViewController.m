//
//  TripDetailViewController.m
//  Buggy
//
//  Created by goat on 2018/3/17.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "TripDetailViewController.h"
#import "lineCollectionView.h"
#import "histogramCollectionView.h"
#import "TripDetailOneCell.h"
#import "TripDetailTwoCell.h"
#import "CLImageView.h"
#import "dateModel.h"
#import "DailyMileageDataBase.h"
#import "TravelInfoModel.h"
#import "WNJsonModel.h"
#import "frequencyWeekModel.h"
#import "NetWorkStatus.h"

@interface TripDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic,strong) CLImageView *naviBackImage;
@property (nonatomic,assign) NSInteger flag;
@property (nonatomic,strong) NSMutableArray<dayMileageModel*> *dateArray;    //日里程数据

@property (nonatomic,strong) DailyMileageDataBase *mileageDatabase;              //日里程数据库
@property (nonatomic,strong) NSMutableArray <frequencyWeekModel *> *frequencyWeekArray;   //周频率数组
@property (nonatomic,strong) NSMutableArray <frequencyWeekModel *> *frequencyMonthArray;  //月频率数组
@property (nonatomic,assign) NSInteger currentPage;      //当前页
@property (nonatomic,assign) NSInteger currentPageWeekFre;      //当前页
@property (nonatomic,assign) NSInteger currentPageMonFre;      //当前页
@property (nonatomic,strong) TripDetailOneCell *oneCell;
@end

@implementation TripDetailViewController
//出行统计详情
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPage = 1;
    self.currentPageMonFre = 1;
    self.currentPageWeekFre = 1;
    //再次执行之前的失败上传操作
//    [self uploadLocalOperation];
    
    //转场代理
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self setupUI];
    
    //初始化数据数组
    self.dateArray = [NSMutableArray array];
    self.travelInfoArray = [NSMutableArray array];
    self.frequencyWeekArray = [NSMutableArray array];
    self.frequencyMonthArray = [NSMutableArray array];
    
    //初始化数据库
    self.mileageDatabase = [[DailyMileageDataBase alloc] init];
    
    //优先请求需要展示的数据
    if (self.cellType == TripShowFirstCell) {
        [self requestMileageDataWithPage:self.currentPage scrollToLeft:NO];   //日里程数据
    }else{
        [self requestFrequencyDataWithPage:self.currentPageWeekFre scrollToLeft:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //将柱状图滑到最右边
        [cell.lineView.collectionView setContentOffset:CGPointMake(cell.lineView.collectionView.contentSize.width-cell.lineView.collectionView.frame.size.width, 0) animated:NO];
        [cell.histogramView.collectionView setContentOffset:CGPointMake(cell.histogramView.collectionView.contentSize.width-cell.histogramView.collectionView.frame.size.width, 0) animated:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.oneCell.lineView manualSetToplabel];  //设置toplabel   0.5秒后执行这个代码
            [self.oneCell.lineView setupCenterCell];   //设置中间cell的颜色
            [cell.histogramView manualSetShapeLayerColor];
        });
    });
    
    //如果是点击出行频率进入的这个界面 禁止tableview的滑动
    if (self.cellType == TripShowSecondCell) {
        _tableview.scrollEnabled = NO;
        frequencyWeekModel *model = [self.frequencyWeekArray lastObject];
        if (model) {
            cell.topLabel.attributedText = [self realTextWithStr1:[NSString stringWithFormat:@"%ld",(long)model.frequency] str2:@"次"];
            cell.tipsLabel.text = model.analysis;
        }
    }else{
        dayMileageModel *model = [self.dateArray lastObject];
        if (model) {
            cell.topLabel.attributedText = [self realTextWithStr1:[NSString stringWithFormat:@"%ld",(long)model.mileage] str2:@"米"];
            cell.tipsLabel.text = model.analysis;
        }
    }
}

-(void)setupUI{
    //自定义导航栏
    [self.view addSubview:self.naviTitle];
    [self.view addSubview:self.naviBackImage];
    [self.view addSubview:self.tableview];
}

-(void)dealloc{
    NSLog(@"11");
}
#pragma mark - 数据操作
//右划手势触发第一个表格界面数据
-(void)requestByGestureRecognizerRight{
    if (self.dateArray.count == 0) {  //没有数据表示则请求
//        [self requestMileageDataBefore:[NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]] scrollToLeft:YES];   //日里程数据
        [self requestMileageDataWithPage:self.currentPage scrollToLeft:NO];   //日里程数据
        
    }
}

//左划手势触发第二个表格界面数据
-(void)requestByGestureRecognizerLeft{
    if (self.frequencyWeekArray.count == 0) {
//        [self requestFrequencyDataBefore:[NSDate date] scrollToLeft:YES];  //周频率
        [self requestFrequencyDataWithPage:self.currentPageWeekFre scrollToLeft:NO];
    }
}

//点击了月按钮
-(void)tapMonthBtn{
    if (self.frequencyMonthArray.count == 0) {  //没有数据则请求
        [self requestFrequencyMonthDataWithPage:self.currentPageMonFre scrollToLeft:YES];
    }else{
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
        cell.histogramView.dataArray = self.frequencyMonthArray;
        [cell.histogramView.collectionView reloadData];
    }
}

//点击了周按钮
-(void)tapWeekBtn{
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
    cell.histogramView.dataArray = self.frequencyWeekArray;
    [cell.histogramView.collectionView reloadData];
}

//请求更多数据  yes代表日里程数据  no代表频率数据
-(void)loadMoreDateIsMileage:(BOOL)isMileage{
    if (isMileage) {
        if (self.currentPage > 0) {   //page大于0表示还有数据
            [self requestMileageDataWithPage:self.currentPage+1 scrollToLeft:NO];   //日里程数据
        }
    }else{
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
        if (cell.histogramView.isMonthType == YES) {
            if (self.currentPageMonFre > 0) {
                [self requestFrequencyMonthDataWithPage:self.currentPageMonFre+1 scrollToLeft:NO];
            }
        }else{
            if (self.currentPageWeekFre > 0) {
                [self requestFrequencyDataWithPage:self.currentPageWeekFre+1 scrollToLeft:NO];
            }
        }
    }
}

//周频率数据  travelFrequencyModel
-(void)requestFrequencyDataWithPage:(NSInteger)page scrollToLeft:(BOOL)scrollToLeft{
    [NETWorkAPI requestWeekAndMonthFrequency:WEEK_TYPE page:[NSString stringWithFormat:@"%ld",page] pageNum:@"10" callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if ([modelArray isKindOfClass:[NSArray class]] && modelArray.count > 0) {
            //插入数据
            NSDateFormatter *forma = [[NSDateFormatter alloc] init];
            for (NSInteger i = 0; i<modelArray.count; i++) {
                frequencyWeekModel *model = modelArray[i];
                //日期格式转换
                forma.dateFormat = @"yyyy-MM-dd";
                NSDate *date = [forma dateFromString:model.traveldate];
                forma.dateFormat = @"yyyy.M.d";
                model.traveldate = [forma stringFromDate:date];
                [self.frequencyWeekArray insertObject:model atIndex:0];
            }
            
            //刷新数据
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
            cell.histogramView.dataArray = self.frequencyWeekArray;
            [cell.histogramView.collectionView reloadData];
            
            if (scrollToLeft) {
                dispatch_queue_t asyncQueue = dispatch_get_main_queue();
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5 * NSEC_PER_SEC)),asyncQueue, ^{
                    [cell.histogramView.collectionView setContentOffset:CGPointMake(cell.histogramView.collectionView.contentSize.width-cell.histogramView.collectionView.frame.size.width, 0) animated:YES];
                    [cell.histogramView manualSetToplabel];  //设置toplabel   0.5秒后执行这个代码
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.8 * NSEC_PER_SEC)),asyncQueue, ^{
                    [cell.histogramView manualSetToplabel];  //设置toplabel
                });
            }
        }
        
        if (currentPage >= 0 && currentPage < 10000) {   //当前页大于等于零时刷新当前页  否则不刷新
            self.currentPageWeekFre = currentPage;
        }
    }];
}

//返回当前天所属周的周一日期
- (NSDate*)weekdayStringFromDate:(NSDate*)inputDate {
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"7", @"1", @"2", @"3", @"4", @"5", @"6", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    NSInteger currentDay = [[weekdays objectAtIndex:theComponents.weekday] integerValue];  //当前天是星期几
    NSDate *Monday = [NSDate dateWithTimeInterval:-(currentDay-1)*24*60*60 sinceDate:inputDate];   //该周星期一的日期
    return Monday;
}

//月频率数据
-(void)requestFrequencyMonthDataWithPage:(NSInteger)page scrollToLeft:(BOOL)scrollToLeft{
    
    [NETWorkAPI requestWeekAndMonthFrequency:MONTH_TYPE page:[NSString stringWithFormat:@"%ld",page] pageNum:@"10" callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if ([modelArray isKindOfClass:[NSArray class]] && modelArray.count > 0) {
            //插入数据
            NSDateFormatter *forma = [[NSDateFormatter alloc] init];
            for (NSInteger i = 0; i<modelArray.count; i++) {
                frequencyWeekModel *model = modelArray[i];
                //日期格式转换
                forma.dateFormat = @"yyyy-MM-dd";
                NSDate *date = [forma dateFromString:model.traveldate];
                forma.dateFormat = @"yyyy.M.d";
                model.traveldate = [forma stringFromDate:date];
                [self.frequencyMonthArray insertObject:model atIndex:0];
            }
            
            //刷新数据
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            TripDetailOneCell *cell = [self.tableview cellForRowAtIndexPath:index];
            cell.histogramView.dataArray = self.frequencyMonthArray;
            [cell.histogramView.collectionView reloadData];
            
            if (scrollToLeft) {
                dispatch_queue_t asyncQueue = dispatch_get_main_queue();
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5 * NSEC_PER_SEC)),asyncQueue, ^{
                    [cell.histogramView.collectionView setContentOffset:CGPointMake(cell.histogramView.collectionView.contentSize.width-cell.histogramView.collectionView.frame.size.width, 0) animated:YES];
                    [cell.histogramView manualSetToplabel];  //设置toplabel   0.5秒后执行这个代码
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.8 * NSEC_PER_SEC)),asyncQueue, ^{
                    [cell.histogramView manualSetToplabel];  //设置toplabel
                });
            }
        }
        
        if (currentPage >= 0 && currentPage < 10000) {   //当前页大于等于零时刷新当前页  否则不刷新
            self.currentPageMonFre = currentPage;
        }
    }];
}

/**请求日里程数据
 * beforeDate  获取指定日期之前的数据
 */
-(void)requestMileageDataWithPage:(NSInteger)page scrollToLeft:(BOOL)scrollToLeft{
    
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    forma.dateFormat = @"yyyy-MM-dd";
    NSDateFormatter *forma2 = [[NSDateFormatter alloc] init];
    forma2.dateFormat = @"yyyy.M.d";
    
    [NETWorkAPI requestDayMileageWithPage:[NSString stringWithFormat:@"%ld",page] pageNum:@"50" callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if ([modelArray isKindOfClass:[NSArray class]]) {
            
            //插入数据
            NSMutableArray<dayMileageModel *> *tempArray = [NSMutableArray array];
            for (NSInteger i = 0; i < modelArray.count; i++) {
                dayMileageModel *model = modelArray[i];
                model.date = model.traveldate;
                NSDate *date = [forma dateFromString:model.traveldate];
                model.traveldate = [forma2 stringFromDate:date];
                [self.dateArray insertObject:model atIndex:0];
                [tempArray addObject:model];
            }
            
            //刷新数据
            self.oneCell.lineView.dataArray = self.dateArray;
            for (dayMileageModel *ml in tempArray) {  //记录最长的里程
                if (ml.mileage > self.oneCell.lineView.theLongestMileage) {
                    self.oneCell.lineView.theLongestMileage = ml.mileage;
                    NSLog(@"最大出行距离%ld",(long)ml.mileage);
                }
            }
            [self.oneCell.lineView.collectionView reloadData];
            
            //滚动到最右边
            if (scrollToLeft) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.oneCell.lineView.collectionView setContentOffset:CGPointMake(self.oneCell.lineView.collectionView.contentSize.width-self.oneCell.lineView.collectionView.frame.size.width, 0) animated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.oneCell.lineView manualSetToplabel];  //设置toplabel   0.5秒后执行这个代码
                        [self.oneCell.lineView setupCenterCell];   //设置中间cell的颜色
                    });
                });
            }
        }
        
        if (currentPage >= 0 && currentPage < 10000) {   //当前页大于等于零时刷新当前页  否则不刷新
            self.currentPage = currentPage;
        }
    }];
}

////上传本地保存的失败操作
//-(void)uploadLocalOperation{
//    if ([NetWorkStatus isNetworkEnvironment]){
//        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *fileName = [NSString stringWithFormat:@"%@isMileageCommit.plist",[AVUser currentUser].objectId];
//        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
//        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
//        NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
//        for (NSDictionary *dict in temp) {
//            AVQuery *query = [AVQuery queryWithClassName:@"TravelDataWithDay"];
//            [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//            NSDate *date = [dateFormatter dateFromString:dict[@"date"]];
//            [query whereKey:@"travelDate" greaterThanOrEqualTo:date];
//            [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//                if (object) {  //有数据刷新数据
//                    [object setObject:@([object[@"mileage"] integerValue]+[dict[@"mileage"] integerValue]) forKey:@"mileage"];
//                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                        if (succeeded == YES && error == nil) {  //上传成功 删除本地保存
//                            [self deleteOperationWith:dict];
//                        }
//                    }];
//                }
//                if (error.code == 101) {  //无数据 新建数据
//                    object = [AVObject objectWithClassName:@"TravelDataWithDay"];
//                    [object setObject:[AVUser currentUser] forKey:@"userId"];
//                    [object setObject:@([dict[@"mileage"] integerValue]) forKey:@"mileage"];
//                    [object setObject:date forKey:@"travelDate"];
//                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                        if (succeeded == YES && error == nil) {  //上传成功 删除本地保存
//                            [self deleteOperationWith:dict];
//                        }
//                    }];
//                }
//            }];
//        }
//    }
//}

//删除已成功上传的操作
//-(void)deleteOperationWith:(NSDictionary *)operation{
//    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *fileName = [NSString stringWithFormat:@"%@isMileageCommit.plist",[AVUser currentUser].objectId];
//    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
//    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePath];
//    [array removeObject:operation];
//    [array writeToFile:filePath atomically:YES];
//}

//保存上传失败的数据
//-(void)saveUploadOperationWith:(NSDictionary *)mileageDict{
//    //本地记录 记录操作
//    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *fileName = [NSString stringWithFormat:@"%@isMileageCommit.plist",[AVUser currentUser].objectId];
//    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
//    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
//    NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
//
//    if (temp) {//有字典 则更新
//        BOOL isRecode = NO;  //是否已有记录
//        for (NSDictionary *dict in temp) {
//            NSString *date = dict[@"date"];
//            if ([date isEqualToString:mileageDict[@"date"]]) {
//                isRecode = YES;
//                NSInteger mileage = [dict[@"mileage"] integerValue];
//                NSInteger uploadMileage = [mileageDict[@"mileage"] integerValue];
//
//                [dict setValue:[NSString stringWithFormat:@"%ld",(mileage + uploadMileage)] forKey:@"mileage"];
//                NSLog(@"%@",dict);
//            }
//        }
//        if (!isRecode) {
//            [temp addObject:@{@"mileage":@([mileageDict[@"mileage"] integerValue]), @"date": mileageDict[@"date"]}];
//        }
//        array = temp;
//    }else{
//        temp = [NSMutableArray arrayWithArray:@[@{@"mileage":@([mileageDict[@"mileage"] integerValue]), @"date": mileageDict[@"date"]}]];
//        array = temp;
//    }
//    [array writeToFile:filePath atomically:YES];
//}

//上传里程数据到后台   dateStr的格式 2018-01-01 00:00:00
//-(void)uploadMileage:(NSInteger)mileage date:(NSString *)dateStr{
//    //上传操作
//    AVQuery *query = [AVQuery queryWithClassName:@"TravelDataWithDay"];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    NSDate *date = [dateFormatter dateFromString:dateStr];
//    [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//    [query whereKey:@"travelDate" greaterThanOrEqualTo:date];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        if (object) {  //有数据刷新数据
//            [object setObject:@([object[@"mileage"] integerValue]+mileage) forKey:@"mileage"];
//            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                if (succeeded == NO && error) {  //上传未成功  保存操作
//                    [self saveUploadOperationWith:@{@"mileage":@(mileage),@"date":dateStr}];
//                }
//            }];
//        }
//        if (error.code == 101) {  //无数据 新建数据
//            object = [AVObject objectWithClassName:@"TravelDataWithDay"];
//            [object setObject:[AVUser currentUser] forKey:@"userId"];
//            [object setObject:@(mileage) forKey:@"mileage"];
//            [object setObject:[NSDate date] forKey:@"travelDate"];
//            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                if (succeeded == NO && error) {  //上传未成功  保存操作
//                    [self saveUploadOperationWith:@{@"mileage":@(mileage),@"date":dateStr}];
//                }
//            }];
//        }else{
//            [self saveUploadOperationWith:@{@"mileage":@(mileage),@"date":dateStr}];
//        }
//    }];
//}

/**
 *  是否为同一天
 */
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2{
    NSCalendar* calendar = [NSCalendar currentCalendar];
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

//请求某一天的出行记录
-(void)requestDailyMesseageWithDate:(NSString *)date andLineHeight:(NSInteger)lineHeight index:(NSInteger)index{
    [self.travelInfoArray removeAllObjects];
    if (lineHeight != 0) {  //里程为零表示无记录
        
        [NETWorkAPI requestDayMileageSubsWithPage:@"1" pageNum:@"100" date:date callback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
            if ([modelArray isKindOfClass:[NSArray class]] && modelArray.count > 0) {
                [self.travelInfoArray removeAllObjects];
                [self.travelInfoArray addObjectsFromArray:modelArray];
                
                //保存数据
                if (index < self.oneCell.lineView.dataArray.count && index >= 0) {
                    dayMileageModel *model = self.oneCell.lineView.dataArray[index];
                    if (model.travelInfoArray == nil || [model.travelInfoArray isKindOfClass:[NSNull class]]) {
                        model.travelInfoArray = [NSMutableArray array];
                    }
                    [model.travelInfoArray removeAllObjects];
                    [model.travelInfoArray addObjectsFromArray:self.travelInfoArray];
                }
            }
            //刷新数据
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
            [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableview setContentOffset:CGPointZero animated:YES];
        }];
    }else{
        //刷新数据
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.tableview setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        if (self.travelInfoArray.count > 0) {
            return self.travelInfoArray.count;
        }else{
            return 1;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        return self.tableview.height;
    }else{
        if (self.travelInfoArray.count > 0) {
            return 75;
        }else{
            return RealWidth(150)+54;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 70;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 0, 0);
        return view;
    }
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = kWhiteColor;
    header.frame = CGRectMake(0, 0, ScreenWidth, 70);
    //红线
    UIView *redLine = [[UIView alloc] init];
    redLine.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
    redLine.frame = CGRectMake(20, 15, 3, 20);
    [header addSubview:redLine];
    //标题
    UILabel *label =[[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
    label.text = NSLocalizedString(@"出行详情", nil);
    label.frame = CGRectMake(redLine.right+15, 15, 200, 20);
    [header addSubview:label];
    return header;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        return self.oneCell;
    }else{
        if (self.travelInfoArray.count > 0) {
            TripDetailTwoCell *TwoCell = [tableView dequeueReusableCellWithIdentifier:@"twoCell"];
            if (TwoCell == nil) {
                TwoCell = [[TripDetailTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"twoCell"];
            }
            TwoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            TwoCell.travelModel = self.travelInfoArray[indexPath.row];
            return TwoCell;
        }else{  //空白占位
            UITableViewCell *empty = [tableView dequeueReusableCellWithIdentifier:@"empty"];
            if (empty == nil) {
                empty = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"empty"];
                empty.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageview = [[UIImageView alloc] init];
                imageview.image = ImageNamed(@"day_mileage_placeholder");
                imageview.frame = CGRectMake(0, 28, RealWidth(215), RealWidth(150));
                imageview.centerX = ScreenWidth/2;
                [empty.contentView addSubview:imageview];
            }
            return empty;
        }
    }
}
#pragma mark - UIViewControllerTransitioningDelegate 转场代理 非手动
//跳转时调用该方法
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    _flag = 0;
    return self;   //返回一个遵守该协议的对象
}
//dismiss时调用该方法
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    _flag = 1;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning 动画代理
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;    //动画时间
}
//动画实现
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    if (_flag == 0) {    //根据不同的过程选择不同的动画效果
        [self present:transitionContext];    //跳转动画
    }else{
        [self dismiss:transitionContext];    //退出动画
    }
}

-(void)present:(id <UIViewControllerContextTransitioning>)transitionContext{
    //通过viewControllerForKey取出转场前后的两个控制器，这里toVC就是vc1、fromVC就是vc2
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    toVC.view.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, ScreenHeight);
    [UIView animateWithDuration:0.25 animations:^{
        toVC.view.transform = CGAffineTransformMakeTranslation(-ScreenWidth, 0);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        //转场失败后的处理
        if ([transitionContext transitionWasCancelled]) {
            //失败后，我们要把vc1显示出来
            fromVC.view.hidden = NO;
            //然后移除截图视图，因为下次触发present会重新截图
            [toVC.view removeFromSuperview];
        }else{
            fromVC.view.hidden = YES;
        }
    }];
}

-(void)dismiss:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.hidden = NO;
    UIView *tempView = [transitionContext containerView].subviews[0];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //因为present的时候都是使用的transform，这里的动画只需要将transform恢复就可以了
        tempView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if (![transitionContext transitionWasCancelled]) {
            
        }else{
            toVC.view.hidden = YES;
        }
    }];
}

#pragma mark - Lazy
-(UILabel *)naviTitle{
    if (_naviTitle == nil) {
        _naviTitle = [[UILabel alloc] init];
        _naviTitle.textColor = kBlackColor;
        _naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _naviTitle.text = NSLocalizedString(@"日里程", nil);
        _naviTitle.opaque = NO;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
    }
    return _naviTitle;
}
-(CLImageView *)naviBackImage{
    if (_naviBackImage == nil) {
        _naviBackImage = [[CLImageView alloc] init];
        _naviBackImage.image = [UIImage imageNamed:@"navi_back_icon"];
        _naviBackImage.frame = CGRectMake(15, 13+statusBarH, 18, 18);
        _naviBackImage.userInteractionEnabled = YES;
        _naviBackImage.opaque = NO;
        __weak typeof(self) wself = self;
        [_naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _naviBackImage;
}
-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview.frame = CGRectMake(0, statusBarH+44, ScreenWidth, ScreenHeight-bottomSafeH-statusBarH-44);
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _tableview.estimatedRowHeight = 0;
            _tableview.estimatedSectionFooterHeight = 0;
            _tableview.estimatedSectionHeaderHeight = 0;
            _tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }

        
    }
    return _tableview;
}

-(TripDetailOneCell *)oneCell{
    if (_oneCell == nil) {
        _oneCell = [[TripDetailOneCell alloc] init];
        _oneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.cellType == TripShowFirstCell) {
            _oneCell.viewType = TripShowFirstView;
        }else{
            _oneCell.viewType = TripShowSecondView;
        }
    }
    return _oneCell;
}

//生成属性字符串
-(NSMutableAttributedString *)realTextWithStr1:(NSString *)str1 str2:(NSString *)str2{
    NSMutableAttributedString * firstPart = [[NSMutableAttributedString alloc] initWithString:str1==nil?@"0":str1];
    UIFont *font1 = [UIFont fontWithName:@"DINAlternate-Bold" size:35];
    NSDictionary * firstAttributes = @{ NSFontAttributeName:font1==nil?[UIFont systemFontOfSize:35]:font1,NSForegroundColorAttributeName:kBlackColor};
    [firstPart setAttributes:firstAttributes range:NSMakeRange(0,firstPart.length)];
    
    NSMutableAttributedString * secondPart = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",str2]];
    UIFont *font2 = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
    NSDictionary * secondAttributes = @{NSFontAttributeName:font2==nil?[UIFont systemFontOfSize:20]:font2,NSForegroundColorAttributeName:kBlackColor};
    [secondPart setAttributes:secondAttributes range:NSMakeRange(0,secondPart.length)];
    [firstPart appendAttributedString:secondPart];
    return firstPart;
}
@end
