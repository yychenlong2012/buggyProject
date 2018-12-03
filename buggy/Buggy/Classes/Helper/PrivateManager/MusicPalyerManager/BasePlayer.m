//
//  BasePlayer.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "BasePlayer.h"

@implementation BasePlayer

- (void)play{}

- (void)pause{}

- (void)stop{}

- (void)next{}

- (void)previous{}

- (float)getSystomVolume{
    return 0;
}

- (void)adjustVolumeOfplayer:(float)value{}

- (void)selectTypeMode:(PLAYERTYPEMODE)typeMode{}

@end
