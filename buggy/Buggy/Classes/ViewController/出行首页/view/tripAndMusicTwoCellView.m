//
//  tripAndMusicTwoCellView.m
//  Buggy
//
//  Created by goat on 2018/5/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "tripAndMusicTwoCellView.h"
#import "TripDetailViewController.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"

@implementation tripAndMusicTwoCellView{
    UILabel *todayLabel;
    UILabel *rateLabel;
    UIImageView *todayImageView;
    UILabel *todayImageViewLabel2;
    UIImageView *rateImageView;
    UILabel *rateImageViewLabel2;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        todayLabel = [[UILabel alloc] init];
        todayLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        todayLabel.text = NSLocalizedString(@"今日出行", nil);
        todayLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:todayLabel];
        
        rateLabel = [[UILabel alloc] init];
        rateLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        rateLabel.text = NSLocalizedString(@"本周频率", nil);
        rateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:rateLabel];
        
        todayImageView = [[UIImageView alloc] init];
        todayImageView.image = [UIImage imageNamed:@"里程"];
        todayImageView.userInteractionEnabled = YES;
        [todayImageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            TripDetailViewController *vc = [[TripDetailViewController alloc] init];
            vc.naviTitle.text = NSLocalizedString(@"日里程", nil);
            vc.cellType = TripShowFirstCell;
            vc.view.backgroundColor = kWhiteColor;
            
            if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
                DYBaseNaviagtionController *navi = (DYBaseNaviagtionController *)mainVC.selectedViewController;
                if (navi != nil) {
                    [navi.topViewController presentViewController:vc animated:YES completion:nil];
                }
            }
            
            
        }];
        [self addSubview:todayImageView];
        
        self.todayMileage = [[UILabel alloc] init];
        self.todayMileage.textAlignment = NSTextAlignmentRight;
        self.todayMileage.text = @"0";
        self.todayMileage.textColor =kWhiteColor;
        self.todayMileage.backgroundColor = kClearColor;
        self.todayMileage.font = [UIFont fontWithName:@"DINAlternate-Bold" size:(ScreenWidth==320?30:37)];
        [todayImageView addSubview:self.todayMileage];
        
        todayImageViewLabel2 = [[UILabel alloc] init];
        todayImageViewLabel2.textAlignment = NSTextAlignmentRight;
        todayImageViewLabel2.text = NSLocalizedString(@"米", nil);
        todayImageViewLabel2.textColor =kWhiteColor;
        todayImageViewLabel2.backgroundColor = kClearColor;
        todayImageViewLabel2.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        [todayImageView addSubview:todayImageViewLabel2];
        
        rateImageView = [[UIImageView alloc] init];
        rateImageView.image = [UIImage imageNamed:@"频率"];
        rateImageView.userInteractionEnabled = YES;
        [rateImageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            TripDetailViewController *vc = [[TripDetailViewController alloc] init];
            vc.naviTitle.text = NSLocalizedString(@"周频率", nil);
            vc.cellType = TripShowSecondCell;
            vc.view.backgroundColor = kWhiteColor;
            
            if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
                DYBaseNaviagtionController *navi = (DYBaseNaviagtionController *)mainVC.selectedViewController;
                if (navi != nil) {
                    [navi.topViewController presentViewController:vc animated:YES completion:nil];
                }
            }
            
            
        }];
        [self addSubview:rateImageView];
        
        self.weekFrequency = [[UILabel alloc] init];
        self.weekFrequency.textAlignment = NSTextAlignmentRight;
        self.weekFrequency.text = @"0";
        self.weekFrequency.textColor =kWhiteColor;
        self.weekFrequency.backgroundColor = kClearColor;
        self.weekFrequency.font = [UIFont fontWithName:@"DINAlternate-Bold" size:(ScreenWidth==320?30:37)];
        [rateImageView addSubview:self.weekFrequency];
        
        rateImageViewLabel2 = [[UILabel alloc] init];
        rateImageViewLabel2.textAlignment = NSTextAlignmentRight;
        rateImageViewLabel2.text = NSLocalizedString(@"次", nil);
        rateImageViewLabel2.textColor =kWhiteColor;
        rateImageViewLabel2.backgroundColor = kClearColor;
        rateImageViewLabel2.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        [rateImageView addSubview:rateImageViewLabel2];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    todayLabel.frame = CGRectMake(25, 20, RealWidth(170), 20);
    rateLabel.frame = CGRectMake(ScreenWidth/2 + 17, 20, RealWidth(170), 20);
    todayImageView.frame = CGRectMake(15, todayLabel.bottom+10, RealWidth(165), RealWidth(104));
    self.todayMileage.frame = CGRectMake(todayImageView.width-33-RealWidth(110), 29, RealWidth(110), 37);
    todayImageViewLabel2.frame = CGRectMake(todayImageView.width-12-15, 45, 15, 15);
    rateImageView.frame = CGRectMake(30+RealWidth(165), todayLabel.bottom+10, RealWidth(165), RealWidth(104));
    self.weekFrequency.frame = CGRectMake(todayImageView.width-33-RealWidth(100), 29, RealWidth(100), 37);
    rateImageViewLabel2.frame = CGRectMake(todayImageView.width-12-15, 45, 15, 15);
}

@end
