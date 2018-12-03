//
//  AVAResourceLoaderManager.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/23.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVRequestTask.h"
#define MimeType @"video/mp3"

@class AVAResourceLoaderManager;
@protocol ResourceLoaderManagerDelegate <NSObject>

@required
- (void)loader:(AVAResourceLoaderManager *)loader cacheProgress:(CGFloat)progress;
@optional
- (void)loader:(AVAResourceLoaderManager *)loader failLoadingWithError:(NSError *)error;
@end

@interface AVAResourceLoaderManager : NSObject<AVAssetResourceLoaderDelegate,AVRequestTaskDelegate>

@property (nonatomic ,weak) id<ResourceLoaderManagerDelegate> delegate;
@property (atomic,assign) BOOL seekRequired;       // Seek标示
@property (nonatomic ,assign) BOOL cacheFinished;  

- (void)stopLoading;

@end
