//
//  SDMusicPlayer.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "BasePlayer.h"
#import "BlueToothManager.h"

@interface SDMusicPlayer : BasePlayer

@property (nonatomic ,assign) BOOL playing;

+ (instancetype)shareManager;

@end
