//
//  MusicListTableViewCell.h
//  Buggy
//
//  Created by goat on 2018/4/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MusicListView;
@class MusicAlbumModel;
@interface MusicListTableViewCell : UITableViewCell
@property(nonatomic,strong) MusicListView *leftView;
@property(nonatomic,strong) MusicListView *rightView;

@property(nonatomic,strong) MusicAlbumModel *leftModel;   //左边的模型
@property(nonatomic,strong) MusicAlbumModel *rightModel;  //右边的模型
@end
