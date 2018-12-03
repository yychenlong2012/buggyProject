//
//  banner2.h
//  Buggy
//
//  Created by goat on 2018/6/30.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MusicBannerModel;

@interface banner2 : UIView
//数据
@property(nonatomic,strong)NSMutableArray<MusicBannerModel *> *dataArray;
-(void)startTimer;
-(void)stopTimer;
@end
