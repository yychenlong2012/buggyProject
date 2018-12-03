//
//  FloatTools.m
//  Buggy
//
//  Created by goat on 2018/7/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "FloatTools.h"
#import "MusicPlayNewController.h"
#import "DYBaseNaviagtionController.h"
#import "MusicManager.h"
#import "CALayer+PauseAimate.h"
#import "MainViewController.h"

@implementation FloatTools

+ (instancetype)manager{
    static FloatTools *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        
        sharedInstance.bgView = [[UIView alloc] init];
        sharedInstance.bgView.backgroundColor = kClearColor;
        sharedInstance.bgView.userInteractionEnabled = YES;
        sharedInstance.bgView.tag = 6765;
        sharedInstance.bgView.frame = CGRectMake(ScreenWidth - RealWidth(100), ScreenHeight - RealWidth(200), RealWidth(56), RealWidth(56));
        sharedInstance.bgView.layer.cornerRadius = sharedInstance.bgView.width/2;
        sharedInstance.bgView.clipsToBounds = YES;
        
        sharedInstance.isShowing = NO;
        
        //icon
        sharedInstance.icon = [[UIImageView alloc] init];
        sharedInstance.icon.image = ImageNamed(@"播放界面占位");
        sharedInstance.icon.frame = sharedInstance.bgView.bounds;
        sharedInstance.icon.userInteractionEnabled = YES;
        [sharedInstance.bgView addSubview:sharedInstance.icon];
        
        //顶部暂停按钮图标
        sharedInstance.topImageView = [[UIImageView alloc] init];
        sharedInstance.topImageView.frame = sharedInstance.bgView.bounds;
        sharedInstance.topImageView.image = ImageNamed(@"floatTop");
        sharedInstance.topImageView.hidden = YES;
        sharedInstance.topImageView.userInteractionEnabled = YES;
        [sharedInstance.bgView addSubview:sharedInstance.topImageView];
        
        //灰色圆圈
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.75].CGColor;  //e6e6e6
        layer.fillColor = kClearColor.CGColor;
        layer.lineWidth = 7;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:sharedInstance.icon.bounds];
        layer.path = path.CGPath;
        [sharedInstance.bgView.layer addSublayer:layer];
        
        //播放进度
        sharedInstance.progressLayer = [CAShapeLayer layer];
//        sharedInstance.progressLayer.strokeColor = [UIColor colorWithHexString:@"#E04E63"].CGColor;
        sharedInstance.progressLayer.strokeColor = kClearColor.CGColor;
        sharedInstance.progressLayer.fillColor = kClearColor.CGColor;
        sharedInstance.progressLayer.lineWidth = 7;
        sharedInstance.progressLayer.strokeStart = 0.0;
        sharedInstance.progressLayer.strokeEnd = 0.0;
        UIBezierPath *path3 = [UIBezierPath bezierPath];
        CGFloat radius = sharedInstance.bgView.width/2;
        [path3 moveToPoint:CGPointMake(radius, 0)];
        [path3 addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
        sharedInstance.progressLayer.path = path3.CGPath;
        [sharedInstance.bgView.layer addSublayer:sharedInstance.progressLayer];
        
        /* 点击手势 */
        __weak typeof(sharedInstance.bgView) newr = sharedInstance.bgView;
        __weak typeof(self) wself = self;
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [sharedInstance.bgView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            MusicPlayNewController *music = [[MusicPlayNewController alloc] init];
            
            if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                MainViewController *main = (MainViewController *)[UIViewController presentingVC];
                if ([[main selectedViewController] isKindOfClass:[DYBaseNaviagtionController class]]) {
                    DYBaseNaviagtionController *navi = [main selectedViewController];
                    [navi pushViewController:music animated:YES];
                }else{
                    [window.rootViewController presentViewController:[[DYBaseNaviagtionController alloc] initWithRootViewController:music] animated:YES completion:^{
                    }];
                }
            }
        }];
        /* 拖动手势 */
        [sharedInstance.bgView addPanGestureRecognizer:^(UIPanGestureRecognizer *recognizer, NSString *gestureId) {
            CGPoint point = [recognizer locationInView:window];
            /* 坐标矫正，是坐标始终靠边站 */
            CGPoint rectifyPoint = [wself rectifyPoint:point];
            newr.center = point;
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    newr.center = rectifyPoint;
                } completion:^(BOOL finished) {
                }];
            }
        }];
        /* 长按手势 */
        [sharedInstance.bgView addLongPressActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [[FloatTools manager] dismissMusicRelocateView];
            //通过长按手势去除悬浮按钮表示停止播放
            [MUSICMANAGER stop];
            [MUSICMANAGER.audioArray removeAllObjects];
        }];
    });
    return sharedInstance;
}

-(void)showMusicRelocateView{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:[FloatTools manager].bgView];
    
    //开始旋转动画
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 25;
    animation.keyPath = @"transform.rotation.z";
    animation.repeatCount = NSIntegerMax;
    animation.removedOnCompletion = NO;
    [[FloatTools manager].icon.layer addAnimation:animation forKey:@"rotation"];
    [FloatTools manager].isShowing = YES;
}

+ (CGPoint)rectifyPoint:(CGPoint )point{
    CGPoint rectifyPoint;
    if (point.x >= ScreenWidth/2) {
        rectifyPoint.x = ScreenWidth - 27.5 * _MAIN_RATIO_375;
        rectifyPoint.y = point.y;
        return rectifyPoint;
    }else{
        rectifyPoint.x = 27.5 * _MAIN_RATIO_375;
        rectifyPoint.y = point.y;
        return rectifyPoint;
    }
}

//移除圆形的播放器入口
- (void)dismissMusicRelocateView{
    [[FloatTools manager].icon.layer removeAllAnimations];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        if (view.tag == 6765) {
            [view removeFromSuperview];
            *stop = YES;
        }
    }];
    [FloatTools manager].isShowing = NO;
}

//重启动画
-(void)restartAnimation{
    [[FloatTools manager].icon.layer removeAllAnimations];
    //开始旋转动画
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 25;
    animation.keyPath = @"transform.rotation.z";
    animation.repeatCount = NSIntegerMax;
    animation.removedOnCompletion = NO;
    [[FloatTools manager].icon.layer addAnimation:animation forKey:@"rotation"];
}

-(void)pauseAnima{
    [[FloatTools manager].icon.layer pauseAnimate];
    [FloatTools manager].topImageView.hidden = NO;
}

-(void)resumeAnima{
    [[FloatTools manager].icon.layer resumeAnimate];
    [FloatTools manager].topImageView.hidden = YES;
}

@end
