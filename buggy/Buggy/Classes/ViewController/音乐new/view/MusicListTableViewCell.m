//
//  MusicListTableViewCell.m
//  Buggy
//
//  Created by goat on 2018/4/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicListTableViewCell.h"
#import "MusicListView.h"
#import "MusicListView.h"
#import "MusicAlbumModel.h"
#import "MusicListViewController.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"
@implementation MusicListTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
            MainViewController *main = (MainViewController *)[UIViewController presentingVC];
            DYBaseNaviagtionController *navi = main.selectedViewController;
            __weak typeof(self) wself = self;
            
            self.leftView = [[MusicListView alloc] init];
            self.leftView.hidden = YES;
            [self.contentView addSubview:self.leftView];
            self.leftView.userInteractionEnabled = YES;
            [self.leftView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                MusicListViewController *vc = [[MusicListViewController alloc] init];
                vc.musicType = kAlbum;
                vc.model = wself.leftModel;
                if (navi != nil) {
                    [navi pushViewController:vc animated:YES];
                }
                
            }];
            
            self.rightView = [[MusicListView alloc] init];
            self.rightView.hidden = YES;
            [self.contentView addSubview:self.rightView];
            self.rightView.userInteractionEnabled = YES;
            [self.rightView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                MusicListViewController *vc = [[MusicListViewController alloc] init];
                vc.musicType = kAlbum;
                vc.model = wself.rightModel;
                if (navi != nil) {
                    [navi pushViewController:vc animated:YES];
                }
                
            }];
        }
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.leftView.frame = CGRectMake(20, 0, RealWidth(160), RealWidth(160)+10+15+20);
    self.rightView.frame = CGRectMake(self.contentView.width-20-RealWidth(160), 0, RealWidth(160), RealWidth(160)+10+15+20);
}

-(void)setLeftModel:(MusicAlbumModel *)leftModel{
    _leftModel = leftModel;
    
    if ([leftModel.imageface isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:leftModel.imageface];
        if (url) {
            [self.leftView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
//            [self.leftView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图") options:SDWebImageProgressiveDownload|SDWebImageLowPriority];
        }
    }

    if ([leftModel.title isKindOfClass:[NSString class]]) {
        self.leftView.titleLabel.text = leftModel.title;
    }
    
    self.leftView.hidden = NO;
}

-(void)setRightModel:(MusicAlbumModel *)rightModel{
    _rightModel = rightModel;
    
    if ([rightModel.imageface isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:rightModel.imageface];
        if (url) {
            [self.rightView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
//            [self.rightView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图") options:SDWebImageProgressiveDownload|SDWebImageLowPriority];
        }
    }
    
    if ([rightModel.title isKindOfClass:[NSString class]]) {
        self.rightView.titleLabel.text = rightModel.title;
    }
    
    self.rightView.hidden = NO;
}

@end
//2018-12-26 10:06:03.698525+0800 Buggy[385:26604] 图片大小 0.432026 0.194679
//2018-12-26 10:06:03.891002+0800 Buggy[385:26604] 图片大小 0.340916 0.195764
//2018-12-26 10:06:04.030019+0800 Buggy[385:26604] 图片大小 0.454430 0.260518
//2018-12-26 10:06:04.177607+0800 Buggy[385:26604] 图片大小 0.389549 0.217991
//2018-12-26 10:06:06.342947+0800 Buggy[385:26604] 图片大小 0.597509 0.327223
//2018-12-26 10:06:06.480886+0800 Buggy[385:26604] 图片大小 0.408623 0.236028
//2018-12-26 10:06:06.663220+0800 Buggy[385:26604] 图片大小 0.381844 0.197015
//2018-12-26 10:06:06.822294+0800 Buggy[385:26604] 图片大小 0.532519 0.256645
