//
//  MusicItemListCell.h
//  Buggy
//
//  Created by goat on 2018/6/7.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicListModel.h"
#import "WaveView.h"

#define MusicListCellHeight 55

@interface MusicItemListCell : UITableViewCell
@property (nonatomic ,strong) musicModel *model;
@property (nonatomic ,assign) NSInteger index;   //cell的行号

/**
 开始波纹动画
 */
- (void)startWaveAnimation;

/**
 结束波纹动画
 */
- (void)endWaveAnimation;
@end
