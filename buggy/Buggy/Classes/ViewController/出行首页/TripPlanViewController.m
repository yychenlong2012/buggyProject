//
//  TripPlanViewController.m
//  Buggy
//
//  Created by goat on 2018/3/15.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "TripPlanViewController.h"
#import "CLImageView.h"
#import <FSCalendar.h>
#import "MYLabel.h"

@interface TripPlanViewController ()<UITableViewDelegate,UITableViewDataSource,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) FSCalendar *calendar;
@property (nonatomic,strong) NSDate *todayMonth;      //存放当前月
@property (nonatomic,strong) CLImageView *naviBackImage;
@property (nonatomic,strong) UILabel *naviTitle;
@property (nonatomic,strong) CLImageView *backToday;
@property (nonatomic,strong) UIView *participateView;
@property (nonatomic,strong) UIImageView *successView;  //出行达成
@property (nonatomic,strong) UIView *detailView;        //下面label的背景view
@property (nonatomic,strong) MYLabel *detailLabel;

@property (nonatomic,strong) NSString *travelAnalysis;   //出行分析
@property (nonatomic,assign) CGFloat travelAnalysisLabelHeight;   //出行分析label高度
@property (nonatomic,strong) NSMutableDictionary *travelDataDict;    //出行数据字典
@property (nonatomic,strong) NSMutableDictionary *recommendDataDict; //推荐数据字典
@property (nonatomic,strong) NSMutableDictionary *hasBeenDownloadData;  //用于标记已下载的月数据 防止重复下载
@end
//出行打卡详情
@implementation TripPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.travelDataDict = [NSMutableDictionary dictionary];
    self.recommendDataDict = [NSMutableDictionary dictionary];
    self.hasBeenDownloadData = [NSMutableDictionary dictionary];
    self.travelAnalysis = @"";
    self.travelAnalysisLabelHeight = 0;
    [self setupUI];
    
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    forma.dateFormat = @"yyyy";
    NSString *year = [forma stringFromDate:[NSDate date]];
    forma.dateFormat = @"M";
    NSString *month = [forma stringFromDate:[NSDate date]];
    [self requestTravelDataWithYear:year month:month];
//    [self requestRecommendData];    //请求未来打卡信息
    [self requestAnalyzeDataWithDate:[NSDate date]];
}

-(void)dealloc{
    NSLog(@"dealloc");
}

-(void)setupUI{
    //导航栏
    [self.view addSubview:self.naviTitle];
    [self.view addSubview:self.naviBackImage];
    [self.view addSubview:self.backToday];
    [self.view addSubview:self.tableview];
}

//请求以前的打卡历史
-(void)requestTravelDataWithYear:(NSString *)year month:(NSString *)month{
    [NETWorkAPI requestUserHistoryPunchWithYear:year month:month callBcak:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (error == nil) {    //请求成功
            [self.hasBeenDownloadData setObject:@"1" forKey:[NSString stringWithFormat:@"%@年 %@月",year,month]];    //标记该月为已请求
            if (modelArray != nil && modelArray.count > 0) {
                for (NSString *date in modelArray) {
                    NSString *dateStr = [date componentsSeparatedByString:@" "].firstObject;
                    [self.travelDataDict setObject:@"1" forKey:[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                }
                [self.calendar reloadData];
            }
        }
        
        //刷新日历界面UI
//        if (self.isFirstLoad) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.calendar selectDate:[NSDate date] scrollToDate:YES];
//            });
//            self.isFirstLoad = NO;
//        }
    }];
}

//请求未来推荐数据
-(void)requestRecommendData{
//    AVQuery *query = [AVQuery queryWithClassName:@"UserTravelInfo"];
//    [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        if (error == nil && object) {
//            NSString *str = object[@"recommendedDate"];
//            [self.recommendDataDict removeAllObjects];
//            NSDateFormatter *form = [[NSDateFormatter alloc] init];
//            form.dateFormat = @"yyyyMMdd";
//            NSInteger today = [self getWeekDayFordate];
//            for (NSInteger i = today-1; i<str.length; i++) {
//                NSString *recommend = [str substringWithRange:NSMakeRange(i, 1)];
//                if ([recommend isEqualToString:@"2"]) {
//                    [self.recommendDataDict setObject:@"1" forKey:[form stringFromDate:[NSDate dateWithTimeInterval:(i+1-today)*24*60*60 sinceDate:[NSDate date]]]];
//                }
//            }
//            [self.calendar reloadData];
//        }
//    }];
}

//分析数据
-(void)requestAnalyzeDataWithDate:(NSDate *)date{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyy-MM-dd";
    [NETWorkAPI requsetTravelWeekAnalyzeWithDate:[form stringFromDate:date] callback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        if ([msg isKindOfClass:[NSString class]] && ![msg isEqualToString:@""]) {
            self.travelAnalysis = msg;
        }else{
            self.travelAnalysis = @"  \n推孩子出去转转才有分析内容哦\n  ";
        }
        //计算label高度
        self.travelAnalysisLabelHeight = [self getTextHeightWithText:self.travelAnalysis font:self.detailLabel.font width:self.detailLabel.width lineSpacing:0];
        //刷新数据
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
        [self.tableview reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    }];
}

//计算文字高度
-(CGFloat)getTextHeightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width lineSpacing:(CGFloat)lineSpacing{
    if (text != nil && [text isKindOfClass:[NSString class]]) {
        //创建属性字符串
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = lineSpacing;   //行距
        [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
        [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
        
        //计算行高方法一
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
        label.font = font;
        label.numberOfLines = 0;
        label.attributedText = attributeString;
        CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)];
        //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
        if ((size.height - font.lineHeight) <= (style.lineSpacing + 2)) {   //这个2是一个误差值
            BOOL isContainChinese = NO;   //是否包含汉字
            for(int i=0; i< [text length];i++){
                int a = [text characterAtIndex:i];
                if( a > 0x4e00 && a < 0x9fff){
                    isContainChinese = YES;
                }
            }
            if (isContainChinese) {  //如果包含中文    在一行文字的情况下只有中文会有多余行高
                return size.height-style.lineSpacing;
            }
        }
        return size.height;
    }else{
        return 0;
    }
}

-(NSInteger)getWeekDayFordate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *now = [NSDate date];
    // 在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    comps = [calendar components:unitFlags fromDate:now];
    return [comps weekday] - 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 0;  //50
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        return RealWidth(145);  //RealWidth(160)
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 70+self.travelAnalysisLabelHeight + 30;   //145    30是多出来的高度
    }
    return 100;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view =[[UIView alloc] init];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return RealWidth(310);
    }else if (section == 2){
        return 0;
    }
    return 20;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *header = [[UIView alloc] init];
        header.layer.masksToBounds = YES;
        header.backgroundColor = kClearColor;
        header.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(300));
        [header addSubview:self.calendar];
      
        //遮住黑色边框
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = kWhiteColor.CGColor;
        layer.fillColor = kClearColor.CGColor;
        layer.lineWidth = 3;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:_calendar.frame];
        layer.path = path.CGPath;
        [header.layer addSublayer:layer];
        
        return header;
    }
    
    //其他组的header
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = kWhiteColor;
    header.frame = CGRectMake(0, 0, ScreenWidth, 20);
    //红线
    UIView *redLine = [[UIView alloc] init];
    redLine.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
    redLine.frame = CGRectMake(20, 0, 3, 20);
    [header addSubview:redLine];
    //标题
    UILabel *label =[[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
    if (section == 1) {
        label.text = NSLocalizedString(@"出行分析", nil);
    }
    if (section == 2) {
//        label.text = NSLocalizedString(@"出行奖励", nil);
    }
    label.frame = CGRectMake(redLine.right+10, 0, 200, 20);
    [header addSubview:label];
    [self.view addSubview:header];
    
    return header;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0 && indexPath.row == 0) {
//        [cell.contentView addSubview:self.participateView];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        [cell.contentView addSubview:self.successView];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        [cell.contentView addSubview:self.detailView];
        if ([self.travelAnalysis containsString:@"推孩子出去转转才有分析内容哦"]) {
            self.detailLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
            self.detailLabel.textAlignment = NSTextAlignmentCenter;
        }else{
            self.detailLabel.textColor =kBlackColor;
            self.detailLabel.textAlignment = NSTextAlignmentLeft;
        }
        self.detailLabel.text = self.travelAnalysis;
        [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.bottom.equalTo(@(-45));
            make.left.equalTo(@20);
            make.right.equalTo(@(-20));
        }];
    }
    return cell;
}

#pragma mark - FSCalendarDelegate
-(void)calender:(FSCalendar *)calender setupCell:(FSCalendarCell *)cell date:(NSDate *)date{
    //设置钩钩图片
    cell.rightImageView.hidden = YES;
    cell.bgView.hidden = YES;
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [form stringFromDate:date];
    if (self.travelDataDict.count > 0) {
        if ([self.travelDataDict[dateStr] isEqualToString:@"1"]) {
            cell.bgView.hidden = NO;
            cell.rightImageView.hidden = NO;
            cell.rightImageView.image = ImageNamed(@"rightImage1");
        }
    }
}
-(void)calender:(FSCalendar *)calender didselectedCell:(FSCalendarCell *)cell date:(NSDate *)date{
    //设置今日颜色
    if ([date isEqualToDate:[NSDate date]]) {  //如果是今天
        self.calendar.appearance.todayColor = [UIColor colorWithHexString:@"#E04E63"];
        self.calendar.appearance.titleTodayColor = kWhiteColor;
    }else{
        self.calendar.appearance.todayColor = kWhiteColor;
        self.calendar.appearance.titleTodayColor = [UIColor colorWithHexString:@"#E04E63"];
    }
}
-(UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date{
    //未来推荐出行指示图标
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [form stringFromDate:date];
    if (self.recommendDataDict.count > 0){
        if ([self.recommendDataDict[dateStr] isEqualToString:@"1"]) {
            return ImageNamed(@"指示图标");
        }
    }
    return nil;
}
//切换月
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    //修改导航标题
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年 M月";
    NSDate *currentDate = calendar.currentPage;
    self.naviTitle.text = [dateFormatter stringFromDate:currentDate];
    //如果已经请求过了则不再继续请求
    if ([[self.hasBeenDownloadData objectForKey:[dateFormatter stringFromDate:currentDate]] isEqualToString:@"1"]) {
        return;
    }
    
    dateFormatter.dateFormat = @"yyyyMM";
    NSInteger today = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
    NSInteger target = [[dateFormatter stringFromDate:currentDate] integerValue];
    if (target <= today) {
        dateFormatter.dateFormat = @"yyyy";
        NSString *year = [dateFormatter stringFromDate:currentDate];
        dateFormatter.dateFormat = @"M";
        NSString *month = [dateFormatter stringFromDate:currentDate];
        [self requestTravelDataWithYear:year month:month];    //请求该月数据
    }
    
    //请求该月出行数据
//    dateFormatter.dateFormat = @"M";
//    NSInteger currentMon = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
//    NSInteger targetMon = [[dateFormatter stringFromDate:currentDate] integerValue];
//    if (targetMon <= currentMon) {   //如果是未来时间 则不请求数据
//        //请求数据
//        [self requestTravelDataAfterDate:currentDate beforeDate:[NSDate dateWithTimeInterval:31*24*60*60 sinceDate:currentDate]];
//    }
}

// 对有事件的显示一个点,默认是显示三个点
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
    //从数组中查找是否有事件
    //    if ([self.datesWithEvent containsObject:[dateFormatter stringFromDate:date]]) {
    //        return 1;
    //    }
    return 0;
}

//选中某个日期后的回调
-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyyMMdd";
    NSInteger today = [[form stringFromDate:[NSDate date]] integerValue];
    NSInteger selectDay = [[form stringFromDate:date] integerValue];
    if (today == selectDay) {   //选中了今天
        self.successView.image = ImageNamed(@"正在进行");    //今天不管有没有打卡都显示为正在进行
    }else if (today < selectDay){   //选中了未来
        self.successView.image = ImageNamed(@"待完成");
    }else{   //选中了之前
        if ([self.travelDataDict[[form stringFromDate:date]] isEqualToString:@"1"]) {
            self.successView.image = ImageNamed(@"出行达成");
        }else{
            self.successView.image = ImageNamed(@"未打卡");
        }
    }
    
    //请求该周的出行分析
//    [self requestAnalyzeData:[self weekdayStringFromDate:date]];
    [self requestAnalyzeDataWithDate:date];
//    NSLog(@"%@",[self weekdayStringFromDate:date]);
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

#pragma mark - lazy
//背景view
-(UIView *)participateView{
    if (_participateView == nil) {
        _participateView = [[UIView alloc] init];
        _participateView.backgroundColor = kClearColor;
        _participateView.frame = CGRectMake(0, 0, ScreenWidth, 50);

        //头标
        for (NSInteger i = 0; i<3; i++) {
            UIImageView *imagev = [[UIImageView alloc] init];
            imagev.frame = CGRectMake(_participateView.width-48 - i*11, 9, 23, 23);
            imagev.image = [UIImage imageNamed:@"logo"];
            [_participateView addSubview:imagev];

            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imagev.bounds];
            layer.path = path.CGPath;
            imagev.layer.mask = layer;
        }

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        label.textColor = kBlackColor;
        label.text = NSLocalizedString(@"人打卡", nil);
        label.frame = CGRectMake(_participateView.width-76-40, 18, 40, 13);
        [_participateView addSubview:label];

        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        numLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
        numLabel.text = @"2368";
        numLabel.frame = CGRectMake(label.left-3-40, 18, 40, 13);
        [_participateView addSubview:numLabel];

        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kLightGrayColor;
        line.alpha = 0.5;
        line.frame = CGRectMake(35, numLabel.bottom+15, ScreenWidth-70, 2);
        [_participateView addSubview:line];
    }
    return _participateView;
}

-(UIView *)detailView{
    if (_detailView == nil) {
        _detailView = [[UIView alloc] init];
        _detailView.backgroundColor = kWhiteColor;
        _detailView.layer.cornerRadius = 10;
        _detailView.layer.shadowRadius = 7;
        _detailView.layer.shadowOpacity = 0.1;
        _detailView.layer.shadowOffset = CGSizeMake(0, 7);
        _detailView.frame = CGRectMake(20, 15, ScreenWidth-40, self.travelAnalysisLabelHeight+40);
        
        [_detailView addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20);
            make.bottom.equalTo(@(-20));
            make.left.equalTo(@20);
            make.right.equalTo(@(-20));
        }];
    }
    return _detailView;
}

-(MYLabel *)detailLabel{
    if (_detailLabel == nil) {
        _detailLabel = [[MYLabel alloc] init];
        _detailLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _detailLabel.numberOfLines = 0;
        [_detailLabel setVerticalAlignment:VerticalAlignmentTop];
        _detailLabel.frame = CGRectMake(20, 20, ScreenWidth-80, self.travelAnalysisLabelHeight);
    }
    return _detailLabel;
}

-(UIImageView *)successView{
    if (_successView == nil) {
        _successView = [[UIImageView alloc] init];
//        _successView.frame = CGRectMake((ScreenWidth-RealWidth(311))/2, RealWidth(25), RealWidth(311), RealWidth(115));
        _successView.frame = CGRectMake((ScreenWidth-RealWidth(311))/2, RealWidth(10), RealWidth(311), RealWidth(115));
        _successView.image = ImageNamed(@"正在进行");
    }
    return _successView;
}

-(UILabel *)naviTitle{
    if (_naviTitle == nil) {
        _naviTitle = [[UILabel alloc] init];
        _naviTitle.textColor = kBlackColor;
        _naviTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        form.dateFormat = @"yyyy年 M月";
        _naviTitle.text = [form stringFromDate:[NSDate date]];
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.frame = CGRectMake((ScreenWidth-100)/2, 13+statusBarH, 100, 18);
    }
    return _naviTitle;
}
-(CLImageView *)naviBackImage{
    if (_naviBackImage == nil) {
        _naviBackImage = [[CLImageView alloc] init];
        _naviBackImage.image = [UIImage imageNamed:@"navi_back_icon"];
        _naviBackImage.frame = CGRectMake(15, 13+statusBarH, 18, 18);
        _naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _naviBackImage;
}
-(CLImageView *)backToday{
    if (_backToday == nil) {
        _backToday = [[CLImageView alloc] init];
        _backToday.image = [UIImage imageNamed:@"返回今日"];
        _backToday.frame = CGRectMake(ScreenWidth-58, 9+statusBarH, 28, 28);
        _backToday.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_backToday addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.calendar selectDate:[NSDate date] scrollToDate:YES];
            wself.successView.image = ImageNamed(@"正在进行");
//            [wself requestTripData:[NSDate date]];
            [wself requestAnalyzeDataWithDate:[NSDate date]];
        }];
    }
    return _backToday;
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight-navigationH-bottomSafeH) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = kWhiteColor;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.estimatedRowHeight = 0;
        _tableview.estimatedSectionFooterHeight = 0;
        _tableview.estimatedSectionHeaderHeight = 0;
    }
    return _tableview;
}
- (FSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(15, 20, ScreenWidth-30, RealWidth(300))];   //高度-20
        _calendar.dataSource = self;
        _calendar.delegate = self;
        //设置周一为第一天
        _calendar.firstWeekday = 2;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
        _calendar.locale = locale;
        //设置翻页方式为水平
        _calendar.scrollDirection = FSCalendarScrollDirectionHorizontal;
        //设置是否用户多选
        _calendar.allowsMultipleSelection = NO;
        _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
        //这个属性控制"上个月"和"下个月"标签在静止时刻的透明度          _calendar.appearance.headerMinimumDissolvedAlpha = 0;
        _calendar.backgroundColor = [UIColor whiteColor];
        //设置周字体颜色
        _calendar.appearance.weekdayTextColor = [UIColor blackColor];
        //设置头字体颜色
        _calendar.appearance.headerTitleColor = [UIColor blackColor];
        //设置主标题格式
        _calendar.appearance.headerDateFormat = @"yyyy MM月";
        //月份模式时，只显示当前月份
        _calendar.placeholderType = FSCalendarPlaceholderTypeNone;
        //有事件的小圆点的颜色
        _calendar.appearance.eventDefaultColor = [UIColor colorWithHexString:@"#E04E63"];
        //这个属性控制"上个月"和"下个月"标签在静止时刻的透明度  主标题两边的标题
        _calendar.appearance.headerMinimumDissolvedAlpha = 0;
        //隐藏header
        _calendar.headerHeight = 0;
        //设置显示的时间范围   一周或一个月
        _calendar.scope = FSCalendarScopeMonth;
//        _calendar.appearance.title
        //保存当前月
        self.todayMonth = self.calendar.currentPage;
        _calendar.backgroundColor = kClearColor;
        
        //设置当天的字体颜色
        _calendar.appearance.todayColor = [UIColor colorWithHexString:@"#E04E63"];
        _calendar.appearance.titleTodayColor = kWhiteColor;
        _calendar.appearance.selectionColor = [UIColor colorWithHexString:@"#E04E63"];
        _calendar.appearance.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(17)];
    }
    return _calendar;
}


@end
