//
//  MusicItemListCell.m
//  Buggy
//
//  Created by goat on 2018/6/7.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicItemListCell.h"
#import "NSString+AVLeanCloud.h"
#import "DownLoadDataBase.h"
#import "CalendarHelper.h"
#import "NetWorkStatus.h"

#define UNSELECT_FONT 16
#define SELECT_FONT 18

@interface MusicItemListCell ()
@property (nonatomic ,strong) UILabel *serialNumberLB; // 序列号
@property (nonatomic ,strong) WaveView *waveView;      // 播放动画
@property (nonatomic ,strong) UILabel *musicNameLB;    // 音乐名称
@property (nonatomic ,strong) UILabel *playTime;       // 播放时长

@end
@implementation MusicItemListCell{
    UIView *_bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

//初始化UI
- (void)setupUI{
    
    // 音乐序列号
    self.serialNumberLB = [Factory labelWithFrame:CGRectZero font:FONT_DEFAULT_Light(17) text:@"1" textColor:COLOR_HEXSTRING(@"#666666") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    
    // 音乐播放动画
    [self.contentView addSubview:self.waveView];
    
    // 音乐名称
    self.musicNameLB = [Factory labelWithFrame:CGRectZero font:FONT_DEFAULT_Light(16) text:NSLocalizedString(@"宝宝音乐", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    
    //时长
    self.playTime = [[UILabel alloc] init];
    self.playTime.textAlignment = NSTextAlignmentRight;
    self.playTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.playTime.textColor = [UIColor colorWithHexString:@"666666"];
    [self.contentView addSubview:self.playTime];
    
    // 底部横线
    _bottomLine = [Factory viewWithFrame:CGRectZero bgColor:COLOR_HEXSTRING(@"#D5D5D5") onView:self.contentView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.serialNumberLB.frame = CGRectMake(0, 0, 60 * _MAIN_RATIO_375, 52.5);
    
    self.musicNameLB.frame = CGRectMake(0, 0, ScreenWidth/2, 25);
    self.musicNameLB.centerY = MusicListCellHeight / 2;
    self.musicNameLB.left = 60 * _MAIN_RATIO_375;
    
    self.playTime.frame = CGRectMake(ScreenWidth-128, 0, 100, 17);
    self.playTime.centerY = self.musicNameLB.centerY;
    
    _bottomLine.frame = CGRectMake(60 * _MAIN_RATIO_375, 0, ScreenWidth - 60 * _MAIN_RATIO_375, 0.5);
    _bottomLine.bottom = MusicListCellHeight - 0.5;
}

- (void)setModel:(musicModel *)model{
    
    _model = model;
    self.musicNameLB.text = model.musicname;
//    self.serialNumberLB.text = [NSString stringWithFormat:@"%d",_model.musicOrder];
    if (model.time != nil && ![model.time isKindOfClass:[NSNull class]]) {
        self.playTime.text = model.time;
    }
}

-(void)setIndex:(NSInteger)index{
    self.serialNumberLB.text = [NSString stringWithFormat:@"%ld",(long)index];
}

#pragma mark --- Public Method
- (void)startWaveAnimation{
    self.waveView.hidden = NO;
    self.serialNumberLB.hidden = YES;
    self.musicNameLB.textColor = [Theme mainNavColor];
    self.musicNameLB.font = FONT_DEFAULT_Light(18);
//        [self.waveView startWaveAnimation];
    
    self.playTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    self.playTime.textColor = [UIColor colorWithHexString:@"E04E63"];
}

- (void)endWaveAnimation{
    self.waveView.hidden = YES;
    self.serialNumberLB.hidden = NO;
    self.musicNameLB.textColor = COLOR_HEXSTRING(@"#333333");
    self.musicNameLB.font = FONT_DEFAULT_Light(16);
//        [self.waveView stopWaveAnimation];
    
    self.playTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.playTime.textColor = [UIColor colorWithHexString:@"666666"];
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (selected) {
        [self startWaveAnimation];
        self.playTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        self.playTime.textColor = [UIColor colorWithHexString:@"E04E63"];
    }else{
        [self endWaveAnimation];
        self.playTime.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        self.playTime.textColor = [UIColor colorWithHexString:@"666666"];
    }
}

-(void)currentMusic{
    
}
//LAZY LOADINGß
- (WaveView *)waveView{
    if (!_waveView) {
        _waveView = [[WaveView alloc] initWithStaticAnimationFrame:CGRectMake(0, 0, 60* _MAIN_RATIO_375, 52.5)];
        _waveView.hidden = YES;
    }
    return _waveView;
}

@end
