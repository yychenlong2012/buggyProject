//
//  tripAndMusicOneCellView.m
//  Buggy
//
//  Created by goat on 2018/5/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "tripAndMusicOneCellView.h"

@interface tripAndMusicOneCellView()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
@property (nonatomic,strong) NSString *weather;      //天气，用于判断是不是相同的天气
@end
@implementation tripAndMusicOneCellView{
    UILabel *airlabel;
    UILabel *dakaLabel;
    UIView *calenderBGView;
    CAShapeLayer *lineLayer;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        //渐变图层
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#4B8FF0"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#5CAAF1"].CGColor];
        self.gradientLayer.locations = @[@0,@1];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(0, 1);
        [self.layer addSublayer:self.gradientLayer];
        
        //天气动画
        self.animationView = [[UIView alloc] init];
        self.animationView.backgroundColor = kClearColor;
        [self addSubview:self.animationView];
        
        //温度
        self.temperature = [[UILabel alloc] init];
        self.temperature.font = [UIFont fontWithName:@"PingFangSC-Thin" size:RealWidth(50)];
        self.temperature.textColor = kWhiteColor;
        self.temperature.textAlignment = NSTextAlignmentRight;
        self.temperature.text = @"℃";
        [self addSubview:self.temperature];
        //空气质量
        airlabel = [[UILabel alloc] init];
        airlabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(16)];
        airlabel.textColor = kWhiteColor;
        airlabel.textAlignment = NSTextAlignmentRight;
        airlabel.text = NSLocalizedString(@"空气质量", nil);
        [self addSubview:airlabel];
        //空气质量等级
        self.air = [[UILabel alloc] init];
        self.air.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(30)];
        self.air.textColor = kWhiteColor;
        self.air.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.air];
        //tips
        self.tipsLabel = [[UILabel alloc] init];
        self.tipsLabel.textAlignment = NSTextAlignmentLeft;
        self.tipsLabel.textColor = kWhiteColor;
        self.tipsLabel.numberOfLines = 0;
        self.tipsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:RealWidth(16)];
        self.tipsLabel.hidden = YES;
        [self addSubview:self.tipsLabel];
        
        //出行管理界面
        UIView *tripManageView = [[UIView alloc] init];
        tripManageView.layer.cornerRadius = 10;
        tripManageView.layer.shadowOpacity = 0.12;
        tripManageView.layer.shadowRadius = 8;
        tripManageView.layer.shadowOffset = CGSizeMake(0, 3);
        tripManageView.opaque = NO;
        tripManageView.backgroundColor = kWhiteColor;
        [self addSubview:tripManageView];
        self.tripManage = tripManageView;
        
        //日期
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [tripManageView addSubview:self.dateLabel];
        
        //头标
        self.imageviewArray = [NSMutableArray array];
        for (NSInteger i = 0; i<3; i++) {
            UIImageView *imagev = [[UIImageView alloc] init];
            imagev.frame = CGRectMake(tripManageView.width-48 - i*11, 9, 23, 23);
            imagev.image = [UIImage imageNamed:@"home_default"];
            [tripManageView addSubview:imagev];
            [self.imageviewArray addObject:imagev];
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imagev.bounds];
            layer.path = path.CGPath;
            imagev.layer.mask = layer;
            
            CAShapeLayer *border = [CAShapeLayer layer];
            border.strokeColor = [UIColor colorWithHexString:@"#CCCCCC"].CGColor;
            border.fillColor = kClearColor.CGColor;
            border.lineWidth = 1;
            UIBezierPath *borderPath = [UIBezierPath bezierPathWithOvalInRect:imagev.bounds];
            border.path = borderPath.CGPath;
            [imagev.layer addSublayer:border];
        }
        
        dakaLabel = [[UILabel alloc] init];
        dakaLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        dakaLabel.textColor = kBlackColor;
        dakaLabel.text = NSLocalizedString(@"人打卡", nil);
        [tripManageView addSubview:dakaLabel];
        
        self.numLabel = [[UILabel alloc] init];
        self.numLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        self.numLabel.textColor = [UIColor colorWithHexString:@"#E04E63"];
        self.numLabel.text = @"0";
        self.numLabel.textAlignment = NSTextAlignmentRight;
        [tripManageView addSubview:self.numLabel];
        
        //日历背景view
        calenderBGView = [[UIView alloc] init];
        calenderBGView.backgroundColor = kClearColor;
        calenderBGView.clipsToBounds = YES;
        [tripManageView addSubview:calenderBGView];
        //日历
        [calenderBGView addSubview:self.calendar];
        //calendar有黑色横线，需要遮住
        lineLayer = [CAShapeLayer layer];
        lineLayer.strokeColor = kWhiteColor.CGColor;
        lineLayer.fillColor = kClearColor.CGColor;
        lineLayer.lineWidth = 2;
        [tripManageView.layer addSublayer:lineLayer];
        //设置日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy年 M月";
        NSDate *currentDate = self.calendar.currentPage;
        self.dateLabel.text = [dateFormatter stringFromDate:currentDate];
        
        self.onlineLabel = [[UILabel alloc] init];
        self.onlineLabel.text = NSLocalizedString(@"连接推车后打卡", nil);
        self.onlineLabel.textAlignment = NSTextAlignmentCenter;
        self.onlineLabel.alpha = 0.3;
        self.onlineLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        self.onlineLabel.textColor = [UIColor colorWithHexString:@"#111111"];
        [self addSubview:self.onlineLabel];
        
        self.connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.connectBtn setBackgroundImage:ImageNamed(@"connect1") forState:UIControlStateNormal];
        [self.connectBtn setTitle:NSLocalizedString(@"现在连接", nil) forState:UIControlStateNormal];
        self.connectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        self.connectBtn.hidden = YES;
        [self addSubview:self.connectBtn];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.gradientLayer.frame = CGRectMake(0, 0, ScreenWidth, statusBarH+84 + RealWidth(248)+30);
    
    self.animationView.frame = CGRectMake(20, 64+statusBarH, RealWidth(212), RealWidth(180));
    
    self.temperature.frame = CGRectMake(ScreenWidth-200-25, 64+statusBarH, 200, RealWidth(50));
    
    airlabel.frame = CGRectMake(ScreenWidth-100-25, self.temperature.bottom+15, 100, RealWidth(16));
    
    self.air.frame = CGRectMake(ScreenWidth-150-25, airlabel.bottom+10, 150, RealWidth(30));
    
    self.tipsLabel.frame = CGRectMake(0, self.animationView.bottom+20, RealWidth(315), RealWidth(68));
    self.tipsLabel.centerX = self.width/2;
    
    self.tripManage.frame = CGRectMake(15, self.tipsLabel.bottom, ScreenWidth-30, RealWidth(160));
    
    self.dateLabel.frame = CGRectMake(25, 20, 100, 16);
    
    for (NSInteger i = 0; i<3; i++) {
        UIImageView *imagev = self.imageviewArray[i];
        imagev.frame = CGRectMake(self.tripManage.width-48 - i*11, 19, 23, 23);
    }
    
    dakaLabel.frame = CGRectMake(self.tripManage.width-76-40, 23, 40, 13);
    
    self.numLabel.frame = CGRectMake(dakaLabel.left-3-40, 23, 40, 13);
    
    calenderBGView.frame = CGRectMake(15, 50, self.tripManage.width-40, self.tripManage.height-45);
    
    self.calendar.frame = CGRectMake(0, 0, self.tripManage.width-40, RealWidth(290));
    
    UIBezierPath *calenderpath = [UIBezierPath bezierPath];
    [calenderpath moveToPoint:CGPointMake(15, 45)];
    [calenderpath addLineToPoint:CGPointMake(self.tripManage.width-15, 45)];
    lineLayer.path = calenderpath.CGPath;
    
    self.onlineLabel.frame = CGRectMake((ScreenWidth-250)/2, self.tripManage.bottom+15, 250, 13);
    
    self.connectBtn.frame = CGRectMake(0, 0, RealWidth(74), RealWidth(50));
    self.connectBtn.right = self.tripManage.right+5;
    self.connectBtn.centerY = self.onlineLabel.centerY;
}

-(void)setRecommendedDate:(NSString *)recommendedDate{
    _recommendedDate = recommendedDate;
    [self.calendar reloadData];   //刷新日历
}

//从后台进入前台
-(void)applicationBecomeActive{
    [self.animation play];
}

//展示天气动画
-(void)showWeatherAnimtionWithCode:(NSString *)weatherCode{
    
    if ([self.weather isEqualToString:weatherCode]) {//天气相同 则不刷新动画
        return;
    }
    self.weather = weatherCode;
    [self.animationView removeAllSubviews];
    self.animation = nil;
    
    NSInteger code = [self.weather integerValue];
    NSString *jsonName = weatherCode;
    if (code == 2 || code == 38) {
        jsonName = @"0";
    }else if (code == 3){
        jsonName = @"1";
    }else if (code == 17 || code == 18){
        jsonName = @"16";
    }else if (code == 27 || code == 28 || code == 29){
        jsonName = @"26";
    }else if (code == 35 || code == 36){
        jsonName = @"34";
    }
    //如果jsonName为空，则添加默认值
    if (jsonName == nil) {
        jsonName = @"0";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonName ofType:@"json"];
    if (path != nil) {
        //动画
        self.animation = [LOTAnimationView animationNamed:jsonName];
        self.animation.frame = CGRectMake(0, 0, self.animationView.width, self.animationView.height);
        self.animation.backgroundColor = [UIColor clearColor];
        self.animation.animationSpeed = 1.5;
        self.animation.loopAnimation = YES;  //无限循环
        self.animation.contentMode = UIViewContentModeScaleAspectFit;
        self.animation.alpha = 0;
        [self.animationView addSubview:self.animation];
        [self.animation play];
        [UIView animateWithDuration:1.5 animations:^{
            self.animation.alpha = 1;
        }];
    }
    
    //背景颜色
    UIColor *topColor = [UIColor colorWithHexString:@"#4B8FF0"];
    UIColor *bottomColor = [UIColor colorWithHexString:@"#5CAAF1"];
    NSInteger num = [NSDate hour:[NSDate date]];
    if (code >= 0 && code <= 8) {   //晴天或多云
        if ((num >= 19 && num <= 24) || (num >= 0 && num <= 6)) { // 晚上
            topColor = [UIColor colorWithHexString:@"#2F7BAF"];
            bottomColor = [UIColor colorWithHexString:@"#154E8E"];
        }else{
            topColor = [UIColor colorWithHexString:@"#4B8FF0"];
            bottomColor = [UIColor colorWithHexString:@"#5CAAF1"];
        }
    }else if (code >= 9 && code <= 25){  //见不到太阳的雨雪多云天气
        topColor = [UIColor colorWithHexString:@"#879098"];
        bottomColor = [UIColor colorWithHexString:@"#BAC2CD"];
    }else if (code == 31){   //霾
        topColor = [UIColor colorWithHexString:@"#CBC6C0"];
        bottomColor = [UIColor colorWithHexString:@"#AFA69C"];
    }else if (code == 30){   //雾
        topColor = [UIColor colorWithHexString:@"#C2C6CB"];
        bottomColor = [UIColor colorWithHexString:@"#AAB0B4"];
    }else if (code >= 26 && code <= 29){    //沙尘
        topColor = [UIColor colorWithHexString:@"#E8B67A"];
        bottomColor = [UIColor colorWithHexString:@"#CE9964"];
    }
    
    //代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(backgroundColorChange:)]) {
        [self.delegate backgroundColorChange:topColor];
    }
    
    //背景色动画
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"colors";
    anim.toValue = @[(__bridge id)topColor.CGColor,(__bridge id)bottomColor.CGColor];
    anim.duration = 2.0;
    anim.removedOnCompletion = NO;          //动画完成时不移除动画
    anim.fillMode = kCAFillModeForwards;    //动画完成时保持最新位置
    [self.gradientLayer addAnimation:anim forKey:nil];
}

#pragma mark - FSCalendarDelegate
// 切换月
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年 M月";
    NSDate *currentDate = calendar.currentPage;
    self.dateLabel.text = [dateFormatter stringFromDate:currentDate];
}
// 对有事件的显示一个点,默认是显示三个点
//- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
//    if (self.recommendedDate != nil && self.recommendedDate.length == 7) {  //一周七天
//        NSString *str = [self getRecommendDataWithDate:date];
//        if ([str isEqualToString:@"2"]) {  //计划
//            return 1;
//        }else{
//            return 0;
//        }
//    }
//    return 0;
//    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //    dateFormatter.dateFormat = @"yyyy-MM-dd";
//    //    从数组中查找是否有事件
//    //    if ([self.datesWithEvent containsObject:[dateFormatter stringFromDate:date]]) {
//    //        return 1;
//    //    }
//}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    cell.rightImageView.image = ImageNamed(@"rightImage1");
    cell.rightImageView.hidden = YES;
    cell.imageView.hidden = YES;
    if (self.recommendedDate != nil && self.recommendedDate.length == 7) {  //一周七天
        NSString *str = [self getRecommendDataWithDate:date];
        if ([str isEqualToString:@"0"]) {  //无状态
        }
        if ([str isEqualToString:@"1"]) {  //已出行打卡
            cell.shapeLayer.fillColor = [UIColor colorWithHexString:@"#EEEEEE"].CGColor;
            cell.titleLabel.textColor = kWhiteColor;
            cell.rightImageView.hidden = NO;
        }
        if ([str isEqualToString:@"2"]) {
            cell.imageView.image = ImageNamed(@"指示图标");
            cell.imageView.hidden = NO;
        }
    }
}

//根据时间戳获得当前周对应天的信息
-(NSString *)getRecommendDataWithDate:(NSDate *)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSArray *array = @[@7,@1,@2,@3,@4,@5,@6];
    NSInteger weekday = [weekdayComponents weekday];  //1到7
    weekday = [array[weekday-1] integerValue];
    return [self.recommendedDate substringWithRange:NSMakeRange(weekday-1, 1)];
}

#pragma mark - lazy
- (FSCalendar *)calendar {
    
    if (!_calendar) {
        _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,0,0,0)];
        _calendar.dataSource = self;
        _calendar.delegate = self;
        _calendar.scrollEnabled = NO;
        _calendar.pagingEnabled = NO;
        //设置周一为第一天
        _calendar.firstWeekday = 2;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
        _calendar.locale = locale;
        //设置是否用户多选
        _calendar.allowsMultipleSelection = NO;
        _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
        _calendar.backgroundColor = [UIColor whiteColor];
        //设置周字体颜色
        _calendar.appearance.weekdayTextColor = [UIColor blackColor];
        //月份模式时，只显示当前月份
        _calendar.placeholderType = FSCalendarPlaceholderTypeFillHeadTail;
        //有事件的小圆点的颜色
        _calendar.appearance.eventDefaultColor = [UIColor colorWithHexString:@"#E04E63"];
        //隐藏header
        _calendar.headerHeight = 0;
        //设置显示的时间范围   一周或一个月
        _calendar.scope = FSCalendarScopeWeek;
        _calendar.appearance.weekdayFont = [UIFont fontWithName:@"PingFangSC-Light" size:17];
        _calendar.appearance.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _calendar.appearance.titleSelectionColor = [UIColor colorWithHexString:@"#7492F4"];
        _calendar.appearance.titleTodayColor = kWhiteColor;
        _calendar.appearance.todayColor = [UIColor colorWithHexString:@"#E04E63"];
        _calendar.weekdayHeight = [UIScreen mainScreen].bounds.size.width==320?30:50;
        //        _calendar.rowHeight = 50;
        
        _calendar.backgroundColor = kClearColor;
        
        //设置当天的字体颜色
        //        _calendar.todayColor = [UIColor blueColor];
    }
    return _calendar;
}
@end
