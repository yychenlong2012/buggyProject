//
//  bannerItem.m
//  Buggy
//
//  Created by goat on 2018/6/30.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "bannerItem.h"
#import "MusicBannerModel.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"
#import "MusicArticleViewController.h"
#import "MusicListViewController.h"

@interface bannerItem()
@property (nonatomic,strong) CAShapeLayer *shapelayer;
@property (nonatomic,strong) UIImageView *imageview;   //banner图片
@property (nonatomic,strong) UILabel *bannerTitle;
@end
@implementation bannerItem
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageview = [[UIImageView alloc] init];
        [self addSubview:self.imageview];
        __weak typeof(self) wself = self;
        
        self.shapelayer = [CAShapeLayer layer];
        self.imageview.layer.mask = self.shapelayer;
        self.imageview.userInteractionEnabled = YES;
        [self.imageview addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                MainViewController *main = (MainViewController *)[UIViewController presentingVC];
                DYBaseNaviagtionController *navi = main.selectedViewController;
                if ([wself.model.type isEqualToString:@"song"]) {  //歌曲
                    MusicListViewController *list = [[MusicListViewController alloc] init];
//                    list.model = wself.model.albuminfo;
                    list.model = [wself.model backMusicAlbumModel];
//                    list.albumObject = wself.model.album;
                    if (navi != nil) {
                        [navi pushViewController:list animated:YES];
                    }
                    
                }else if ([wself.model.type isEqualToString:@"text"]){  //文章
                    MusicArticleViewController *article = [[MusicArticleViewController alloc] init];
                    article.title = wself.model.title;
                    article.articleUrl = wself.model.url;
                    article.view.backgroundColor = kWhiteColor;
                    if (navi != nil) {
                        [navi pushViewController:article animated:YES];
                    }
                }
            }
        }];
        
        self.bannerTitle = [[UILabel alloc] init];
        self.bannerTitle.textAlignment = NSTextAlignmentCenter;
        self.bannerTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        self.bannerTitle.textColor = kWhiteColor;
        self.bannerTitle.backgroundColor = kClearColor;
        self.bannerTitle.hidden = YES;
        [self addSubview:self.bannerTitle];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageview.frame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageview.bounds cornerRadius:8];
    self.shapelayer.path = path.CGPath;
    
    self.bannerTitle.frame = CGRectMake(0, 0, RealWidth(300), 15);
    self.bannerTitle.center = CGPointMake(self.width/2, self.height/2);
}

-(void)setModel:(MusicBannerModel *)model{
    _model = model;
    NSURL *imageUrl = [NSURL URLWithString:model.imgurl];
    if (imageUrl) {
        [self.imageview sd_setImageWithURL:imageUrl placeholderImage:ImageNamed(@"banner占位图")];
    }
    
    if (model.title != nil && ![model.title isKindOfClass:[NSNull class]]) {
        self.bannerTitle.text = model.title;
    }
}


//2018-12-26 10:11:35.185450+0800 Buggy[449:28529] 图片大小 0.408698 0.200139
//2018-12-26 10:11:35.322241+0800 Buggy[449:28529] 图片大小 0.432026 0.194679
//2018-12-26 10:11:35.492161+0800 Buggy[449:28529] 图片大小 0.577319 0.408294
//2018-12-26 10:11:35.573947+0800 Buggy[449:28529] 图片大小 0.149972 0.223761
//2018-12-26 10:11:35.884368+0800 Buggy[449:28529] 图片大小 0.465430 0.326331
//2018-12-26 10:11:36.019810+0800 Buggy[449:28529] 图片大小 0.648888 0.296264
@end
