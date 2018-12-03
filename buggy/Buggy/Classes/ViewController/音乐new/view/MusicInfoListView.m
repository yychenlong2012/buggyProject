//
//  MusicInfoListView.m
//  Buggy
//
//  Created by 孟德林 on 2017/4/6.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "MusicInfoListView.h"
#import "WNJsonModel.h"
#import "MusicViewModel.h"
#import "UIImage+Additions.h"
#import "NetWorkStatus.h"
#import "MusicAlbumModel.h"
@interface MusicInfoListView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MusicInfoListView{
    UIImageView *_bgImageView;
    UIImageView *_imageView;
    UIView *_bgView;
    UILabel *_titleLB;
    UILabel *_detailLB;
    CABasicAnimation *_keyAnimation;
    CAAnimationGroup *_groupAnimation;
    CABasicAnimation *_keyAnmationScale;
    
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark --- 设置头部的主题和动画
- (void)setupUI{
    //视图是按照顺序进行的
    // 背景图片
//    UIImage *image = ImageNamed(@"经典古诗-封面");
    UIImage *image = ImageNamed(@"歌单占位图");
    
    //背景图片
    _bgImageView = [Factory imageViewWithFrame:CGRectMake(0, 0, ScreenWidth, MusicInfoListViewHeight + 10) image:image onView:self];
    _bgImageView.contentMode = UIViewContentModeScaleToFill;
    
    UIView *view = [[UIView alloc ]init];
    view.backgroundColor = kBlackColor;
    view.frame = _bgImageView.bounds;
    view.alpha = 0.1;
    [_bgImageView addSubview:view];
    //模糊效果
    NSString *version = [UIDevice currentDevice].systemVersion;
    UIBlurEffect *effect;
    if (version.doubleValue >= 10.0) {
        effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    }else{
        effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = _bgImageView.bounds;
    [_bgImageView addSubview:effectView];

    //黑色胶片
    UIImageView *CDImage = [Factory imageViewWithFrame:CGRectMake(0, 0, 35 *_MAIN_RATIO_375, 114 * _MAIN_RATIO_375) image:ImageNamed(@"唱碟") onView:self];
    
    //主题图片
    _imageView = [Factory imageViewWithFrame:CGRectMake(30 * _MAIN_RATIO_375, 86.5, 125 * _MAIN_RATIO_375, 130 * _MAIN_RATIO_375) image:image onView:self];
    CDImage.centerY = _imageView.centerY;
    CDImage.left = _imageView.right;
    
    // 主标题
    _titleLB = [Factory labelWithFrame:CGRectMake(0, 0, 96 * _MAIN_RATIO_375, 34) font:FONT_DEFAULT_Light(24) text:@"" textColor:COLOR_HEXSTRING(@"#FFFFFF") onView:self textAlignment:NSTextAlignmentCenter];
    _titleLB.right = ScreenWidth - 30 * _MAIN_RATIO_375;
    _titleLB.top = 83;
    _titleLB.adjustsFontSizeToFitWidth = YES;
    
    // 标题详解
    _detailLB = [Factory labelWithFrame:CGRectMake(0, 0, 127 * _MAIN_RATIO_375, 72 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(12.5) text:@"" textColor:COLOR_HEXSTRING(@"#FFFFFF") onView:self textAlignment:NSTextAlignmentLeft];
    _detailLB.adjustsFontSizeToFitWidth = YES;
    _detailLB.right = ScreenWidth - 30 * _MAIN_RATIO_375;
    _detailLB.top = 117 + 27.5;
}

- (void)setModel:(MusicThemeModel *)model{
    _model = model;
    _titleLB.text = model.themeTitle;
    _detailLB.text = model.themeDetails;

    if (model.themeImage != nil && ![model.themeImage isKindOfClass:[NSNull class]]) {
        
        NSString *urlStr;
        if ([model.themeImage isKindOfClass:[NSString class]]) {
            urlStr = (NSString *)model.themeImage;
        }
        
        if ([model.themeImage isKindOfClass:[AVFile class]]) {
            urlStr = model.themeImage.url;
        }
        
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url) {
            [[[SDWebImageManager sharedManager] imageDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
                    self->_imageView.image = image;
                    self->_bgImageView.image = image;
                }
            }];
        }
    }
    _bgView.backgroundColor = [COLOR_HEXSTRING(model.themeColor) colorWithAlphaComponent:(float)(model.themeColorOpacity/100.00)];
}

-(void)setTopModel:(MusicAlbumModel *)topModel{
    if (![topModel isKindOfClass:[MusicAlbumModel class]]) {
        return;
    }
    
    _topModel = topModel;
    
    if (topModel.title != nil && ![topModel.title isKindOfClass:[NSNull class]]) {
        _titleLB.text = topModel.title;
    }
    
    if (topModel.describe != nil && ![topModel.describe isKindOfClass:[NSNull class]]) {
        _detailLB.text = topModel.describe;
    }
    
    if ([topModel.imageface isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:topModel.imageface];
        if (url) {
            [self->_imageView sd_setImageWithURL:url];
            [self->_bgImageView sd_setImageWithURL:url];
            
//            [[[SDWebImageManager sharedManager] imageDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//                if (image) {
//                    self->_imageView.image = image;
//                    self->_bgImageView.image = image;
//                }
//            }];
        }
    }

//    if (topModel.bgColor != nil && [topModel.bgColor isKindOfClass:[NSString class]]) {
//        _bgView.backgroundColor = COLOR_HEXSTRING(topModel.bgColor);
//    }
}

- (void)addAnimation{
    
    CAKeyframeAnimation *keyAnmation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyAnmation.values = @[
                           [NSValue valueWithCGPoint:CGPointMake(ScreenWidth-30*_MAIN_RATIO_375 - 48*_MAIN_RATIO_375, 100)],
                           [NSValue valueWithCGPoint:CGPointMake(ScreenWidth/2, 20 + 17 + 4)]
                           ];
    CAKeyframeAnimation *keyAnmationScale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyAnmationScale.values = @[@1,@0.8];
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[keyAnmation,keyAnmationScale];
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.duration = 4;
    [_titleLB.layer addAnimation:groupAnimation forKey:@"groupAnimation"];
}


#pragma mark --- ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y + MusicInfoListViewHeight - navigationH;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollDidScroll:)]) {
        [self.delegate scrollDidScroll:offsetY];
    }
    
//    CGFloat begin = 140;
//    CGFloat height = MusicInfoListViewHeight - navigationH - begin;
//
//    CGFloat startCenterX = ScreenWidth-30*_MAIN_RATIO_375 - 48*_MAIN_RATIO_375;
//    CGFloat endCenterX = ScreenWidth/2;
//
//    CGFloat startCenterY = 100;
//    CGFloat endCenterY = 41;
//
//    if (offsetY >= begin && offsetY<= MusicInfoListViewHeight - navigationH) {
//        _titleLB.center = CGPointMake(startCenterX -(offsetY - begin) *(startCenterX - endCenterX)/height, startCenterY - (startCenterY - endCenterY)/height * (offsetY - begin));
//        _titleLB.transform = CGAffineTransformMakeScale(1-(0.2/90)*(offsetY - begin), 1-(0.2/90)*(offsetY - begin));
//    }else if (offsetY<= 143){
//        _titleLB.center = CGPointMake(ScreenWidth-30*_MAIN_RATIO_375 - 48*_MAIN_RATIO_375, 100);
//    }else if (offsetY > MusicInfoListViewHeight - navigationH){
//        [UIView animateWithDuration:0.1 animations:^{
//            _titleLB.center = CGPointMake(ScreenWidth/2, 20 + 17 + 4 + (ScreenHeight == 812 ? 24 : 0));
//        }];
//
//    }
}

/*   处理表格方法   */
#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MusicListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 设置代理
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(musicNumberOfRowsInSection:)]) {
        return [self.dataSource musicNumberOfRowsInSection:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [NSString stringWithFormat:@"%ld%ldresueIdentifier",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (self.dataSource && [self.dataSource musicTableviewCell:cell musicCellForRowAtIndexPath:indexPath musicIdentifiler:identifier]) {
        cell = [self.dataSource musicTableviewCell:cell musicCellForRowAtIndexPath:indexPath musicIdentifiler:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//点击播放音乐
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"选中%ld",indexPath.row);
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicDidSelectRowAtIndexPath:tableView:)]) {
        [self.delegate musicDidSelectRowAtIndexPath:indexPath tableView:tableView];
    }
    [[BLEMusicPlayer shareManager] setCurrentIndex:indexPath.row];
}

// 判断是否划到最后一行
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([MainModel model].musicTypeNumber == self.musicTypeNumber) {
        NSInteger playingNum = [BLEMusicPlayer shareManager].currentIndex;
        NSIndexPath *indexPathMusic = [NSIndexPath indexPathForRow:playingNum inSection:0];
        if (playingNum >=0 && indexPathMusic == indexPath) {
            // 判断是否正在播放
            if ([BLEMusicPlayer shareManager].playing) {
                cell.selected = YES;
            }
        }else{
            cell.selected = NO;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicwillDisplayCellForRowAtIndexPath:withTableView:)]) {
        [self.delegate musicwillDisplayCellForRowAtIndexPath:indexPath withTableView:tableView];
    }
}

#pragma mark ---- getter  and setter

-(UITableView *)tableView{
    
    if (_tableView == nil) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - _NAV_HEIGHT) style:UITableViewStylePlain];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationH, ScreenWidth, ScreenHeight - navigationH) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(MusicInfoListViewHeight - navigationH, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(MusicInfoListViewHeight - navigationH, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end
