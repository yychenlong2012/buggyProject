//
//  lrcScrollView.h
//  Buggy
//
//  Created by goat on 2018/6/13.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface lrcScrollView : UIScrollView
@property (nonatomic, copy) NSString *lrcName;          //歌词文件名  就是歌曲Id
@property (nonatomic,assign) NSTimeInterval currentTime;   //当前播放时间
@end
