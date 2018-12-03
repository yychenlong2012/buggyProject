//
//  TripDetailOneCell.m
//  Buggy
//
//  Created by goat on 2018/3/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "TripDetailOneCell.h"
#import "lineCollectionView.h"
#import "histogramCollectionView.h"
#import "lineLayoutOne.h"
#import "CLLabel.h"
#import "CLButton.h"
#import "dateModel.h"
#import "frequencyWeekModel.h"
#import "TripDetailViewController.h"
@interface TripDetailOneCell()<lineCollectionViewDelegate,histogramCollectionViewDelegate>

@property (nonatomic,strong) UIScrollView *BGView;         //用于切换柱状图和线条图

@property (nonatomic,strong) UIView *swipBGView;                 //手势区域
@property (nonatomic,strong) CLButton *sparseAnddense;           //稀疏 稠密
@property (nonatomic,strong) CLButton *backToday;                //归位按钮

@property (nonatomic,strong) CLLabel *weekBtn;
@property (nonatomic,strong) CLLabel *monthBtn;

@property (nonatomic,assign) BOOL isRunned;   //是否以运行  整个生命周期只运行一次

@end
@implementation TripDetailOneCell

-(instancetype)init{
    if (self == [super init]) {
        self.isRunned = NO;
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:35];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.opaque = NO;
    [self.contentView addSubview:self.topLabel];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    self.tipsLabel.text = NSLocalizedString(@"出行距离", nil);
    self.tipsLabel.textColor = [UIColor colorWithHexString:@"#172058"];
    self.tipsLabel.alpha = 0.65;
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.tipsLabel];
    
    //存放两个柱状图
    self.BGView = [[UIScrollView alloc] init];
    self.BGView.backgroundColor = kClearColor;
    self.BGView.showsVerticalScrollIndicator = NO;
    self.BGView.showsHorizontalScrollIndicator = NO;
    self.BGView.pagingEnabled = YES;
    self.BGView.scrollEnabled = NO;
    self.BGView.contentSize = CGSizeMake(2*ScreenWidth, 0);
    [self.contentView addSubview:self.BGView];
//    self.BGView.layer.borderWidth = 1;
    
    //第一个柱状图
    self.lineView = [[lineCollectionView alloc] init];
    self.lineView.backgroundColor = [UIColor clearColor];
    [self.BGView addSubview:self.lineView];
    
    //第二个柱状图
    self.histogramView = [[histogramCollectionView alloc] init];
    self.histogramView.backgroundColor = kClearColor;
    [self.BGView addSubview:self.histogramView];
    
    //按钮背景view
    self.swipBGView = [[UIView alloc]init];
    self.swipBGView.backgroundColor = kClearColor;
    [self.contentView addSubview:self.swipBGView];
    __weak typeof(self) wself = self;
    //添加手势
    [self.swipBGView addSwipeGestureRecognizer:^(UISwipeGestureRecognizer *recognizer, NSString *gestureId) {
        [wself.BGView setContentOffset:CGPointMake(ScreenWidth, 0) animated:YES];
        
        //如果已经是频率界面 则不执行
        if (wself.BGView.contentOffset.x != ScreenWidth) {
            //保存toplabel数据
            NSAttributedString *temp = wself.topLabel.attributedText;
            if (wself.beforeStr != nil) {
                wself.topLabel.attributedText = wself.beforeStr;
            }
            wself.beforeStr = temp;
            
            //属性设置
            wself.tipsLabel.text = NSLocalizedString(@"出行频率", nil);
            wself.weekBtn.hidden = NO;
            wself.monthBtn.hidden = NO;
            wself.sparseAnddense.hidden = YES;
            wself.backToday.hidden = YES;
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            vc.tableview.scrollEnabled = NO;
            [vc.tableview setContentOffset:CGPointZero animated:YES];
            //请求下一个界面的数据
            [vc requestByGestureRecognizerLeft];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            TripDetailOneCell *cell = [vc.tableview cellForRowAtIndexPath:index];
            if (cell.histogramView.isMonthType == YES) {
                vc.naviTitle.text = NSLocalizedString(@"月频率", nil);
            }else{
                vc.naviTitle.text = NSLocalizedString(@"周频率", nil);
            }
        }
        
    } direction:UISwipeGestureRecognizerDirectionLeft];
    [self.swipBGView addSwipeGestureRecognizer:^(UISwipeGestureRecognizer *recognizer, NSString *gestureId) {

        //如果已经是日里程界面则不执行
        if (wself.BGView.contentOffset.x != 0) {
            //保存toplabel数据
            NSAttributedString *temp = wself.topLabel.attributedText;
            if (wself.beforeStr != nil) {
                wself.topLabel.attributedText = wself.beforeStr;
            }
            wself.beforeStr = temp;

            //属性设置
            wself.tipsLabel.text = NSLocalizedString(@"出行距离", nil);
            [wself.BGView setContentOffset:CGPointMake(0, 0) animated:YES];
            wself.weekBtn.hidden = YES;
            wself.monthBtn.hidden = YES;
            wself.sparseAnddense.hidden = NO;
            wself.backToday.hidden = NO;
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            vc.tableview.scrollEnabled = YES;
            //请求数据
            [vc requestByGestureRecognizerRight];
            vc.naviTitle.text = NSLocalizedString(@"日里程", nil);
        }
        
    } direction:UISwipeGestureRecognizerDirectionRight];
    
    //稀疏稠密按钮
    self.sparseAnddense = [CLButton buttonWithType:UIButtonTypeCustom];
    self.sparseAnddense.extraWidth = 15;
    [self.sparseAnddense setBackgroundImage:[UIImage imageNamed:@"稀疏"] forState:UIControlStateNormal];
    [self.sparseAnddense addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSData *imageData1 = UIImagePNGRepresentation([wself.sparseAnddense backgroundImageForState:UIControlStateNormal]);
        NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"稀疏"]);
        if ([imageData1 isEqualToData:imageData2]) {
            [wself.sparseAnddense setBackgroundImage:[UIImage imageNamed:@"稠密"] forState:UIControlStateNormal];
            wself.lineView.layout.itemSize = CGSizeMake(10, wself.BGView.height);
            [wself.lineView.collectionView reloadData];
            [wself.lineView setSparseAnddense:10];
        }else{
            [wself.sparseAnddense setBackgroundImage:[UIImage imageNamed:@"稀疏"] forState:UIControlStateNormal];
            wself.lineView.layout.itemSize = CGSizeMake(40, wself.BGView.height);
            [wself.lineView.collectionView reloadData];
            [wself.lineView setSparseAnddense:40];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself.lineView setupCenterCell];
        });
    }];
    [self.swipBGView addSubview:self.sparseAnddense];
  
    //归位按钮
    self.backToday = [CLButton buttonWithType:UIButtonTypeCustom];
    self.backToday.extraWidth = 15;
    [self.backToday setBackgroundImage:[UIImage imageNamed:@"返回今日"] forState:UIControlStateNormal];
    [self.backToday addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [wself.lineView.collectionView setContentOffset:CGPointMake(wself.lineView.collectionView.contentSize.width-wself.lineView.collectionView.width, 0) animated:YES];
        dayMileageModel *model = [wself.lineView.dataArray lastObject];
        wself.topLabel.attributedText = [wself realTextWithStr1:[NSString stringWithFormat:@"%ld",(long)model.mileage] str2:@"米"];
        wself.lineView.centerIndexPath = [NSIndexPath indexPathForRow:wself.lineView.dataArray.count-1 inSection:0];
        if ([[UIViewController presentingVC] isKindOfClass:[TripDetailViewController class]]) {
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            if (model.travelInfoArray != nil && [model.travelInfoArray isKindOfClass:[NSMutableArray class]] && model.travelInfoArray.count >0) {
                [vc.travelInfoArray removeAllObjects];
                [vc.travelInfoArray addObjectsFromArray:model.travelInfoArray];
                //刷新数据
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                [vc.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                [vc.tableview setContentOffset:CGPointZero animated:YES];
            }else{
                [vc requestDailyMesseageWithDate:model.traveldate andLineHeight:model.mileage index:self.lineView.dataArray.count-1];
            }
        }
        [wself updateMileage:model.mileage index:[NSIndexPath indexPathForRow:wself.lineView.dataArray.count-1 inSection:0]];
    }];
    [self.swipBGView addSubview:self.backToday];
    self.backToday.hidden = YES;
    
    //周按钮
    self.weekBtn = [[CLLabel alloc] init];
    self.weekBtn.extraWidth = 15;
    self.weekBtn.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    self.weekBtn.text = NSLocalizedString(@"周", nil);
    self.weekBtn.textColor = kWhiteColor;
    self.weekBtn.textAlignment = NSTextAlignmentCenter;
    self.weekBtn.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
    self.weekBtn.userInteractionEnabled = YES;
    self.weekBtn.hidden = YES;
    [self.swipBGView addSubview:self.weekBtn];
    [self.weekBtn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if ([wself.weekBtn.textColor isEqual:kRGBAColor(51, 51, 51, 0.65)]) {
            wself.weekBtn.textColor = kWhiteColor;
            wself.weekBtn.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
            
            wself.monthBtn.textColor = kRGBAColor(51, 51, 51, 0.65);
            wself.monthBtn.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            
            wself.histogramView.titleArray = @[@"7",@"6",@"5",@"4",@"3",@"2",@"1",@"0"];
            wself.histogramView.isMonthType = NO;
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            [vc tapWeekBtn];
            vc.naviTitle.text = NSLocalizedString(@"周频率", nil);
            
            dispatch_queue_t asyncQueue = dispatch_get_main_queue();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5 * NSEC_PER_SEC)),asyncQueue, ^{
                //0.5秒后执行这个代码
                [wself.histogramView manualSetToplabel];
                [wself.histogramView manualSetShapeLayerColor];
            });
        }
    }];
    
    //月按钮
    self.monthBtn = [[CLLabel alloc] init];
    self.monthBtn.extraWidth = 15;
    self.monthBtn.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    self.monthBtn.text = NSLocalizedString(@"月", nil);
    self.monthBtn.textColor = kRGBAColor(51, 51, 51, 0.65);
    self.monthBtn.textAlignment = NSTextAlignmentCenter;
    self.monthBtn.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
    self.monthBtn.userInteractionEnabled = YES;
    self.monthBtn.hidden = YES;
    [self.swipBGView addSubview:self.monthBtn];
    [self.monthBtn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if ([wself.monthBtn.textColor isEqual:kRGBAColor(51, 51, 51, 0.65)]) {
            wself.monthBtn.textColor = kWhiteColor;
            wself.monthBtn.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
            
            wself.weekBtn.textColor = kRGBAColor(51, 51, 51, 0.65);
            wself.weekBtn.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            
            wself.histogramView.titleArray = @[@"35",@"30",@"25",@"20",@"15",@"10",@"5",@"0"];
            wself.histogramView.isMonthType = YES;
            TripDetailViewController *vc = (TripDetailViewController *)[UIViewController presentingVC];
            [vc tapMonthBtn];
            vc.naviTitle.text = NSLocalizedString(@"月频率", nil);
            
            dispatch_queue_t asyncQueue = dispatch_get_main_queue();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5 * NSEC_PER_SEC)),asyncQueue, ^{
                //0.5秒后执行这个代码
                [wself.histogramView manualSetToplabel];
                [wself.histogramView manualSetShapeLayerColor];
            });
        }
    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.topLabel.frame = CGRectMake((ScreenWidth-150)/2, ScreenWidth==320?25:40, 150,35);
    
    self.tipsLabel.frame = CGRectMake((ScreenWidth-300)/2, self.topLabel.bottom+15, 300, 15);
    
    //整体滑动的BGView
    self.BGView.frame = CGRectMake(0, self.tipsLabel.bottom, ScreenWidth, self.contentView.height-self.tipsLabel.bottom-90);
    
    //直线图view
    self.lineView.frame = CGRectMake(0, 0, ScreenWidth, self.BGView.height);
    self.lineView.delegate = self;
    
    //柱状图view
    self.histogramView.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, self.BGView.height);
    self.histogramView.delegate = self;
    
    self.swipBGView.frame = CGRectMake(0, self.BGView.bottom, ScreenWidth, 90);
    
    //按钮
    self.sparseAnddense.frame = CGRectMake((self.swipBGView.width-28)/2, 32, 28, 28);

    self.backToday.frame = CGRectMake(self.sparseAnddense.right+20, 32, 28, 28);
    
    self.weekBtn.frame = CGRectMake(ScreenWidth/2-38, 32, 28, 28);
    CAShapeLayer *layer1 = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.weekBtn.bounds];
    layer1.path = path.CGPath;
    self.weekBtn.layer.mask = layer1;
    
    self.monthBtn.frame = CGRectMake(ScreenWidth/2+10, 32, 28, 28);
    CAShapeLayer *layer2 = [CAShapeLayer layer];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:self.monthBtn.bounds];
    layer2.path = path2.CGPath;
    self.monthBtn.layer.mask = layer2;
    
    if (self.viewType == TripShowSecondView && self.isRunned == NO) {
        //整个生命周期中只运行一次
        [self.BGView setContentOffset:CGPointMake(ScreenWidth, 0)];
        [self showHistogramView];
        self.isRunned = YES;
    }
}

-(void)showHistogramView{
    self.tipsLabel.text = NSLocalizedString(@"出行频率", nil);
    [self.BGView setContentOffset:CGPointMake(ScreenWidth, 0) animated:NO];
    self.weekBtn.hidden = NO;
    self.monthBtn.hidden = NO;
    self.sparseAnddense.hidden = YES;
    self.backToday.hidden = YES;
}
//生成属性字符串
-(NSMutableAttributedString *)realTextWithStr1:(NSString *)str1 str2:(NSString *)str2{
    NSMutableAttributedString * firstPart = [[NSMutableAttributedString alloc] initWithString:str1==nil?@"0":str1];
    UIFont *font1 = [UIFont fontWithName:@"DINAlternate-Bold" size:35]==nil?[UIFont systemFontOfSize:35]:[UIFont fontWithName:@"DINAlternate-Bold" size:35];
    NSDictionary * firstAttributes = @{ NSFontAttributeName:font1,NSForegroundColorAttributeName:kBlackColor};
    [firstPart setAttributes:firstAttributes range:NSMakeRange(0,firstPart.length)];
    
    NSMutableAttributedString * secondPart = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",str2]];
    UIFont *font2 = [UIFont fontWithName:@"PingFangSC-Semibold" size:20]==nil?[UIFont systemFontOfSize:20]:[UIFont fontWithName:@"PingFangSC-Semibold" size:20];
    NSDictionary * secondAttributes = @{NSFontAttributeName:font2,NSForegroundColorAttributeName:kBlackColor};
    [secondPart setAttributes:secondAttributes range:NSMakeRange(0,secondPart.length)];
    [firstPart appendAttributedString:secondPart];
    return firstPart;
}
#pragma mark - lineCollectionViewDelegate  histogramCollectionViewDelegate
//collectionView停止滚动时 最中间cell的今日里程数
-(void)updateMileage:(NSInteger)mileage index:(NSIndexPath *)index{
    NSMutableAttributedString *str = [self realTextWithStr1:[NSString stringWithFormat:@"%ld",(long)mileage] str2:NSLocalizedString(@"米", nil)];
    self.topLabel.attributedText = str;
    
    //设置分析数据
    if (index.row < self.lineView.dataArray.count) {
        dayMileageModel *model = self.lineView.dataArray[index.row];
        self.tipsLabel.text = model.analysis;
    }
}

-(void)updateFrequency:(NSInteger)frequency index:(NSIndexPath *)index{
    NSMutableAttributedString *str = [self realTextWithStr1:[NSString stringWithFormat:@"%ld",(long)frequency] str2:NSLocalizedString(@"次", nil)];
    self.topLabel.attributedText = str;
    
    //设置分析数据
    if (index.row < self.histogramView.dataArray.count) {
        frequencyWeekModel *model = self.histogramView.dataArray[index.row];
        self.tipsLabel.text = model.analysis;
    }
}

-(void)scrollViewContentOffsetX:(CGFloat)offsetX{
    if (self.lineView.collectionView.contentSize.width-self.lineView.collectionView.width != offsetX) {
        self.backToday.hidden = NO;
    }else{
        self.backToday.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
