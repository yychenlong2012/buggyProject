//
//  SDMusicPlayer.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "SDMusicPlayer.h"

@interface SDMusicPlayer ()

@end

@implementation SDMusicPlayer

+ (instancetype)shareManager{
    
    static SDMusicPlayer *musicPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        musicPlayer = [[SDMusicPlayer alloc] init];
    });
    return musicPlayer;
}
- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)play{
    [super play];
    self.playing = YES;
    Byte keyByte[] = {0x55,0xaa,0x00,0x03,0x02,(0 - 0x05)};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}

- (void)pause{
    [super pause];
    self.playing = NO;
    Byte keyByte[] = {0x55,0xaa,0x00,0x03,0x01,(0 - 0x04)};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}

- (void)stop{
    [super stop];
    self.playing = NO;
    Byte keyByte[] = {0x55,0xaa,0x00,0x03,0x01,(0 - 0x04)};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}

- (void)next{
    [super next];
    Byte keyByte[] = {0x55,0xaa,0x00,0x03,0x04,(0 - 0x07)};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}

- (void)previous{
    [super previous];
    Byte keyByte[] = {0x55,0xaa,0x00,0x03,0x05,(0 - 0x08)};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
}
// 获取当前音量为多少
- (float)getSystomVolume{
    [super getSystomVolume];
    Byte keyByte[] = {0x55,0xaa,0x00,0x04,0x04,0xf8};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:6];
    [BLEMANAGER writeValueForPeripheral:data];
    return 0;
}

- (void)adjustVolumeOfplayer:(float)value{
    [super adjustVolumeOfplayer:value];
    int audioCount = (int)(value * 32);
    Byte volumebyte = audioCount;
    Byte keyByte[] = {0x55,0xaa,0x01,0x04,0x03,volumebyte,(0 - (8  + (int)volumebyte))};
    NSData *data = [[NSData alloc] initWithBytes:keyByte length:7];
    [BLEMANAGER writeValueForPeripheral:data];
}

- (void)selectTypeMode:(PLAYERTYPEMODE )typeMode{
    [super selectTypeMode:typeMode];
}

@end
