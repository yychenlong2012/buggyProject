//
//  BasePlayer.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSInteger {
    
    PLAYER_ORDER,      // 顺序
    PLAYER_REPEAT,     // 循环
    PLAYER_RANDOM,     // 随机
 
    
} PLAYERTYPEMODE;

@interface BasePlayer : NSObject

- (void)play;

- (void)pause;

- (void)stop;

- (void)next;

- (void)previous;

- (float)getSystomVolume;

- (void)adjustVolumeOfplayer:(float)value;

- (void)selectTypeMode:(PLAYERTYPEMODE)typeMode;

@end
