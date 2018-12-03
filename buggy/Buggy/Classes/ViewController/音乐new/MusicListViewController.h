//
//  MusicListViewController.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseVC.h"
#import "MusicManager.h"
@class MusicAlbumModel;

@interface MusicListViewController : BaseVC

@property (nonatomic,assign) MusicType musicType;   //音乐栏目  暂时不用  MUSIC_TYPENUMBER

@property (nonatomic,strong) MusicAlbumModel *model;   //banner跳转时使用

@end
