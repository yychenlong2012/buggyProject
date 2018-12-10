//
//  MusicPlayNewController.m
//  Buggy
//
//  Created by goat on 2018/4/16.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicPlayNewController.h"
#import "MusicManager.h"
#import "CLButton.h"
#import "CLImageView.h"
#import "MusicManager.h"
#import "NetWorkStatus.h"
#import "NSString+AVLoader.h"
#import "CALayer+PauseAimate.h"
#import "MusicActionTools.h"
#import "MusicListModel.h"
#import "NetWorkStatus.h"
#import "lrcScrollView.h"
#import "FloatTools.h"
#import "WNJsonModel.h"
#import "DeviceModel.h"
#import "BlueToothManager.h"

@interface MusicPlayNewController ()<PlayerDelegate,UIScrollViewDelegate>
@property (nonatomic,assign) Music_Play_Mode playMode; //歌曲播放顺序
@property (nonatomic,strong) NSString *musicBleName;  //音乐蓝牙名
@property (nonatomic,strong) CLButton *previou;       //上一首
@property (nonatomic,strong) CLButton *next;          //下一首
@property (nonatomic,strong) UIButton *connectBleBtn; //连接蓝牙

@property (assign,nonatomic) BOOL isTouch;                   //是否按住了进度条
@property (strong,nonatomic) UISlider *progress;             //播放进度条
@property (strong,nonatomic) UIProgressView *cacheProgress;   //缓存进度条
@property (strong,nonatomic) UILabel *leftTime;              //时间label
@property (strong,nonatomic) UILabel *rightTime;
@property (strong,nonatomic) UIImageView *baseImage;          //灰色底座
@property (strong,nonatomic) UIImageView *blackImage;         //黑胶唱片
@property (strong,nonatomic) UIImageView *themeImage;         //中间主题图片
@property (strong,nonatomic) UILabel *downloadProgress;
@property (strong,nonatomic) CLImageView *downloadImage;
@property (strong,nonatomic) UILabel *musicName;
@property (strong,nonatomic) UIView *volumeView;              //音量调节
@property (strong,nonatomic) UISlider *volumeSlider;          //音量调节滑块
@property (strong,nonatomic) CLImageView *like;               //收藏按钮
@property (strong,nonatomic) UIButton *beginOrPause;          //开始或暂停
@property (strong,nonatomic) lrcScrollView *lrcView;          //歌词view
@end

@implementation MusicPlayNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    [self setupMusicPlayView];
    MUSICMANAGER.playerDelegate = self;
    self.musicBleName = @"设备蓝牙";   //默认值
    if (MUSICMANAGER.audioArray != nil && MUSICMANAGER.audioArray.count > 0 && MUSICMANAGER.currentItemIndex < MUSICMANAGER.audioArray.count) {
        musicModel *model = MUSICMANAGER.audioArray[MUSICMANAGER.currentItemIndex];
        if (model) {
            if (model.musicid != 0) {
                [self.lrcView setLrcName:[NSString stringWithFormat:@"%ld",model.musicid]];
            }
        }
    }
    [self requestDeviceData];
}

//请求已绑定的推车信息
-(void)requestDeviceData{
    if (NETWorkAPI.deviceArray.count > 0) {
        //判断音乐蓝牙名
        if (BLEMANAGER.currentPeripheral == nil) {   //蓝牙未连接则选取最新的已绑定推车作为音乐蓝牙标识
            DeviceModel *model = NETWorkAPI.deviceArray.firstObject;
            [self musicBleNameWith:model];
        }else{  //否则选取已连接的蓝牙作为标识
            for (DeviceModel *model in NETWorkAPI.deviceArray) {
                if ([BLEMANAGER.currentPeripheral.identifier.UUIDString isEqualToString:model.bluetoothuuid]) {
                    [self musicBleNameWith:model];
                    return ;
                }
            }
        }
    }
}

-(void)musicBleNameWith:(DeviceModel *)model{
    if ([model.deviceidentifier isKindOfClass:[NSNull class]]) { //无型号数据
        self.musicBleName = @"3Pomelos_A3";
    }else{ //有型号数据
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [cachePath stringByAppendingPathComponent:@"deviceTypeList.plist"];
        NSArray *deviceTypeArray = [NSArray arrayWithContentsOfFile:filePath];
        for (NSDictionary *dict in deviceTypeArray) {
            if ([dict[@"deviceIdentifier"] isEqualToString:model.deviceidentifier]) {  //型号相同
                self.musicBleName = dict[@"musicBluetoothName"];
            }
        }
    }
}

#pragma mark - target调用
/**<下一首歌曲*/
- (void)nextSong:(UIButton *)sender{
    //防止短时间连续点击
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(playNext) object:_next];
    [self performSelector:@selector(playNext) withObject:self.next afterDelay:0.15f];
}
-(void)playNext{
    [self removeRotation];//重新开始动画
    self.leftTime.text = @"00.00";
    self.rightTime.text = @"00.00";
    self.cacheProgress.progress = 0;
    [self.beginOrPause setImage:ImageNamed(@"播放") forState:UIControlStateNormal];
    [MUSICMANAGER next];
}
/**<上一首歌曲*/
- (void)previouSong:(UIButton *)sender{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(playPrevious) object:_previou];
    [self performSelector:@selector(playPrevious) withObject:self.previou afterDelay:0.15f];
}
-(void)playPrevious{
    [self removeRotation];//重新开始动画
    self.leftTime.text = @"00.00";
    self.rightTime.text = @"00.00";
    self.cacheProgress.progress = 0;
    [self.beginOrPause setImage:ImageNamed(@"播放") forState:UIControlStateNormal];
    [MUSICMANAGER previous];
}
#pragma mark - PlayerDelegate
- (void)PD_updateProgressWithCurrentPosition:(FSStreamPosition)currentPosition andEndPosition:(FSStreamPosition)endPosition{
    self.leftTime.text = [NSString stringWithFormat:@"%02u:%02u",currentPosition.minute,currentPosition.second];
    self.rightTime.text = [NSString stringWithFormat:@"%02u:%02u",endPosition.minute,endPosition.second];
    if (self.isTouch == NO) {
        self.progress.value = currentPosition.position;
    }
    
    //缓存进度
    float prebuffer = (float)MUSICMANAGER.prebufferedByteCount;
    float contentlength = (float)MUSICMANAGER.contentLength;
    if (contentlength>0) {
        self.cacheProgress.progress = prebuffer/contentlength;
    }
    
    //更新当前播放时间
    self.lrcView.currentTime = currentPosition.playbackTimeInSeconds;
}
- (void)PD_startPlayNewMusic{  //开始播放一首新歌
    [self setMusicInfo];
    
    //设置歌词
    musicModel *model = MUSICMANAGER.audioArray[MUSICMANAGER.currentItemIndex];
    if (model.musicid != 0) {
        [self.lrcView setLrcName:[NSString stringWithFormat:@"%ld",model.musicid]];
    }
}
- (void)PD_playCompletion{   //播放完毕
    self.cacheProgress.progress = 0;
}

#pragma mark - setupUI
//设置音乐播放界面
-(void)setupMusicPlayView{
    __weak typeof(self) wself = self;
    //灰色底座
    self.baseImage = [[UIImageView alloc] initWithImage:ImageNamed(@"底座")];
    self.baseImage.frame = CGRectMake((ScreenWidth-RealWidth(286.5))/2, navigationH, RealWidth(286.5), RealWidth(286.5));
    [self.view addSubview:self.baseImage];
    //黑色胶片
    self.blackImage = [[UIImageView alloc] initWithImage:ImageNamed(@"黑胶唱片")];
    self.blackImage.frame = CGRectMake(0, 0, RealWidth(258), RealWidth(258));
    self.blackImage.center = self.baseImage.center;
    [self.view addSubview:self.blackImage];
    //主题图片
    self.themeImage = [[UIImageView alloc] initWithImage:ImageNamed(@"播放界面占位")];
    self.themeImage.frame = CGRectMake(0, 0, RealWidth(146), RealWidth(146));
    self.themeImage.center = self.blackImage.center;
    CAShapeLayer *shape = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.themeImage.bounds];
    shape.path = path.CGPath;
    self.themeImage.layer.mask = shape;
    [self.view addSubview:self.themeImage];
    [self beginRotation];
    //标题
    self.musicName = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-RealWidth(250))/2, self.baseImage.bottom+25, RealWidth(250), RealWidth(27))];
    self.musicName.textAlignment = NSTextAlignmentCenter;
    self.musicName.font = [UIFont systemFontOfSize:19];
    [self.view addSubview:self.musicName];
   
    //开始或暂停
    UIButton *startOrEnd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, RealWidth(72.5), RealWidth(72.5))];
    startOrEnd.centerX = ScreenWidth/2;
    startOrEnd.bottom = ScreenHeight - bottomSafeH - RealWidth(35);
    [startOrEnd addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [MUSICMANAGER pause];
        [wself setPlayingStatus];
    }];
    [self.view addSubview:startOrEnd];
    self.beginOrPause = startOrEnd;
    [self setPlayingStatus];
    
    //上一首
    self.previou = [[CLButton alloc] initWithFrame:CGRectMake(startOrEnd.left-RealWidth(68), 0, RealWidth(22), RealWidth(18.5))];
    self.previou.centerY = startOrEnd.centerY;
    self.previou.extraWidth = 15;
    [self.previou addTarget:self action:@selector(previouSong:) forControlEvents:UIControlEventTouchUpInside];
    [self.previou setImage:ImageNamed(@"上一首") forState:UIControlStateNormal];
    [self.view addSubview:self.previou];
    //下一首
    self.next = [[CLButton alloc] initWithFrame:CGRectMake(startOrEnd.right+RealWidth(46), 0, RealWidth(22), RealWidth(18.5))];
    self.next.centerY = startOrEnd.centerY;
    self.next.extraWidth = 15;
    [self.next addTarget:self action:@selector(nextSong:) forControlEvents:UIControlEventTouchUpInside];
    [self.next setImage:ImageNamed(@"下一首") forState:UIControlStateNormal];
    [self.view addSubview:self.next];
    
    //进度条背景
    UIProgressView *bgView = [[UIProgressView alloc] initWithFrame:CGRectMake((ScreenWidth-RealWidth(200))/2 + RealWidth(5), 0, RealWidth(190), RealWidth(20))];
    bgView.progressTintColor = COLOR_HEXSTRING(@"#F1F1F1");
    bgView.progress = 1;
    [self.view addSubview:bgView];
    //音乐缓存进度
    self.cacheProgress = [[UIProgressView alloc] initWithFrame:CGRectMake((ScreenWidth-RealWidth(200))/2 + RealWidth(5), 0, RealWidth(190), RealWidth(20))];
    self.cacheProgress.progressTintColor = COLOR_HEXSTRING(@"#F8DDE4");
    self.cacheProgress.progress = 0;
    self.cacheProgress.backgroundColor = kClearColor;
    self.cacheProgress.trackTintColor = kClearColor;
    [self.view addSubview:self.cacheProgress];
    // 音乐播放进度
    UISlider *playerSlider = [[UISlider alloc] init];
    playerSlider.frame = CGRectMake((ScreenWidth-RealWidth(200))/2, 0, RealWidth(200), RealWidth(20));
    playerSlider.backgroundColor = [UIColor whiteColor];
    playerSlider.value = 0;
    playerSlider.minimumValue = 0.0f;
    playerSlider.maximumValue = 1.0f;
    playerSlider.minimumTrackTintColor = COLOR_HEXSTRING(@"#F2818F");
    playerSlider.maximumTrackTintColor = kClearColor;
    playerSlider.backgroundColor = kClearColor;
    [playerSlider setThumbImage:ImageNamed(@"滑动按钮") forState:UIControlStateNormal];
    [self.view addSubview:playerSlider];
    playerSlider.continuous = NO;   //手指离开时置灰调用一次valueChange
    [playerSlider addTarget:self action:@selector(ProgressTouchOutSide) forControlEvents:UIControlEventValueChanged];
    [playerSlider addTarget:self action:@selector(progressTouchDown) forControlEvents:UIControlEventTouchDown];
    playerSlider.bottom = startOrEnd.top - RealWidth(30);
    self.progress = playerSlider;
    bgView.centerY = playerSlider.centerY;
    self.cacheProgress.centerY = playerSlider.centerY;
    // 左边的时间
    self.leftTime = [Factory labelWithFrame:CGRectMake(playerSlider.left - RealWidth(12.5)-ScreenWidth/6, 0, ScreenWidth/6, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) text:@"00:00" textColor:COLOR_HEXSTRING(@"#AAAAAA") onView:self.view textAlignment:NSTextAlignmentRight];
    self.leftTime.centerY = playerSlider.centerY;
    // 右边的时间
    self.rightTime = [Factory labelWithFrame:CGRectMake(playerSlider.right+RealWidth(12.5), 0, ScreenWidth/6, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(11 * _MAIN_RATIO_375) text:@"00:00" textColor:COLOR_HEXSTRING(@"#AAAAAA") onView:self.view textAlignment:NSTextAlignmentLeft];
    self.rightTime.centerY = playerSlider.centerY;
    
    CGFloat width = (ScreenWidth - RealWidth(110) - RealWidth(96))/3;
    //选择模式
    CLImageView *selectType = [[CLImageView alloc] init];
    NSString *mode = KUserDefualt_Get(@"playMode");
    if (mode == nil || [mode isEqualToString:@"0"]) {
        selectType.image = ImageNamed(@"顺序播放");
        MUSICMANAGER.playMode = kOrderOfPlayMode;
    }else if ([mode isEqualToString:@"1"]){
        selectType.image = ImageNamed(@"随机播放");
        MUSICMANAGER.playMode = kRandomPlayMode;
    }else if ([mode isEqualToString:@"2"]){
        selectType.image = ImageNamed(@"单曲循环");
        MUSICMANAGER.playMode = kSingleCycleMode;
    }
    selectType.frame = CGRectMake(RealWidth(55), 0, RealWidth(24), RealWidth(24));
    selectType.bottom = playerSlider.top - RealWidth(20);
    selectType.userInteractionEnabled = YES;
    __weak typeof(selectType) weakSelect = selectType;
    [selectType addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSString *message = nil;
        switch (wself.playMode) {
            case kOrderMode:{
                wself.playMode = kRandomMode;
                message = NSLocalizedString(@"随机播放", nil);
                weakSelect.image = ImageNamed(@"随机播放");
                MUSICMANAGER.playMode = kRandomPlayMode;
                KUserDefualt_Set(@"1", @"playMode");
            }break;
            case kRandomMode:{
                wself.playMode = kSingelMode;
                message = NSLocalizedString(@"单曲循环", nil);
                weakSelect.image = ImageNamed(@"单曲循环");
                MUSICMANAGER.playMode = kSingleCycleMode;
                KUserDefualt_Set(@"2", @"playMode");
            }break;
            case kSingelMode:{
                wself.playMode = kOrderMode;
                message = NSLocalizedString(@"顺序播放", nil);
                weakSelect.image = ImageNamed(@"顺序播放");
                MUSICMANAGER.playMode = kOrderOfPlayMode;
                KUserDefualt_Set(@"0", @"playMode");
            }
        }
        [AYMessage show:message onView:kWindow autoHidden:YES];
    }];
    [self.view addSubview:selectType];
    //下载
    CLImageView *download = [[CLImageView alloc] init];
    download.image = ImageNamed(@"下载_未下载");
    download.frame = CGRectMake(selectType.right+width, selectType.top, RealWidth(24), RealWidth(24));
    download.userInteractionEnabled = YES;
    __weak typeof(download) weakDownload = download;
    [download addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSData *imageData1 = UIImagePNGRepresentation(weakDownload.image);
        NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"下载_未下载"]);
        if ([imageData1 isEqualToData:imageData2]){
            musicModel *model = MUSICMANAGER.audioArray[MUSICMANAGER.currentItemIndex];
            [MusicActionTools downLoadMusic:model
                progress:^(NSInteger progress) {
                    weakDownload.hidden = YES;
                    wself.downloadProgress.hidden = NO;
                    wself.downloadProgress.text = [NSString stringWithFormat:@"%ld%%",(long)progress];
                    NSLog(@"%@",[NSString stringWithFormat:@"%ld%%",(long)progress]);
                } success:^{
                    weakDownload.hidden = NO;
                    weakDownload.image = ImageNamed(@"下载_已下载");
                    wself.downloadProgress.hidden = YES;
                } failure:^(NSError *error) {
                    weakDownload.hidden = NO;
                    wself.downloadProgress.hidden = YES;
            }];
        }
    }];
    [self.view addSubview:download];
    self.downloadImage = download;
    //下载进度
    UILabel *downloadProgress = [[UILabel alloc] init];
    downloadProgress.textAlignment = NSTextAlignmentCenter;
    downloadProgress.textColor = COLOR_HEXSTRING(@"#F47686");
    downloadProgress.hidden = YES;
    downloadProgress.font = [UIFont systemFontOfSize:15];
    downloadProgress.frame = CGRectMake(selectType.right+width, selectType.top, RealWidth(40), RealWidth(24));
    [self.view addSubview:downloadProgress];
    self.downloadProgress = downloadProgress;
    //喜欢
    self.like = [[CLImageView alloc] init];
    self.like.image = ImageNamed(@"未收藏");
    self.like.frame = CGRectMake(download.right+width, selectType.top, RealWidth(24), RealWidth(24));
    self.like.userInteractionEnabled = YES;
    [self.like addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if ([NetWorkStatus isNetworkEnvironment]) {
            NSData *imageData1 = UIImagePNGRepresentation(wself.like.image);
            NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"未收藏"]);
            if ([imageData1 isEqualToData:imageData2]){
                [MusicActionTools babyLike:YES];
                wself.like.image = ImageNamed(@"已收藏");
                
                CABasicAnimation *anim = [CABasicAnimation animation];
                anim.keyPath = @"transform.scale";
                anim.fromValue = @1;
                anim.toValue = @3;
                anim.duration = 0.25;
                CABasicAnimation *anim2 = [CABasicAnimation animation];
                anim2.keyPath = @"opacity";
                anim2.fromValue = @1.0;
                anim2.toValue = @0;
                anim2.duration = 0.25;
                CAAnimationGroup *group = [CAAnimationGroup animation];
                group.duration = 0.25;
                group.animations = @[anim,anim2];
                [wself.like.layer addAnimation:group forKey:nil];
            }else{
                [MusicActionTools babyLike:NO];
                wself.like.image = ImageNamed(@"未收藏");
            }
        }
    }];
    [self.view addSubview:self.like];
    //音量
    CLImageView *volume = [[CLImageView alloc] init];
    volume.image = ImageNamed(@"音量调节_Normal");
    volume.frame = CGRectMake(self.like.right+width, selectType.top, RealWidth(24), RealWidth(24));
    volume.userInteractionEnabled = YES;
    [volume addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        if (wself.volumeView.hidden) {
            wself.volumeView.hidden = NO;
        }else{
            wself.volumeView.hidden = YES;
        }
    }];
    [self.view addSubview:volume];
    
    //lrc歌词view
    self.lrcView = [[lrcScrollView alloc] init];
    self.lrcView.pagingEnabled = YES;
    self.lrcView.showsHorizontalScrollIndicator = NO;
    self.lrcView.frame = CGRectMake(0, self.baseImage.top, ScreenWidth, selectType.top-self.baseImage.top-30);
    self.lrcView.contentSize = CGSizeMake(ScreenWidth*2, 0);
    self.lrcView.backgroundColor = kClearColor;
    self.lrcView.delegate = self;
    [self.view addSubview:self.lrcView];
    
    // 音量调节
    self.volumeView = [self setVolumeView];
    self.volumeView.hidden = YES;
    [self.view addSubview:self.volumeView];
    self.volumeView.centerX = volume.centerX;
    self.volumeView.bottom = volume.top;
}

- (UIView *)setVolumeView{
    UIView *view = [Factory viewWithFrame:CGRectMake(0, 0, 32 * _MAIN_RATIO_375, 160 * _MAIN_RATIO_375) bgColor:nil onView:self.view];
    [Factory imageViewWithFrame:CGRectMake(0, 0, 32 * _MAIN_RATIO_375, 160 * _MAIN_RATIO_375) image:ImageNamed(@"音量调节槽") onView:view];
    // 音量进度条
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, (160 - 31) * _MAIN_RATIO_375, 15)];
    CGFloat volumeNum = [KUserDefualt_Get(@"musicVolume") floatValue];
    if (volumeNum == 0) {
        volumeNum = 0.3;
        KUserDefualt_Set(@(0.3), @"musicVolume");
    }
    MUSICMANAGER.volume = volumeNum;
    slider.value = MUSICMANAGER.volume;
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    slider.continuous = YES;
    slider.tintColor = COLOR_HEXSTRING(@"#F5909C");
    [slider setThumbImage:ImageNamed(@"音量调节按钮") forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(sliderVolumeSwipe:) forControlEvents:UIControlEventValueChanged];
    CGAffineTransform rotation = CGAffineTransformMakeRotation(4.71238899);
    [slider setTransform:rotation];
    slider.centerX = 16 * _MAIN_RATIO_375;
    slider.top = 15.5 * _MAIN_RATIO_375;
    self.volumeSlider = slider;
    [view addSubview:slider];
    return view;
}
- (void)sliderVolumeSwipe:(UISlider *)slider{
    MUSICMANAGER.volume = slider.value;
    KUserDefualt_Set(@(slider.value), @"musicVolume");  //本地化音量
}
//进度条拖拽
-(void)ProgressTouchOutSide{
    FSStreamPosition position = {0};
    position.position = self.progress.value;
    [MUSICMANAGER seekToPosition:position];     //取值范围0 - 1
    self.isTouch = NO;
}
-(void)progressTouchDown{
    self.isTouch = YES;
}

//开始旋转动画
- (void)beginRotation{
    [_themeImage.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 25;
    animation.keyPath = @"transform.rotation.z";
    animation.repeatCount = NSIntegerMax;
    animation.removedOnCompletion = NO;
    [_themeImage.layer addAnimation:animation forKey:@"rotation"];
}
//初始化动画
- (void)removeRotation{
    [_themeImage.layer resumeAnimate];
    [_themeImage.layer removeAllAnimations];
    [self beginRotation];
}
//初始化界面歌曲信息
- (void)setMusicInfo{
    __weak typeof(self) wself = self;
    if (MUSICMANAGER.audioArray.count > 0) {
        musicModel *model = MUSICMANAGER.audioArray[MUSICMANAGER.currentItemIndex];
        //设置下载按钮图片
        if ([MusicActionTools isMusicDownloaded:model]) {
            wself.downloadImage.image = ImageNamed(@"下载_已下载");
        }else{
            wself.downloadImage.image = ImageNamed(@"下载_未下载");
        }
        
        //设置歌名
        self.musicName.text = model.musicname;
        //设置是否收藏
        [MusicActionTools isLiked:model.musicname withBlock:^(BOOL isLiked) {
            if (isLiked) {
                wself.like.image = ImageNamed(@"已收藏");
            }else{
                wself.like.image = ImageNamed(@"未收藏");
            }
        }];
        //设置封面图片
        if (MUSICMANAGER.currentMusicImage == nil) {
            self.themeImage.image = ImageNamed(@"播放界面占位");
        }else{
            self.themeImage.image = MUSICMANAGER.currentMusicImage;;
        }
    }
}
//初始化播放状态
-(void)setPlayingStatus{
    if (MUSICMANAGER.isPlaying) {
        [self.beginOrPause setImage:ImageNamed(@"播放") forState:UIControlStateNormal];
        [self.themeImage.layer resumeAnimate];
    }else{
        [self.beginOrPause setImage:ImageNamed(@"暂停") forState:UIControlStateNormal];
        [self.themeImage.layer pauseAnimate];
    }
}
#pragma mark - scrollviewdelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat alpha = 1 - scrollView.contentOffset.x/ScreenWidth;
    
    self.baseImage.alpha = alpha;
    self.blackImage.alpha = alpha;
    self.themeImage.alpha = alpha;
    self.musicName.alpha = alpha;
    
    //隐藏音量调节
    self.volumeView.hidden = YES;
}
#pragma mark - 生命周期
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //设置右边按钮动画
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"transform.scale";
    anim.duration = 0.3;
    anim.fromValue = @1.0;
    anim.toValue = @1.4;
    anim.repeatCount = 1;
    [self.connectBleBtn.imageView.layer addAnimation:anim forKey:nil];
    
    //初始化歌曲界面信息
    [self setMusicInfo];
    [self setPlayingStatus];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [Relocate dismissMusicRelocateView];
    [[FloatTools manager] dismissMusicRelocateView];
    [self chechoutNetworkStatus];  //检查网络 判断是否播放音乐
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [Relocate showMusicRelocateView];
    [[FloatTools manager] showMusicRelocateView];
}

/* 判断是否处于wifi状态 */
- (void)chechoutNetworkStatus{
    if ([NetWorkStatus isNetworkEnvironment]) {   //是否有网
        if (![NetWorkStatus isWifiNetworkEnvironment]){    //非WiFi环境
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示",nil) message:NSLocalizedString(@"你当前处于非wifi网络状态，为节省您的流量，请慎重选择！",nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDestructive handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    [AVFile clearAllCachedFiles];
    //清除音乐缓存
    [MUSICMANAGER clearMusicCache];
}
-(void)dealloc{
    
}

#pragma mark - 供外部调用
//暂停或播放
-(void)musicPlayerPauseOrPlay{
    if (MUSICMANAGER.isPlaying) {
        [self.beginOrPause setImage:ImageNamed(@"播放") forState:UIControlStateNormal];
        [self.themeImage.layer resumeAnimate];
    }else{
        [self.beginOrPause setImage:ImageNamed(@"暂停") forState:UIControlStateNormal];
        [self.themeImage.layer pauseAnimate];
    }
}
#pragma mark - 自定义导航栏
- (void)setupNav{
    CLImageView *backimage = [[CLImageView alloc] init];
    backimage.image = ImageNamed(@"音乐返回");
    backimage.frame = CGRectMake(20, statusBarH == 20? 25:44, 21, 21);
    backimage.userInteractionEnabled = YES;
    __weak typeof(self) wself = self;
    [backimage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [wself.navigationController popViewControllerAnimated:YES];
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.view addSubview:backimage];

    //蓝牙音响连接按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"蓝牙播放"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"蓝牙播放"] forState:UIControlStateFocused];
    btn.frame = CGRectMake(ScreenWidth - 50, statusBarH == 20? 25 : 44, 30, 30);
    [btn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        //先判断蓝牙是否开启
        NSString *message;
        if (BLEMANAGER.centralManager.state == CBManagerStatePoweredOn) {
            message = [NSString stringWithFormat:@"请到蓝牙列表连接%@",self.musicBleName];
        }else{
            message = [NSString stringWithFormat:@"请打开蓝牙 并连接%@",self.musicBleName];
        }
        //alert
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示",nil) message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"我知道了",nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
            //跳转到系统设置界面连接蓝牙
//            NSString *version = [UIDevice currentDevice].systemVersion;
//            if (version.doubleValue >= 10.0) {
//                NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x41,0x70,0x70,0x2d,0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x42,0x6c,0x75,0x65,0x74,0x6f,0x6f,0x74,0x68} length:24];
//                NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
//                NSURL *url = [NSURL URLWithString:string];
//                //A.p.p-P.r.e.f.s:r.o.o.t=B.l.u.e.t.o.o.t.h
//                if (url != nil) {
//                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
//                        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
//                    }
//                }
//
//            }else{
//                NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x70,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x42,0x6c,0x75,0x65,0x74,0x6f,0x6f,0x74,0x68} length:20];
//
//                NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
//                NSURL *url = [NSURL URLWithString:string];
//
//                if (url != nil) {
//                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
//                        [[UIApplication sharedApplication]openURL:url];
//                    }
//                }
//            }
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil]];
        [wself presentViewController:alertController animated:YES completion:nil];
    }];
    [self.view addSubview:btn];
    self.connectBleBtn = btn;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, btn.frame.origin.y + 30, 60, 25)];
    label.text = NSLocalizedString(@"连接音箱", nil);
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:label];
}

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}
@end
