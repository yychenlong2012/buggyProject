//
//  MusicPlayNewController.h
//  Buggy
//
//  Created by goat on 2018/4/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BaseVC.h"
typedef enum : NSUInteger {
    kOrderMode = 0,   //顺序播放
    kRandomMode = 1,      //随机播放
    kSingelMode = 2       //单曲循环
}Music_Play_Mode;//播放模式

//typedef enum : NSUInteger {
//    MobileOrNetwork = 0, //手机或者网络
//    BuggySDCard,         //推车SD卡
//}Music_Source;//音乐源

@interface MusicPlayNewController : BaseVC
//@property (nonatomic,assign) Music_Source playSource;   //音乐源

//暂停或播放
-(void)musicPlayerPauseOrPlay;
@end
