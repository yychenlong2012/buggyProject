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
        }
    }
    
//    if (leftModel.imageface != nil && ![leftModel.imageface isKindOfClass:[NSNull class]]) {
//        
//        NSString *urlStr;
//        if ([leftModel.imageface isKindOfClass:[NSString class]]) {
//            urlStr = (NSString *)leftModel.imageface;
//        }
//        
//        if ([leftModel.imageface isKindOfClass:[AVFile class]]) {
//            urlStr = leftModel.imageface.url;
//        }
//        
//        NSURL *url = [NSURL URLWithString:urlStr];
//        if (url) {
//            [self.leftView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
//        }
//    }
    
    if ([leftModel.title isKindOfClass:[NSString class]]) {
        self.leftView.titleLabel.text = leftModel.title;
    }
    
    self.leftView.hidden = NO;
}

-(void)setRightModel:(MusicAlbumModel *)rightModel{
    _rightModel = rightModel;
    
//    if (rightModel.imageFace != nil && ![rightModel.imageFace isKindOfClass:[NSNull class]]) {
//
//        NSString *urlStr;
//        if ([rightModel.imageFace isKindOfClass:[NSString class]]) {
//            urlStr = (NSString *)rightModel.imageFace;
//        }
//
//        if ([rightModel.imageFace isKindOfClass:[AVFile class]]) {
//            urlStr = rightModel.imageFace.url;
//        }
//
//        NSURL *url = [NSURL URLWithString:urlStr];
//        if (url) {
//            [self.rightView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
//        }
//    }
    
    if ([rightModel.imageface isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:rightModel.imageface];
        if (url) {
            [self.rightView.imageView sd_setImageWithURL:url placeholderImage:ImageNamed(@"歌单占位图")];
        }
    }
    
    if ([rightModel.title isKindOfClass:[NSString class]]) {
        self.rightView.titleLabel.text = rightModel.title;
    }
    
    self.rightView.hidden = NO;
}

@end
