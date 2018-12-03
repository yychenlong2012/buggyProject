//
//  BLEMusicPlayer1.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/16.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "BasePlayer.h"

typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateWaiting,
    PlayerStatePlaying,
    PlayerStatePaused,
    PlayerStateStopped,
    PlayerStateBuffering,
    PlayerStateError
};

@protocol BLEMusicPlayerDelegate <NSObject>

@optional
/**
 开始播放
 
 @param player 当前播放的管理者
 */
- (void)playerStartPlayWithPlayer:(id)player;

/**
 音乐播放的进度
 
 @param player 当前播放的管理者
 */
- (void)updataPlayProgress:(float)progress
               currentTime:(float)currentTime
                 totalTime:(float)totalTime;

/**
 音乐缓存的进度
 
 @param player 当前播放的管理者
 */
- (void)updataBufferProgress:(float)bufferProgress;

/**
 播放的rate(速率)改变
 
 @param player 当前播放的管理者
 @param changeRate 改变的rate
 */
- (void)player:(id)player rateOfPlayer:(float)rate;

/**
 当前的Item发生改变
 
 @param player 当前播放的管理者
 */
- (void)playerCurrentItemOfPlayerChanged:(id)player;

/**
 当前的Item在数组的位置

 @param index 数组的下标位置
 */
- (void)playerCurrentItemIndex:(NSInteger)index;


/**
 播放失败

 @param player 播放的AVPlayer
 @param error 错误原因
 */
- (void)player:(id)player failure:(NSError *)error;

@end

@interface BLEMusicPlayer : BasePlayer

@property (nonatomic ,weak) id<BLEMusicPlayerDelegate> delegate;

@property (nonatomic,assign) PLAYERTYPEMODE     playerType;   //顺序 循环 随机

@property (nonatomic,strong,readonly) NSArray   *musicList;

@property (nonatomic,strong) NSArray *musicPlayerList;

@property (nonatomic,assign) PLAYERFROMTYPE playerFromType;    //本地网络车载

@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,strong) NSString *currntMusicName;
    
@property (nonatomic,assign) BOOL  playing;

@property (nonatomic,assign) PlayerState state;

@property (nonatomic,assign,readonly) float progress;

@property (nonatomic,strong) NSMutableArray *musicListModelArray;   //歌曲模型数组

@property (nonatomic,assign) BOOL isBLEPlayerViewExit;      //因为BLEPlayerView（KVO）监听了这个界面的歌曲下标，当这个界面销毁后 就不能控制音乐播放了

@property (nonatomic ,strong) UIImage *currentMusicImage;

+ (instancetype)shareManager;

@property (nonatomic ,assign) BOOL isPlaying;/**<点击的是否正在播放的歌曲*/
@property (nonatomic ,strong) AVPlayer *player; /**<音频播放控件*/

/**
 第一次加载
 */
- (void)firstPlayer;

/**
 根据连接播放音乐
 
 @param url 音乐的连接，可以是本地音乐、网络音乐
 */
//- (void)musicPlayerwithURL:(NSURL *)url;

/**
 设置内部音乐列表

 @param musicList 音乐列表
 */
- (void)setMusicList:(NSArray *)musicList andModelArray:(NSArray *)modelArray;


/**
 手动调节播放进度（音乐播放的状态为 prepareToPlay）

 @param value 跳转的进度值（0-1）
 @param completion 回调
 */
- (void)setupCurrentTimeWithSilderValue:(CGFloat)value
                             completion:(void (^)(void))completion;


#pragma mark - 以下为优化方法
/**
 
 @param url
 */
- (void)reloadCurrentItemWithURL:(AVFile *)file;

//播放方法
- (void)play;
//暂停
- (void)pause;
//下一曲
- (void)next;
//上一曲
- (void)previous;

@end
