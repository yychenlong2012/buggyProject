//
//  MusicListCell.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MusicListModel.h"
#import "WaveView.h"

#define MusicListCellHeight 55

typedef void(^DownLoad)(void);
@interface MusicListCell : UITableViewCell

@property(nonatomic ,copy) DownLoad download;
    
@property (nonatomic ,strong) MusicListModel *model;

@property (nonatomic ,assign) NSInteger downProgress;

//@property (nonatomic ,assign) BOOL isHaveNetWork;      //是否有网
/**
 开始波纹动画
 */
- (void)startWaveAnimation;

/**
 结束波纹动画
 */
- (void)endWaveAnimation;

@end
