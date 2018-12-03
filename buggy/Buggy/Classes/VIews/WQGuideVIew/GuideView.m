//
//  GuideView.m
//  Buggy
//
//  Created by 孟德林 on 2016/10/24.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "GuideView.h"

@implementation GuideView

+ (void)userTripsGuideView{
    CGRect frame = [UIScreen mainScreen].bounds;
    __block UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    /* bgViewOne第一个视图 */
    __block UIView * bgViewOne = [[UIView alloc]initWithFrame:frame];
    bgViewOne.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [keyWindow addSubview:bgViewOne];
    //create path 重点来了（**这里需要添加第一个路径）
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    UIImage *beginImage = ImageNamed(@"开始");
    UIImage *tripsImage = ImageNamed(@"轨迹");
    // 这里添加第二个路径 （这个是圆）
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(90 * _MAIN_RATIO_375 + beginImage.size.width/2, ScreenHeight - 200 + 63) radius:beginImage.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth - 90 * _MAIN_RATIO_375 - tripsImage.size.width/2 + 2, ScreenHeight - 200 + 63) radius:tripsImage.size.width/2 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    // 这里添加第二个路径 （这个是矩形）
    UIImage *historyImage = ImageNamed(@"icon_history");
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(5, 25, historyImage.size.width + 30, historyImage.size.height + 15) cornerRadius:5] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [bgViewOne.layer setMask:shapeLayer];
    
    UIImageView *imageHisTips = [Factory imageViewWithCenter:CGPointMake(0, 0) image:ImageNamed(@"查看历史记录") onView:bgViewOne];
    imageHisTips.left = 10 * _MAIN_RATIO_375;
    imageHisTips.top = 72.5;
    [bgViewOne addSubview:imageHisTips];

    UIImageView *imageOK = [Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, ScreenHeight - 350) image:ImageNamed(@"知道了btn") onView:bgViewOne];
    imageOK.userInteractionEnabled = YES;
    
    
    UIImageView *imageView = [Factory imageViewWithCenter:CGPointMake(0, 0) image:ImageNamed(@"记录轨迹") onView:bgViewOne];
    imageView.left = 11.5 * _MAIN_RATIO_375;
    imageView.bottom = ScreenHeight - 200;
    
    UIImageView *imageHis = [Factory imageViewWithCenter:CGPointMake(0, 0) image:ImageNamed(@"生成轨迹") onView:bgViewOne];
    imageHis.right = ScreenWidth - 11.5 * _MAIN_RATIO_375;
    imageHis.bottom = ScreenHeight - 200;
    
    /* 点击触发的事件 */
    [Factory buttonEmptyWithFrame:CGRectMake(imageOK.left, imageOK.top, imageOK.size.width, imageOK.size.height) click:^{
        [bgViewOne removeFromSuperview];
        [GuideView userTripsGuideViewTwo];
    } onView:bgViewOne];
}
+ (void)userTripsGuideViewTwo{
    CGRect frame = [UIScreen mainScreen].bounds;
    __block UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    /* bgViewTwo第二个视图 */
    __block UIView *bgViewTwo = [[UIView alloc] initWithFrame:frame];
    bgViewTwo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [keyWindow addSubview:bgViewTwo];
    UIBezierPath *pathTwo = [UIBezierPath bezierPathWithRect:frame];
    // 这里添加第二个路径 （这个是圆）
    UIImage *beginImage = ImageNamed(@"开始");
    UIImage *tripsImage = ImageNamed(@"轨迹");
    // 这里添加第二个路径 （这个是圆）
    [pathTwo appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(90 * _MAIN_RATIO_375 + beginImage.size.width/2, ScreenHeight - 200 + 63) radius:beginImage.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    [pathTwo appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth - 90 * _MAIN_RATIO_375 - tripsImage.size.width/2 + 2, ScreenHeight - 200 + 63) radius:tripsImage.size.width/2 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    // 这里添加第二个路径 （这个是矩形）
    //    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(frame.size.width/2.0-1, 234, frame.size.width/2.0+1, 55) cornerRadius:5] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayerTwo = [CAShapeLayer layer];
    shapeLayerTwo.path = pathTwo.CGPath;
    [bgViewTwo.layer setMask:shapeLayerTwo];
    
    UIImage *image = ImageNamed(@"单击屏幕");
    [Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, ScreenHeight - 200) image:image onView:bgViewTwo];
    
    UIImage *imageOK = ImageNamed(@"知道啦");
    UIImageView *imageOkView =[Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) image:imageOK onView:bgViewTwo];
    [Factory buttonEmptyWithFrame:imageOkView.frame click:^{
        [bgViewTwo removeFromSuperview];
        NSUserDefaults *firstCouponBoard = [NSUserDefaults standardUserDefaults];
        [firstCouponBoard setBool:YES forKey:FirstCouponBoard_iPhone];
        [firstCouponBoard synchronize];
        
    } onView:bgViewTwo];
}


+ (void)userHomeGuideView{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    __block UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    /* bgViewOne第一个视图 */
    __block UIView * bgViewOne = [[UIView alloc]initWithFrame:frame];
    bgViewOne.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [keyWindow addSubview:bgViewOne];
    //create path 重点来了（**这里需要添加第一个路径）
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    // 这里添加第二个路径 （这个是圆）
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, 153 * _MAIN_RATIO_375 - 40 + 64) radius:41.25 * _MAIN_RATIO_375 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    // 这里添加第二个路径 （这个是矩形）
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake((ScreenWidth - 150)/2, ScreenHeight - 49 * _MAIN_RATIO_375 - 75 * _MAIN_RATIO_375 - 110 *_MAIN_RATIO_375, 150 , 70) cornerRadius:6] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [bgViewOne.layer setMask:shapeLayer];
    
    
    UIImageView *imageView = [Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, 0) image:ImageNamed(@"头像编辑") onView:bgViewOne];
    imageView.top = 153 * _MAIN_RATIO_375 - 40 + 64 + 41.25 * _MAIN_RATIO_375;
    
    
    UIImageView *imageViewOne = [Factory imageViewWithCenter:CGPointMake(ScreenWidth/2, 0) image:ImageNamed(@"点击输入体重") onView:bgViewOne];
    imageViewOne.bottom = ScreenHeight - 49 - 75 * _MAIN_RATIO_375 - 110 *_MAIN_RATIO_375;
    
    
    [Factory buttonWithCenter:CGPointMake(ScreenWidth/2, ScreenHeight - 49 - 50 * _MAIN_RATIO_375) withImage:ImageNamed(@"知道了btn") click:^{
        [bgViewOne removeFromSuperview];
        NSUserDefaults *firstCouponBoard = [NSUserDefaults standardUserDefaults];
        [firstCouponBoard setBool:YES forKey:FirstHomeCouponBoard_iPhone];
        [firstCouponBoard synchronize];
    } onView:bgViewOne];
}



@end
