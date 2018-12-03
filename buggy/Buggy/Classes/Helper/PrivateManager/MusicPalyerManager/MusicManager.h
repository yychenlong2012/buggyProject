//
//  MusicManager.h
//  Buggy
//
//  Created by goat on 2018/1/19.
//  Copyright © 2018年 3Pomelos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FreeStreamer/FSAudioStream.h>
#define MUSICMANAGER [MusicManager defaultPlayer]

typedef NS_ENUM(NSUInteger, MusicPlayMode) {//播放模式
    kRandomPlayMode = 0,        //随机播放
    kSingleCycleMode = 1,       //单曲循环
    kOrderOfPlayMode = 2,       //顺序播放
};

typedef NS_ENUM(NSInteger, MusicType) {  //歌曲所属模块
    kLike = 1,           //收藏模块
    kDownload = 2,       //下载模块
    kAlbum = 3,          //专辑
    
    //场景
    kSenceSleep       = 4,         // 哄睡
    kSencePacify      = 5,         // 安抚
    kSenceChildsoon   = 6,         // 儿歌
    kSenceStory       = 7,         // 故事
};
@protocol PlayerDelegate <NSObject>
@optional
/**
 *  更新播放进度
 *  @param currentPosition  当前位置
 *  @param endPosition      结束位置（总时长）
 *  播放进度通过currentPosition.position获得，取值范围0-1
 *  缓存进度可以不断地在这个代理方法中调用如下代码
     float prebuffer = (float)self.player.prebufferedByteCount;
     float contentlength = (float)self.player.contentLength;
     if (contentlength>0) {
     self.progressView.progress = prebuffer/contentlength;
     }
 */
- (void)PD_updateProgressWithCurrentPosition:(FSStreamPosition)currentPosition andEndPosition:(FSStreamPosition)endPosition;
- (void)PD_startPlayNewMusic;  //开始播放一手新歌
- (void)PD_playCompletion;     //播放完毕
- (void)PD_playPause;          //暂停

@end


@interface MusicManager : FSAudioStream

@property (assign, nonatomic) BOOL isPlaying;        //是否为播放状态    供其他类使用
@property (strong, nonatomic) NSMutableArray<musicModel *> * audioArray;   //播放文件数组
@property (assign, nonatomic) float rate;                   //播放速率
@property (assign, nonatomic) MusicPlayMode playMode;        //播放模式
@property (assign, nonatomic) MusicType    currentMusicType; //当前播放的歌曲所属模块
@property (weak, nonatomic) id<PlayerDelegate> playerDelegate;

@property (assign, nonatomic) NSUInteger currentItemIndex;  //当前播放歌曲的序号
@property (strong, nonatomic) UIImage *currentMusicImage;   //当前播放音乐的专辑图片
@property (strong, nonatomic) NSString *currntMusicName;    //当前播放音乐的名字


+ (instancetype)defaultPlayer;                  //获得播放器单例
- (void)playItemAtIndex:(NSUInteger)itemIndex;  //播放文件队列中的指定文件
- (void)next;                                  //下一首
- (void)previous;                              //上一首
- (void)pause;                                 //歌曲播放时点击则为暂停  歌曲暂停时点击则为播放
- (CGFloat)calculateachesSize;                 //获取缓存大小
- (void)clearMusicCache;                       //清空缓存
//- (void)downloadMusicWithUrl:(NSURL *)url;
@end
