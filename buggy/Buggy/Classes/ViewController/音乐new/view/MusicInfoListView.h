//
//  MusicInfoListView.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicListCell.h"
#import "MusicThemeModel.h"
#import "MainModel.h"
@class MusicAlbumModel;

#define MusicInfoListViewHeight (205 * _MAIN_RATIO_375 + 64)

@protocol MusicInfoListViewDelegate <NSObject>
@optional
- (void)musicDidSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
- (void)musicwillDisplayCellForRowAtIndexPath:(NSIndexPath*)indexPath withTableView:(UITableView *)tableView;

- (void)scrollDidScroll:(CGFloat)offsetY;
@end

@protocol MusicInfoListViewDataDelegate <NSObject>

@required
- (NSInteger)musicNumberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)musicTableviewCell:(UITableViewCell *)tableViewCell musicCellForRowAtIndexPath:(NSIndexPath *)indexPath musicIdentifiler:(NSString *)musicIdentifiler;

@end

@interface MusicInfoListView : UIView

@property (nonatomic,weak) id<MusicInfoListViewDelegate> delegate;   //assign

@property (nonatomic,weak) id<MusicInfoListViewDataDelegate> dataSource;   //assign

@property (nonatomic,strong) UITableView *tableView;

//@property (nonatomic,strong) MusicThemeModel *model;   //3.0版本之前的model

@property (nonatomic,strong) MusicAlbumModel *topModel; //现在的模型

@property (nonatomic,assign) MUSIC_TYPENUMBER musicTypeNumber;
    
- (void)addAnimation;

@end
