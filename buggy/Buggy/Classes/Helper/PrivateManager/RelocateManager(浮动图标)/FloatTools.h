//
//  FloatTools.h
//  Buggy
//
//  Created by goat on 2018/7/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloatTools : NSObject
@property (nonatomic,strong) UIView *bgView;   //背景view
@property (nonatomic,strong) UIImageView *icon;  //音乐图片
@property (nonatomic,strong) UIImageView *topImageView;  //顶部暂停图标

@property (nonatomic,strong) CAShapeLayer *progressLayer;  //播放进度

@property (nonatomic,assign) BOOL isShowing;   //是否正在显示浮动图标

+ (instancetype)manager;

//显示浮动按钮
-(void)showMusicRelocateView;
//移除圆形的播放器入口
- (void)dismissMusicRelocateView;

-(void)pauseAnima;

-(void)resumeAnima;

//重启动画
-(void)restartAnimation;
@end
