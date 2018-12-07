//
//  MusicManager.m
//  Buggy
//
//  Created by goat on 2018/1/19.
//  Copyright © 2018年 3Pomelos. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "MusicManager.h"
#import "NSString+AVLoader.h"
#import "FloatTools.h"
#define updateTime 0.2    //定时器刷新间隔
@interface MusicManager()

//@property (strong, nonatomic) NSTimer * progressTimer;
@property (strong, nonatomic) CADisplayLink *displaylink;
@end
@implementation MusicManager
/**
 *  获得播放器单例
 *
 *  @return 播放器单例
 */
+ (instancetype)defaultPlayer{
    static MusicManager * player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 3.让应用程序可以接受远程事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //创建FSAudioStream对象
        FSStreamConfiguration *config = [[FSStreamConfiguration alloc] init];
        config.httpConnectionBufferSize *= 2;    //流缓冲区大小
        config.enableTimeAndPitchConversion = YES;
        config.maxDiskCacheSize = 200*1024*1024;    //最大缓冲内存
        player = [[super alloc] initWithConfiguration:config];

        
        player.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"发生错误：%@",description);
        };
        player.onCompletion = ^(){
            [player next];
        };
        player.onStateChange = ^(FSAudioStreamState state){   //播放状态变化
            switch (state) {
                case kFsAudioStreamPaused:{
                    NSLog(@"暂停  pauseAnima");
                    [[FloatTools manager] pauseAnima];
                    if ([player.playerDelegate respondsToSelector:@selector(PD_playPause)]) {
                        [player.playerDelegate PD_playPause];
                    }
                } break;
                case kFsAudioStreamStopped:{
                    NSLog(@"停止");
//                    [[FloatTools manager] pauseAnima];
                } break;
                case kFsAudioStreamPlaying:{
                    NSLog(@"正在播放  resumeAnima");
                    [[FloatTools manager] resumeAnima];
                } break;
                case kFsAudioStreamSeeking:{
                    NSLog(@"seeking");
                } break;
                case kFSAudioStreamEndOfFile:{
                    NSLog(@"播放完毕  restartAnimation");
                    [[FloatTools manager] resumeAnima];
                    [[FloatTools manager] restartAnimation];
                } break;
                case kFsAudioStreamFailed:{
                    NSLog(@"失败");
                } break;
                case kFsAudioStreamRetryingStarted:{
                    NSLog(@"重试");
                } break;
                case kFsAudioStreamRetryingSucceeded:{
                    NSLog(@"重试成功");
                } break;
                case kFsAudioStreamRetryingFailed:{
                    NSLog(@"重试失败");
                } break;
                case kFsAudioStreamPlaybackCompleted:{
                    NSLog(@"重放完成");
                } break;
                case kFsAudioStreamUnknownState:{
                    NSLog(@"未知");
                } break;
                default:
                    break;
            }

//            if (state == kFsAudioStreamPlaying) {
//                [player setPlayRate:player.rate];
//            }
//            if (state == kFsAudioStreamStopped) {
//                if (player.isSinglePlay && player.isLoop) {
//                    [player playItemAtIndex:player.currentItemIndex];
//                }
//                if (!player.isSinglePlay && player.currentItemIndex+1 < player.audioArray.count) {
//                    [player playItemAtIndex:player.currentItemIndex+1];
//                }
//                if (!player.isSinglePlay && player.isLoop && player.currentItemIndex+1 >= player.audioArray.count) {
//                    [player playItemAtIndex:0];
//                }
//            }
        };
        [player setVolume:0.5];
//        player.progressTimer = nil;
        player.displaylink = nil;
        player.playMode = kOrderOfPlayMode;
        player.rate = 2.0;
        player.currentItemIndex = 0;
    });
    
    return player;
}

/**
 *  播放
 */
- (void)play{
    [super play];

    if (!_displaylink) {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    _isPlaying = YES;
}

/**
 *  播放指定地址的文件
 *
 *  @param url 文件地址
 */
- (void)playFromURL:(NSURL *)url{
    [super playFromURL:url];

//    NSURL *localUrl = [NSURL fileURLWithPath:[[NSString cacheFolderPath] stringByAppendingPathComponent:@"1111.mp3"]];
//    if (localUrl != nil) {
//        self.outputFile = localUrl;
//    }
    
    if (!_displaylink) {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    _isPlaying = YES;
}

/**
 *  从指定位置开始播放文件
 *
 *  @param offset 起始偏移量
 */
- (void)playFromOffset:(FSSeekByteOffset)offset{
    [super playFromOffset:offset];

    if (!_displaylink) {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    _isPlaying = YES;
}

/**
 *  播放文件队列中的指定文件
 *
 *  @param itemIndex 指定的文件的索引
 */
- (void)playItemAtIndex:(NSUInteger)itemIndex{

    //首先更新浮动图标图片
    [FloatTools manager].icon.image = ImageNamed(@"播放界面占位");
    
    if (itemIndex < self.audioArray.count) {
        musicModel *model = [self.audioArray objectAtIndex:itemIndex];
        //上传播放次数
        [NETWorkAPI uploadMusicPlayCount:model];
        
        self.currentItemIndex = itemIndex;
        self.currentMusicImage = nil;
        self.currntMusicName = model.musicname;
        
        //判断有无本地文件
        NSString *fileName = @"";
        if ([model.musicname isKindOfClass:[NSString class]] && model.musicname.length > 0) {
            fileName = model.musicname;
        }
        if (model.musicid > 0) {
            fileName = [NSString stringWithFormat:@"%ld",(long)model.musicid];
        }
        if (![fileName isEqualToString:@""]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@.mp3",[NSString cacheFolderPath],fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSURL *url = [NSURL fileURLWithPath:path];
                if (url) {
                    //播放歌曲
                    [self stop];
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.15*NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^{
                        [self playFromURL:url];
                    });
                    
                    if ([_playerDelegate respondsToSelector:@selector(PD_startPlayNewMusic)]) {
                        [_playerDelegate PD_startPlayNewMusic];
                    }
                    //下载图片
                    [self downloadImage:model];
                    return;
                }
            }
        }
        
        //无本地文件，使用url获取
        NSString *musicurl = model.musicurl;
        if (musicurl != nil && [musicurl isKindOfClass:[NSString class]] && [musicurl hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:musicurl];
            if (url) {
                //播放歌曲
                [self stop];
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.15*NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    [self playFromURL:url];
                });
                if ([_playerDelegate respondsToSelector:@selector(PD_startPlayNewMusic)]) {
                    [_playerDelegate PD_startPlayNewMusic];
                }
                //下载图片
                [self downloadImage:model];
            }
        }
    } else { NSLog(@"超出列表长度"); }
}

-(void)downloadImage:(musicModel *)model{
        
    //如果没有file文件 判断是否有url
    NSString *imageUrl = model.imageurl;
    if (imageUrl != nil && [imageUrl isKindOfClass:[NSString class]] && [imageUrl hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:imageUrl];
        if (url) {
            [[[SDWebImageManager sharedManager] imageDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
                    self->_currentMusicImage = image;
                    if ([self->_playerDelegate respondsToSelector:@selector(PD_startPlayNewMusic)]) {
                        [self->_playerDelegate PD_startPlayNewMusic];
                    }
                    [FloatTools manager].icon.image = image;
                }
                //设置封面
                [self configLockScreenPlay:model];
            }];
        }
    }
}

/* 配置锁屏界面 */
- (void)configLockScreenPlay:(musicModel *)model{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.currentMusicImage) {
        // 初始化一个封面
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: self.currentMusicImage];
        // 设置封面
        [dict setObject: albumArt forKey:MPMediaItemPropertyArtwork];
    }
    // 设置标题
    [dict setObject:model.musicname forKey:MPMediaItemPropertyTitle];
    // 设置作者
//    [ dict setObject: @"作者" forKey:MPMediaItemPropertyArtist ];
    // 设置专辑
    [ dict setObject: @"三爸育儿" forKey:MPMediaItemPropertyAlbumTitle ];
    // 流派
//    [ dict setObject:@"流派" forKey:MPMediaItemPropertyGenre ];
    // 设置总时长
    NSInteger time = self.duration.minute*60 + self.duration.second;
    [dict setObject:@(time) forKey:MPMediaItemPropertyPlaybackDuration];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

/**
 *  暂停或开始
 */
- (void)pause
{
    if (_isPlaying) {
        [super pause];

        [_displaylink invalidate];
        _displaylink = nil;
        _isPlaying = NO;
    }else{
        [super pause];

        if (!_displaylink) {
            _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
            [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
        _isPlaying = YES;
    }
}

/**
 *  停止
 */
- (void)stop{
    [super stop];

    [_displaylink invalidate];
    _displaylink = nil;
    _isPlaying = NO;
}

/**
 *  设置播放速率
 *
 *  @param rate 播放速率（0.5~2）
 */
- (void)setRate:(float)rate{
    _rate = rate;
    [self setPlayRate:rate];
}

/**
 *  更新播放进度
 */
- (void)updateProgress{
    [FloatTools manager].progressLayer.strokeEnd = self.currentTimePlayed.position;
    if ([_playerDelegate respondsToSelector:@selector(PD_updateProgressWithCurrentPosition:andEndPosition:)]) {
        [_playerDelegate PD_updateProgressWithCurrentPosition:self.currentTimePlayed andEndPosition:self.duration];
    }
}

/**
 *  播放的文件队列
 *
 *  @return 播放的文件队列
 */
- (NSMutableArray *)audioArray{
    if (!_audioArray) {
        _audioArray = [[NSMutableArray alloc] init];
    }
    return _audioArray;
}

//下一首
-(void)next{
    if (self.audioArray.count == 0) {
        NSLog(@"无歌曲");
        return;
    }
    _isPlaying = YES;
    
    [self stop];
    
    __weak typeof(self) wself = self;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.15*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"%lu",(unsigned long)wself.playMode);
        if (wself.playMode == kRandomPlayMode) {
            wself.currentItemIndex = arc4random() % wself.audioArray.count;
        }else if (wself.playMode == kOrderOfPlayMode){
            wself.currentItemIndex = (wself.currentItemIndex+1)%wself.audioArray.count;
        }else if (wself.playMode == kSingleCycleMode){
            
        }
        [wself playItemAtIndex:wself.currentItemIndex];
    });
}

-(void)previous{
    if (self.audioArray.count == 0) {
        NSLog(@"无歌曲");
        return;
    }
    _isPlaying = YES;

    [self stop];
    
    __weak typeof(self) wself = self;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.15*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        switch (wself.playMode) {
            case kRandomPlayMode:{
                wself.currentItemIndex = arc4random() % wself.audioArray.count;
            }break;
            case kOrderOfPlayMode:{
                if (wself.currentItemIndex == 0) {
                    wself.currentItemIndex = wself.audioArray.count - 1;
                }else{
                    wself.currentItemIndex --;
                }
            }break;
            case kSingleCycleMode:{
                
            }
        }
        [wself playItemAtIndex:wself.currentItemIndex];
    });
}

//获取缓存大小
- (CGFloat)calculateachesSize {
    
    float totalCacheSize = 0;
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[MusicManager defaultPlayer].configuration.cacheDirectory error:nil];
    for (NSString *file in fileArray) {
        if ([file hasPrefix:@"FSCache-"]) {
            
            NSString *filePath = [[MusicManager defaultPlayer].configuration.cacheDirectory stringByAppendingPathComponent:file];
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            unsigned long long length = [fileAttributes fileSize];
            float ff = length/1024.0/1024.0;
            totalCacheSize += ff;
        }
    }
    return totalCacheSize;
}

//清除音乐缓存
- (void)clearMusicCache{
    [[MusicManager defaultPlayer] expungeCache];
}

@end
