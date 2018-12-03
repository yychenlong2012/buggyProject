//
//  TripDetailViewController.h
//  Buggy
//
//  Created by goat on 2018/3/17.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BaseVC.h"
@class TravelInfoModel;
typedef NS_ENUM(NSUInteger, showCellType) {
    TripShowFirstCell   = 0,    //显示第一个界面  里程
    TripShowSecondCell  = 1     //显示第二个界面  周频率
};
@interface TripDetailViewController : BaseVC
@property (nonatomic,strong) UILabel *naviTitle;
@property (nonatomic,assign) showCellType cellType;
@property (nonatomic,strong) UITableView *tableview;       //最外层tableview
@property (nonatomic,strong) NSMutableArray<TravelInfoModel*> *travelInfoArray;  //单日的出行分段记录

//请求更多数据  0代表日里程数据  1代表频率数据
-(void)loadMoreDateIsMileage:(BOOL)isMileage;
//请求某一天的出行详情
-(void)requestDailyMesseageWithDate:(NSString *)date andLineHeight:(NSInteger)lineHeight index:(NSInteger)index;

-(void)requestByGestureRecognizerRight;

-(void)requestByGestureRecognizerLeft;

-(void)tapMonthBtn;

-(void)tapWeekBtn;
@end
