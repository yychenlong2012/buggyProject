//
//  BLEMusicPlayer1.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "BLEMusicPlayer.h"
#import "NSUserDefaults+SafeAccess.h"
#import "AVAResourceLoaderManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NetWorkStatus.h"
#import "NSString+AVLeanCloud.h"
#import "MusicViewModel.h"
#import "RecentPlayDataBase.h"

#define kPLAYERTYPEMODE @"kPLAYERTYPEMODE"
@interface BLEMusicPlayer()<ResourceLoaderManagerDelegate,AVAssetResourceLoaderDelegate>

@property (nonatomic ,assign) id timeObserver;

/* 以下为优化属性 */
@property (nonatomic ,strong) AVAResourceLoaderManager *resourceloader;
@property (nonatomic ,strong) NSURL *url;

@property (nonatomic ,strong) MPMoviePlayerController *movieController;
@property (nonatomic ,assign) MPMoviePlaybackState movieState;

@property (nonatomic ,strong) RecentPlayDataBase *recentPlayDataBase;   //最近播放数据库
@property (nonatomic ,assign) BOOL isRegister;        //是否注册监听了歌曲状态  在没有监听的情况下去移除监听会崩溃
@property (nonatomic ,strong) NSMutableArray<AVPlayerItem *> *musicItemCacheArray;  //每次切换下一首歌曲 都将上一首歌曲放入数组 以防还有对他的监听
@property (nonatomic ,assign) BOOL isNextMusic;       //是不是在播放另一首歌



@end

@implementation BLEMusicPlayer

- (void)dealloc{
    [self removeCurrentItemAddObservers];
    [self musicPlayerRemoveObserver];
}

+ (instancetype)shareManager{
    static BLEMusicPlayer *musicPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        musicPlayer = [[BLEMusicPlayer alloc] init];
    });
    return musicPlayer;
}

#pragma mark --- 基本配置类

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.playerType = [[NSUserDefaults standardUserDefaults] integerForKey:kPLAYERTYPEMODE];
        self.currentIndex = 0;
        self.currntMusicName = @"";
        self.isRegister = NO;
        self.isNextMusic = YES;
        self.musicItemCacheArray = [NSMutableArray array];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configLockScreenPlay) name:NSExtensionHostDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentPlayingTime)
                                                     name:NSExtensionHostWillResignActiveNotification object:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //后台播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self musicPlayerAddObserver];
        self.recentPlayDataBase = [[RecentPlayDataBase alloc] init];  //数据库
        
    }
    return self;
}

//- (void)musicPlayerwithURL:(NSURL *)url{
//    self.url = url;
//    @synchronized (self) {
//        [self removeCurrentItemAddObservers];
//        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
//        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:urlAsset];
////        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
//        [self.player replaceCurrentItemWithPlayerItem:item];
//        [self currentItemAddObservers];
//    }
//}

/* --------------------- 以下是优化方法 ---------------  */

- (void)reloadCurrentItemWithURL:(AVFile *)file{
  
    self.url = [NSURL URLWithString:file.url];
    @synchronized (self) {
        if (self.isPlaying) {
            self.isPlaying = NO;
            return;
        }
        [self removeCurrentItemAddObservers];   //崩溃过
        if ([file.url hasPrefix:@"https"]) {
            //        /* 有缓存播放缓存文件 */
//            NSString *cacheFilePath = [AVFileHandle cacheFileExistsWithURL:[NSURL fileURLWithPath:file.url]];  //如果传url过去 那么取不到正确的文件名
            NSString *cacheFilePath = [AVFileHandle downloadFileExistsWithName:file.name];
            NSLog(@"AVFile是否存在该文件 = %d 缓存文件是否存在 = %@",file.isDataAvailable,cacheFilePath);
            if (file.isDataAvailable || cacheFilePath) {
                /* 后台或者本地 */
                NSString *LeanCloudCacheFilePath = [AVFileHandle hardLinkFromUrl:file.localPath withExpand:file.pathExtension];
                NSURL *url = [NSURL fileURLWithPath:cacheFilePath ? cacheFilePath:LeanCloudCacheFilePath];
                AVURLAsset *asset = [AVURLAsset assetWithURL:url];
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [self.player replaceCurrentItemWithPlayerItem:item];
            }else{
                /* 没有缓存/后台也没有 播放网络文件(此方案为备选方案，需要定制)  无论有无网络都会走这里 */
                self.resourceloader = [[AVAResourceLoaderManager alloc] init];
                self.resourceloader.delegate = self;
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self.url originalSchemeURL] options:nil];
                [asset.resourceLoader setDelegate:self.resourceloader queue:dispatch_get_main_queue()];
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [self.player replaceCurrentItemWithPlayerItem:item];
                
                //查看本地有没有文件
//                NSString *cacheFilePath = [AVFileHandle cacheFileExistsWithName:file.name];
//                NSLog(@"----%@",cacheFilePath);
//                //下载音乐
//                [self downLoadMusic:file];
            }
        }else{
            NSString *downFilePath = [AVFileHandle loadFileExistsWithFileName:file.name];
            if (downFilePath) {
                NSURL *url = [NSURL fileURLWithPath:downFilePath];
                AVURLAsset *asset = [AVURLAsset assetWithURL:url];
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [self.player replaceCurrentItemWithPlayerItem:item];
                DLog(@"播放本地文件");
            }
        }
        [self currentItemAddObservers];
        _state = PlayerStateWaiting;
    }
}

// 改  添加缓存
- (void)reloadCurrentItemWithURL2:(AVFile *)file musicName:(NSString *)musicName{
  
    @synchronized (self) {
        if (self.isPlaying) {
            self.isPlaying = NO;
            return;
        }
        [self removeCurrentItemAddObservers];   //崩溃过
   
        if ([file.url hasPrefix:@"https"]) {
            
            //判断是否有缓存文件
            NSString *cacheFilePath = [AVFileHandle cacheFileExistsWithName:musicName];
            //判断是否有下载文件
            NSString *downloadFilePath = [AVFileHandle downloadFileExistsWithName:musicName];

            if (cacheFilePath) {    //有缓存 则播放
                
                NSURL *url = [NSURL fileURLWithPath:cacheFilePath];
                [self playMusicWithURL:url];
                [self currentItemAddObservers];
                _state = PlayerStateWaiting;
                [self play];
                
            }else if (downloadFilePath) {   //有下载文件 播放
                
                NSURL *url = [NSURL fileURLWithPath:downloadFilePath];
                [self playMusicWithURL:url];
                [self currentItemAddObservers];
                _state = PlayerStateWaiting;
                [self play];
                
            }else {   //都没有 下载文件
                [self downLoadMusic:file musicName:musicName];
            }
        }else{
            NSString *downloadFilePath = [AVFileHandle downloadFileExistsWithName:musicName];
            if (downloadFilePath == nil) {
                downloadFilePath = [AVFileHandle cacheFileExistsWithName:musicName];
            }
            if (downloadFilePath) {   //有下载文件 播放
                
                NSURL *url = [NSURL fileURLWithPath:downloadFilePath];
                [self playMusicWithURL:url];
                [self currentItemAddObservers];
                _state = PlayerStateWaiting;
                [self play];
            }
        }
    }
}



- (void)downLoadMusic:(AVFile *)file musicName:(NSString *)musicName{

    __weak typeof(self) wself = self;

    [MusicViewModel downLoadMusicToLocal2:file progress:^(NSInteger progress) {
        NSLog(@"歌曲下载===%ld",(long)progress);
    } success:^(BOOL success) {
        
        if (success) {     //下载成功
            
            NSString *fileName = musicName;
            if (fileName == nil) {
                fileName = file.name;
                if ([fileName containsString:@"兔小贝"]) {
                    fileName = [fileName substringFromIndex:8];
                }
            }
            if (![fileName containsString:@"mp3"]) {
                fileName = [NSString stringWithFormat:@"%@%@",fileName,@".mp3"];
            }

            // 将下载的文件的从LeanCloud的缓存中copy到指定下载的路径下
            [AVFileHandle loadCacheFile2WithFileName:fileName fromCachePath:file.localPath success:^(NSString *cacheAbsolutelyPath, BOOL finish) {
                DLog(@"是否成功 =  %d  %@",finish,cacheAbsolutelyPath);
                if (finish) {
                    NSURL *url = [NSURL fileURLWithPath:cacheAbsolutelyPath];
                    [wself playMusicWithURL:url];
                    [self currentItemAddObservers];
                    self->_state = PlayerStateWaiting;
                    [self play];
                }else{
                    NSLog(@"下载失败");
                }
                
            }];
        }else{
            NSLog(@"下载失败");
        }

    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"下载失败");
        }
    }];
}

-(void)playMusicWithURL:(NSURL *)url
{
    if (url == nil) {
        return;
    }

    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    //保存上一首歌曲的playerItem  这里定了40 太大了会占内存
    if (self.musicItemCacheArray.count >= 40) {
        [self.musicItemCacheArray removeObjectAtIndex:0];
        if (self.player.currentItem != nil) {
            [self.musicItemCacheArray addObject:self.player.currentItem];
        }
    }else{
        if (self.player.currentItem != nil) {
            [self.musicItemCacheArray addObject:self.player.currentItem];
        }
    }
    
    [self.player replaceCurrentItemWithPlayerItem:item];
}



- (void)stop{
    [super stop];
    if (self.state == PlayerStateStopped) {
        return;
    }
    [self.player pause];
    [self.resourceloader stopLoading];
//    [self removeCurrentItemAddObservers];
    self.resourceloader = nil;
//    self.player = nil;
    self.state = PlayerStateStopped;
}

#pragma mark - AVLoaderDelegate

- (void)loader:(AVAResourceLoaderManager *)loader cacheProgress:(CGFloat)progress{
    DLog(@" 经过优化的progress %f",progress);
}



#pragma mark - CacheFile

- (BOOL)currentItemCacheState{
    if ([self.url.absoluteString hasPrefix:@"https"]) {
        if (self.resourceloader) {
            return self.resourceloader.cacheFinished;
        }
        return YES;
    }
    return NO;
}

- (NSString *)currentItemCacheFilePath{
    
    if (![self currentItemCacheState]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@",[NSString cacheFolderPath],[NSString fileNameWithURL:self.url]];
}

+ (BOOL)clearCache{
    [AVFileHandle clearCache];
    return YES;
}

/* ---------------------- 以上是优化的方法 ---------------  */

- (void)setMusicList:(NSArray *)musicList andModelArray:(NSMutableArray *)modelArray{
    if (_musicList != nil) {  //先清空
        _musicList = nil;
    }
    _musicList = musicList;
    
    if (self.musicListModelArray != nil) {
        self.musicListModelArray = nil;
    }
    self.musicListModelArray = modelArray;
}

#pragma mark --- 添加Observer
- (void)musicPlayerAddObserver {
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}
//删除观察者
- (void)musicPlayerRemoveObserver {
    
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
}

- (void)currentItemAddObservers{
    NSKeyValueObservingOptions opations = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    // 查看播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:opations context:nil];
    // 查看加载进度
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:opations context:nil];
    // 监听音乐是否完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayDidFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    // 监听音乐是否跳跃
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayJumped) name:AVPlayerItemTimeJumpedNotification object:self.player.currentItem];
    // 监听时间进度
    __weak typeof(self) wself = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // TODO
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(wself.player.currentItem.duration);
        float progress = current/total;
        if (current) {
//            NSLog(@"\n 音乐加载的进度：%f \n 当前的时间:%f \n 总时间:%f" ,current/total,current,total);
            if (wself.delegate&&[wself.delegate respondsToSelector:@selector(updataPlayProgress:currentTime:totalTime:)]) {
                [wself.delegate updataPlayProgress:progress currentTime:current totalTime:total];
            }
        }
    }];
    self.isRegister = YES;
    self.isNextMusic = YES;
}

- (void)removeCurrentItemAddObservers{
    
    if (self.player.currentItem == nil) {
        return;
    }
    if (self.isRegister == NO) {  //没有添加监听就不用去除
        return;
    }
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [self.player removeTimeObserver:self.timeObserver];
    self.isRegister = NO;
}

#pragma mark --- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *item = (AVPlayerItem*)object;
    if ([keyPath isEqualToString:@"status"]) {
        switch ([change[@"new"] integerValue]) {
            case AVPlayerItemStatusReadyToPlay:
            {
                [self play];
                if ([self.delegate respondsToSelector:@selector(playerStartPlayWithPlayer:)]) {
                    [self.delegate playerStartPlayWithPlayer:self.player];
                }
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"播放失败");
                self.playing = NO;
                if ([self.delegate respondsToSelector:@selector(player:failure:)]) {
                    [self.delegate player:self.player failure:nil];
                }
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"出现未知的原因");
                self.playing = NO;
            }
                break;
            default:
                break;
        }
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray<NSValue *> *array = item.loadedTimeRanges;
//        NSLog(@"---缓冲的数组个数---%lu",(unsigned long)array.count);
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];  //本次缓冲的时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        float totalDuration = CMTimeGetSeconds(self.player.currentItem.asset.duration);
        float bufferProgerss = durationSeconds / totalDuration;
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSLog(@"\n %@ 音乐缓存的进度:%f \n 当前时间:%f \n 总的时间:%f",self.player.currentItem,bufferProgerss ,durationSeconds,totalBuffer);
        if ([self.delegate respondsToSelector:@selector(updataBufferProgress:)]) {
            [self.delegate updataBufferProgress:bufferProgerss];
        }
        
        //设置锁屏界面
        if (self.isNextMusic == YES) {
            //歌曲图片
            MusicListModel *model = self.musicListModelArray[self.currentIndex];
            AVFile *imageFile = model.musicImage;
            __weak typeof(self) wself = self;
            if (imageFile != nil && [imageFile isKindOfClass:[AVFile class]]) {
                
                [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    
                    if (data) {
                        wself.currentMusicImage = [UIImage imageWithData:data];
                        [self configLockScreenPlay:totalDuration];
                    }else{
                        wself.currentMusicImage = [UIImage imageNamed:@"精品儿歌"];
                        [self configLockScreenPlay:totalDuration];
                    }
                    
                }];
            }
            [self configLockScreenPlay:totalDuration];
        }
        
        self.isNextMusic = NO;
        
    }
    if ([keyPath isEqualToString:@"rate"]) {
        // 0~1 表示正在播放 ， 1 表示播放
        float rate = self.player.rate;
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:rateOfPlayer:)]) {
            [self.delegate player:self.player rateOfPlayer:rate];
        }
        if (rate == 0.0) {
            self.state = PlayerStatePaused;
        }else{
            self.state = PlayerStatePlaying;
        }
    }
    
    if ([keyPath isEqualToString:@"currentItem"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerCurrentItemOfPlayerChanged:)]) {
            [self.delegate playerCurrentItemOfPlayerChanged:self.player];
        }
    }
}
#pragma mark --- NSNotification
/* 当前歌曲播放完成 */
- (void)musicPlayDidFinished{
    // 需要自动播放下一首
    if (self.playerType == PLAYER_ORDER) {  // 注意点： 如果进入播放的最后一首歌曲，从新播放
        [self playerOrderSong];
    }
    if (self.playerType == PLAYER_RANDOM) { // 随机播放
        [self playerRandomSong];
    }
    if (self.playerType == PLAYER_REPEAT) { // 单曲重复播放
        [self playerCurentSongAgain];
    }
    
}

/* 从当前歌曲切换到另外一首 */
- (void)musicPlayJumped{
    NSLog(@"切换另外一首歌");
    
}

/* 配置锁屏界面 */
- (void)configLockScreenPlay:(NSInteger)duration{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.currentMusicImage) {
        
        //musicListModelArray
        // 初始化一个封面
        MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: self.currentMusicImage ];
        // 设置封面
        [ dict setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
    }
    
    // 设置标题
    [ dict setObject:self.currntMusicName forKey:MPMediaItemPropertyTitle ];
    
    // 设置作者
    //[ dict setObject: @"作者" forKey:MPMediaItemPropertyArtist ];
    
    // 设置专辑
    //[ dict setObject: @"唱片集" forKey:MPMediaItemPropertyAlbumTitle ];
    
    // 流派
    //[ dict setObject:@"流派" forKey:MPMediaItemPropertyGenre ];
    
    // 设置总时长
    [ dict setObject:@(duration) forKey:MPMediaItemPropertyPlaybackDuration ];
    
    [ [MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict ];
    
}

/* 在退出前保存当前的时间 */
- (void)saveCurrentPlayingTime{
    
    
}

#pragma mark --- 基本操作类
- (void)firstPlayer{
    // 将当前播放的顺序值添加传出去
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerCurrentItemIndex:)]) {   //设置标题并添加记录
        [self.delegate playerCurrentItemIndex:self.currentIndex];
    }
    
    //保存播放记录到本地  历史播放
    MusicListModel *model = self.musicListModelArray[self.currentIndex];
    self.currntMusicName = model.musicName;
    
    NSDictionary *dict = @{  @"musicName":(model.musicName == nil) ? @"" : model.musicName,
                            @"musicUrl":(model.musicFiles.url == nil) ? @"" : model.musicFiles.url
//                            @"musicImage":(model.musicImage.url == nil) ? @"" : model.musicImage.url
                         };
    [self.recentPlayDataBase addData:dict];    //添加数据库
    
    AVFile *file = (AVFile *)_musicList[self.currentIndex];
    //每次播放都将操作保存起来
//    NSTimeInterval time = CACurrentMediaTime();
    [self appendPlayingRecord:self.currntMusicName];
//    DLog(@"消耗的时间:%f",CACurrentMediaTime() - time);
    [self pause];
    [self reloadCurrentItemWithURL2:file musicName:model.musicName];
}

//播放方法
- (void)play{
    [super play];   //父类并没有实现具体功能
    
    if (self.player == nil) {
        return;
    }
    if (self.player.currentItem == nil) {
        return;
    }
    if (self.player.rate) {
        return;
    } else {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
            self.playing = YES;
        }
    }
}

//更新后台歌曲播放次数记录
-(void)appendPlayingRecord:(NSString *)name{
    //获取歌名
    if ([name containsString:@"兔小"]) {
        name = [name substringFromIndex:8];
    }
    if ([name containsString:@"mp3"]) {
        name = [name substringWithRange:NSMakeRange(0, name.length-4)];
    }
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist",[AVUser currentUser].username];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];

    //判断是否有网  保存响应头的点击记录
    if (![NetWorkStatus isNetworkEnvironment]) {
        //无网络则保存播放次数信息   每个用户都有一张属于自己的表格
        if (array == nil) {          //无对应的plist文件
            array = @[ @{@"musicName" : name,
                         @"playCount" : @"1"} ];
        }else{
            NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
            BOOL isExit = NO;    //是否存在
            for (NSDictionary *dict in temp) {
                NSString *musicName = dict[@"musicName"];
                if ([musicName isEqualToString:name]) {   //存在歌曲记录
                    //更新播放次数
                    isExit = YES;
                    NSString *playcount = dict[@"playCount"];
                    [dict setValue:[NSString stringWithFormat:@"%d",(playcount.intValue + 1)] forKey:@"playCount"];
                }
            }
            if (isExit == NO)
                [temp addObject:@{@"musicName":name , @"playCount" : @"1"}];//添加记录
            array = temp;
        }
        [array writeToFile:filePath atomically:YES];
        return;
    }else{   //有网络则上传点击信息
   
        //本地有记录则上传记录
        if (array.count>0){
            BOOL flag = NO;
            for (NSDictionary *dict in array) {
                NSString *musicName = dict[@"musicName"];
                NSString *playCount = dict[@"playCount"];
                if ([musicName isEqualToString:name]) {
                    flag = YES;
                    [self uploadPlayCountWithMusicName:musicName playCount:playCount.integerValue + 1];
                    continue;
                }
                [self uploadPlayCountWithMusicName:musicName playCount:playCount.integerValue];
            }
            if (flag == NO) {
                [self uploadPlayCountWithMusicName:name playCount:1];
            }
        }else{
            //直接上传本次操作
            [self uploadPlayCountWithMusicName:name playCount:1];
        }
        //清除本地记录
        NSArray *array = [NSArray array];
        [array writeToFile:filePath atomically:YES];
    }
}

- (void)uploadPlayCountWithMusicName:(NSString *)musicName playCount:(NSInteger)play_Count{
    //查询表中对应的记录
    AVQuery *query = [AVQuery queryWithClassName:@"Music_relate_user"];
    AVUser *user = [AVUser currentUser];
    [query whereKey:@"post_user" equalTo:user];
    [query whereKey:@"musicName" equalTo:musicName];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        NSLog(@"%@ object = %@",error,object);
        //error code 101 表示没有找到匹配项目
        //error = nil    表示找到了匹配项目
        @synchronized (self) {
            if (object) {    //如果存在记录  则更新播放次数
                NSInteger count = [[object objectForKey:@"play_count"] integerValue];   //保存的播放次数
                count = count + play_Count;
                [object setObject:@(count) forKey:@"play_count"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"上传操作 错误信息 = %@ 正确信息 = %d",error,succeeded);
                }];
            }else{
                
                if (error != nil && error.code == 101) {
                    NSLog(@"没有匹配的项目");
                    object = [AVObject objectWithClassName:@"Music_relate_user"];
                    [object setObject:user forKey:@"post_user"];
                    [object setObject:musicName forKey:@"musicName"];
                    [object setObject:@(play_Count) forKey:@"play_count"];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"上传操作 错误信息 = %@ 正确信息 = %d",error,succeeded);
                    }];
                }
            }
        }
    }];
}

- (void)pause{
    [super pause];
    if (self.player == nil) {
        return;
    }
    if (self.player.currentItem == nil) {
        return;
    }
    if (!self.player.rate) {
        return;
    } else {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
                [self.player pause];
                self.playing = NO;
        }
    }
}

- (void)next{
    //[super next];
    // 获得下一首的资源，从新给_audioPlayer.data属性赋值
    if (self.playerType == PLAYER_ORDER) {
        DLog(@"BLE -- 下一首");
        if (!_musicList) return;
        [self stop];
        @synchronized (self) {
            if (self.currentIndex<0 || self.currentIndex >= _musicList.count -1) {
                self.currentIndex = 0;
//                if (_musicList.count == 1) {
//                    [self firstPlayer];
//                }
            }else{
                self.currentIndex ++;   //musicPlayView 监听了这个属性  一旦这个属性值改变  musicPlayerView又会firstPlayer方法  所以会重复调用这个方法
            }
        }
        [self firstPlayer];
    }else{
        [self musicPlayDidFinished];
    }
}

- (void)previous{
    [super previous];
    // 获得上一首的资源，从新给_audioPlayer.data属性赋值
    DLog(@"BLE -- 上一首");
    if (!_musicList) return;
    [self stop];
    @synchronized (self) {
        if (self.currentIndex <= 0 || self.currentIndex > _musicList.count- 1) {
            self.currentIndex = _musicList.count - 1;
//            if (_musicList.count == 1) {
//                [self firstPlayer];
//            }
        }else{
            self.currentIndex --;
        }
    }
    [self firstPlayer];
}

/* 顺序播放 */
- (void)playerOrderSong{
    if (!_musicList) return;
    @synchronized (self) {
        if (self.currentIndex < 0 || self.currentIndex >= _musicList.count -1) {
            self.currentIndex = 0;
//            if (_musicList.count == 1) {
//                [self firstPlayer];
//            }
        }else{
            self.currentIndex ++;
        }
//        if (self.isBLEPlayerViewExit == NO) {
//            [self firstPlayer];
//        }
        [self firstPlayer];
    }
}

/* 随机播放 */
- (void)playerRandomSong{
    // 随机播放
    @synchronized (self) {
        NSLog(@"BLE -- 随机播放");
        self.currentIndex = arc4random()%(_musicList.count - 1);
        DLog(@"我是下标：ßß----------®%li",self.currentIndex);
        
//        if (self.isBLEPlayerViewExit == NO || _musicList.count == 1) {
//            [self firstPlayer];
//        }
        [self firstPlayer];
    }
}

/* 重复播放 */
- (void)playerCurentSongAgain{
    // 重复播放
    NSLog(@"BLE -- 重复播放");
    [self firstPlayer];
}

- (float)getSystomVolume{
    [super getSystomVolume];
    CGFloat volume = [NSUserDefaults floatForKey:MusicPlayerVolume];
    _player.volume = (volume == 0? 0.5 : volume); // 默认为一半的音量
    return _player.volume;
}

- (void)adjustVolumeOfplayer:(float)value{
    [super adjustVolumeOfplayer:value];
    [self.player setVolume:value];
}

- (void)selectTypeMode:(PLAYERTYPEMODE )typeMode{
    [super selectTypeMode:typeMode];
    self.playerType = typeMode;
    // 保存随机播放的模式,保存在后台
    [[NSUserDefaults standardUserDefaults] setInteger:typeMode forKey:kPLAYERTYPEMODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupCurrentTimeWithSilderValue:(CGFloat)value
                             completion:(void (^)(void))completion {
   
    __weak typeof(self) wself = self;
    CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
   
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        self.resourceloader.seekRequired = YES;
        [self.player pause];
        CMTime seekTime = CMTimeMake(value *duration, 1);
        [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (completion) {
                completion();
            }
            //如果当前状态为暂停播放则返回
            if (!self.playing) {
                return;
            }
            [wself.player play];
        }];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
}

- (AVPlayer *)player{
    
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}
@end
