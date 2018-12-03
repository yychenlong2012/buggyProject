//
//  MusicListCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicListCell.h"
#import "NSString+AVLeanCloud.h"
#import "DownLoadDataBase.h"
#import "CalendarHelper.h"
#import "NetWorkStatus.h"

#define UNSELECT_FONT 16
#define SELECT_FONT 18

@interface MusicListCell ()

@property (nonatomic ,strong) UILabel *serialNumberLB; // 序列号

@property (nonatomic ,strong) WaveView *waveView;      // 播放动画

@property (nonatomic ,strong) UILabel *musicNameLB;    // 音乐名称

@property (nonatomic ,strong) UILabel *progressLB;     // 音乐状态（0：未下载  1、已下载）

@property (nonatomic ,strong) UILabel *percentageLB;   // 下载的进度

@end


@implementation MusicListCell{
    
    UIView *_bottomLine;
    UIButton *_loadBT;
    DownLoadDataBase *_downLoadDB;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
//LAZY LOADINGß
- (WaveView *)waveView{
    if (!_waveView) {
        _waveView = [[WaveView alloc] initWithStaticAnimationFrame:CGRectMake(0, 0, 60* _MAIN_RATIO_375, 52.5)];
        _waveView.hidden = YES;
    }
    return _waveView;
}
//初始化UI
- (void)setupUI{
    
    // 音乐序列号
    self.serialNumberLB = [Factory labelWithFrame:CGRectZero font:FONT_DEFAULT_Light(17) text:@"1" textColor:COLOR_HEXSTRING(@"#666666") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    self.serialNumberLB.frame = CGRectMake(0, 0, 60 * _MAIN_RATIO_375, 52.5);
    
    // 音乐播放动画
    [self.contentView addSubview:self.waveView];
    
    // 音乐名称
    self.musicNameLB = [Factory labelWithFrame:CGRectZero font:FONT_DEFAULT_Light(16) text:@"宝宝音乐" textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    self.musicNameLB.frame = CGRectMake(0, 0, ScreenWidth/2, 25);
    self.musicNameLB.centerY = MusicListCellHeight / 2;
    self.musicNameLB.left = 60 * _MAIN_RATIO_375;
    
    // 进度值
    _progressLB = [Factory labelWithFrame:CGRectMake(0, 0, 50, MusicListCellHeight - 0.5) font:FONT_DEFAULT_Light(15) text:nil textColor:COLOR_HEXSTRING(@"#F47686") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    _progressLB.right = ScreenWidth - 10 * _MAIN_RATIO_375;
    _progressLB.hidden = YES;
    
    // 下载图标
    _loadBT = [Factory buttonWithCenter:CGPointZero withImage:ImageNamed(@"未下载") click:nil onView:self.contentView];
    _loadBT.centerY = MusicListCellHeight / 2;
    _loadBT.centerX = ScreenWidth - 36 * _MAIN_RATIO_375;
    [_loadBT addTarget:self action:@selector(downLoad:) forControlEvents:UIControlEventTouchUpInside];
    
    // 底部横线
    _bottomLine = [Factory viewWithFrame:CGRectZero bgColor:COLOR_HEXSTRING(@"#D5D5D5") onView:self.contentView];
    _bottomLine.frame = CGRectMake(60 * _MAIN_RATIO_375, 0, ScreenWidth - 60 * _MAIN_RATIO_375, 0.5);
    _bottomLine.bottom = MusicListCellHeight - 0.5;
}

- (void)setModel:(MusicListModel *)model{
    _model = model;
    self.musicNameLB.text = model.musicName;
    self.serialNumberLB.text = [NSString stringWithFormat:@"%d",_model.musicOrder];
//    NSString *fileName = [NSString downFileName:self.model.musicName extensionPath:[self.model.musicFiles pathExtension]];
    
//    BOOL isExists = [NSString fileExitsInDownloadWithFileName:fileName];  //10月31号
//
//    if (isExists) {
//        [_loadBT setImage:ImageNamed(@"已下载") forState:UIControlStateNormal];
//    }else{
//        [_loadBT setImage:ImageNamed(@"未下载") forState:UIControlStateNormal];
//    }
}

#pragma mark --- Public Method
    
- (void)startWaveAnimation{
    self.waveView.hidden = NO;
    self.serialNumberLB.hidden = YES;
    self.musicNameLB.textColor = [Theme mainNavColor];
    self.musicNameLB.font = FONT_DEFAULT_Light(18);
//    [self.waveView startWaveAnimation];
}
    
- (void)endWaveAnimation{
    self.waveView.hidden = YES;
    self.serialNumberLB.hidden = NO;
    self.musicNameLB.textColor = COLOR_HEXSTRING(@"#333333");
    self.musicNameLB.font = FONT_DEFAULT_Light(16);
//    [self.waveView stopWaveAnimation];
    
}
    
#pragma mark --- Action
- (void)downLoad:(UIButton *)sender{
//    /* 每次点击首先实例化 DownLoadDataBase */
//    _downLoadDB = [[DownLoadDataBase alloc] init];
//
//    //查看本地有无缓存
//    NSString *cacheFilePath = [AVFileHandle cacheFileExistsWithName:self.model.musicName];
//    if (cacheFilePath) {
//        //将缓存文件转移至下载文件夹
//        NSString *fileName = self.model.musicName;
//        if ([self.model.musicName containsString:@"兔小贝"])
//            fileName = [self.model.musicName substringFromIndex:8];
//        if (![fileName containsString:@"mp3"]) {
//            fileName = [NSString stringWithFormat:@"%@%@",fileName,@".mp3"];
//        }
//
//        //看看有无存放下载歌曲的文件夹
//        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString cacheFolderPath]]) {
//            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString cacheFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//
//        //缓存文件路径
//        NSString *downloadFilePath = [NSString stringWithFormat:@"%@/%@",[NSString cacheFolderPath],fileName];
//        BOOL success = [[NSFileManager defaultManager] moveItemAtPath:cacheFilePath toPath:downloadFilePath error:nil];
//        //转移成功 保存记录到数据库
//        if (success) {
//            NSDictionary *dic = @{   @"musicName":self.model.musicName == nil ? @"" : self.model.musicName,
//                                    @"musicUrl":downloadFilePath == nil ? @"" : downloadFilePath,
//                                    @"musicImage":self.model.musicImage.url == nil ? @"" : self.model.musicImage.url,
//                                    @"orderDate":self.model.musicFiles.url == nil ? @"" : self.model.musicFiles.url};
//            [_downLoadDB addData:dic];
//
//            //改变按钮
//            _loadBT.hidden = NO;
//            [_progressLB removeFromSuperview];
//            [_loadBT setImage:ImageNamed(@"已下载") forState:UIControlStateNormal];
//            return;
//        }else{
//            _loadBT.hidden = NO;
//            _progressLB.hidden = YES;
//            [_loadBT setImage:ImageNamed(@"未下载") forState:UIControlStateNormal];
//
//        }
//    }
//
//    /*         下载网络资源         */
//    if (![NetWorkStatus isNetworkEnvironment]) {
//        NSLog(@"无网络");
//        return;
//    }
//    /* 然后对相应的状态进行判定 */
//    _progressLB.hidden = NO;
//    _loadBT.hidden = YES;
//    __weak typeof(self) wself = self;
//    NSString *fileName = [NSString downFileName:self.model.musicName extensionPath:[self.model.musicFiles pathExtension]];
//    NSLog(@"fileName = %@ %@",fileName,self.model.musicName);
//    BOOL isExists = [NSString fileExistsAccordingToLeanCloudCache:self.model.musicFiles loadFile:fileName];   //是否已下载
//    NSLog(@"是否已下载 = %d %@",isExists,self.model.musicFiles);
//    if (!isExists) {
//        [MusicViewModel downLoadMusicToLocal:self.model.musicFiles progress:^(NSInteger progress) {
//            self->_progressLB.text = [NSString stringWithFormat:@"%ld%@",(long)progress,@"%"];    //下载进度
//        } success:^(BOOL success) {
//            if (success) {     //下载成功
//                self->_progressLB.hidden = YES;
//                self->_loadBT.hidden = NO;
//                [self->_progressLB removeFromSuperview];
//                [self->_loadBT setImage:ImageNamed(@"已下载") forState:UIControlStateNormal];
//                // 将下载的文件的从LeanCloud的缓存中copy到指定下载的路径下
//                [AVFileHandle loadCacheFileWithFileName:fileName fromCachePath:wself.model.musicFiles.localPath success:^(NSString *cacheAbsolutelyPath, BOOL finish) {
//                    DLog(@"转移目录成功！ 下载的路径%@",cacheAbsolutelyPath);
//                    //将信息存入数据库
//                    if (finish) {
//                        NSDictionary *dic = @{ @"musicName":wself.model.musicName == nil ? @"" : wself.model.musicName,
//                                               @"musicUrl":cacheAbsolutelyPath == nil ? @"" : cacheAbsolutelyPath,
//                                               @"musicImage":wself.model.musicImage.url == nil ? @"" : wself.model.musicImage.url,
//                                               @"orderDate":wself.model.musicFiles.url == nil ? @"" : wself.model.musicFiles.url};
//                        [self->_downLoadDB addData:dic];
//                    }else{
//                        [self downLoadFailure];
//                    }
//                }];
//            }else{
//                [self downLoadFailure];
//            }
//
//        } failure:^(NSError *error) {
//            if (error) {
//                [self downLoadFailure];
//            }
//        }];
//    }else{
//        _progressLB.hidden = YES;
//        _loadBT.hidden = NO;
//        [_progressLB removeFromSuperview];
//        [_loadBT setImage:ImageNamed(@"已下载") forState:UIControlStateNormal];
//    }
}

- (void)downLoadFailure{
    _progressLB.hidden = YES;
    _loadBT.hidden = NO;
    [_loadBT setImage:ImageNamed(@"未下载") forState:UIControlStateNormal];
    [MBProgressHUD showToastDown:@"下载失败"];
}

-(void)setSelected:(BOOL)selected{
   
    if (selected) {
        [self startWaveAnimation];
    }else{
        [self endWaveAnimation];
    }
    
}

@end
