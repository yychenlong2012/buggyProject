//
//  TripDetailTwoCell.m
//  Buggy
//
//  Created by goat on 2018/3/26.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "TripDetailTwoCell.h"
#import "TravelInfoModel.h"
@interface TripDetailTwoCell()
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UILabel *startTime;
@property (nonatomic,strong) UILabel *endTime;
@property (nonatomic,strong) UILabel *distance;
@property (nonatomic,strong) UILabel *calories;
@end
@implementation TripDetailTwoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        self.startTime = [[UILabel alloc] init];
        self.startTime.textAlignment = NSTextAlignmentLeft;
        self.startTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:self.startTime];
        
        self.endTime = [[UILabel alloc] init];
        self.endTime.textAlignment = NSTextAlignmentLeft;
        self.endTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:self.endTime];
        
        self.distance = [[UILabel alloc] init];
        self.distance.textAlignment = NSTextAlignmentLeft;
        self.distance.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.distance.textColor = [UIColor colorWithHexString:@"#E04E63"];
        [self.contentView addSubview:self.distance];
        
        self.calories = [[UILabel alloc] init];
        self.calories.textAlignment = NSTextAlignmentLeft;
        self.calories.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.calories.textColor = [UIColor colorWithHexString:@"#E04E63"];
        [self.contentView addSubview:self.calories];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"#172058"];
        self.lineView.alpha = 0.15;
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat leftMargin = 90;
    self.startTime.frame = CGRectMake(leftMargin, 0, 70, 14);
    self.endTime.frame = CGRectMake(self.startTime.right+10, 0, 50, 14);
    self.distance.frame = CGRectMake(leftMargin, 29, 70, 14);
    self.calories.frame = CGRectMake(self.distance.right+10, 29, 80, 14);
    self.lineView.frame = CGRectMake(leftMargin, self.distance.bottom+15, ScreenWidth-67, 1);
    
    CGFloat r = 10;    //圆圈直径
    //小圆圈
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.strokeColor = [UIColor colorWithHexString:@"E04E63"].CGColor;
    circleLayer.fillColor = kClearColor.CGColor;
    circleLayer.lineWidth = 2;
    [self.contentView.layer addSublayer:circleLayer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(45, 3, r, r)];
    circleLayer.path = path.CGPath;
    
    //虚线
    CAShapeLayer *line1 = [CAShapeLayer layer];
    line1.strokeColor = [UIColor colorWithHexString:@"E04E63"].CGColor;
    line1.lineWidth = 1;
    line1.lineDashPattern = @[@(3),@(3)];
    [self.contentView.layer addSublayer:line1];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(45+r/2, r+3)];
    [path2 addLineToPoint:CGPointMake(45+r/2, self.contentView.height)];
    line1.path = path2.CGPath;
    
//    CAShapeLayer *line2 = [CAShapeLayer layer];
//    line2.strokeColor = kBlackColor.CGColor;
//    line2.lineWidth = 1;
//    line2.lineDashPattern = @[@(3),@(3)];
//    [self.contentView.layer addSublayer:line2];
//
//    UIBezierPath *path3 = [UIBezierPath bezierPath];
//    [path3 moveToPoint:CGPointMake(45+r/2, 10 + r)];
//    [path3 addLineToPoint:CGPointMake(45+r/2, self.contentView.height)];
//    line2.path = path3.CGPath;
    
}

-(void)setTravelModel:(TravelInfoModel *)travelModel{
    _travelModel = travelModel;
    
    NSDateFormatter *forme = [[NSDateFormatter alloc] init];
    forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *startdate = [forme dateFromString:travelModel.starttime];
    NSDate *enddate = [forme dateFromString:travelModel.endtime];
    forme.dateFormat = @"HH:mm";
    self.startTime.text = [forme stringFromDate:startdate];
    self.endTime.text = [forme stringFromDate:enddate];
    self.distance.text = [NSString stringWithFormat:@"%ld m",(long)travelModel.mileage];
    self.calories.text = [NSString stringWithFormat:@"%ld kcal",(long)travelModel.calories];
}


- (void)awakeFromNib {
    [super awakeFromNib];
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
