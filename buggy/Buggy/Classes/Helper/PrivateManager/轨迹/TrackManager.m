//
//  TrackManager.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "TrackManager.h"

@interface TrackManager()<CAAnimationDelegate>

@property (nonatomic ,assign) CLLocationCoordinate2D *coordinates;

@property (nonatomic ,assign) NSInteger count;

@property (nonatomic ,strong,readwrite) MAPointAnnotation *annotation;

@property (nonatomic ,strong) MAPolyline *polyLine;

@property (nonatomic ,strong) CAShapeLayer *shapeLayer;

@end

@implementation TrackManager

- (instancetype)init{
    
    if (self = [super init]) {
        [self configureInterface];
    }
    return self;
}
- (void)configureInterface{
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.title = @"宝宝飞车";
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 4.0f;
    self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.lineJoin = kCALineCapRound;
}

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates withCount:(NSInteger)count{
    self.coordinates = coordinates;
    self.count = count;
    self.annotation.coordinate = self.coordinates[0];
}

- (void)executeAnamation{
    
    [self clearAnamation];
    // 将地图起始点放入坐标
    [self.mapView addAnnotation:self.annotation];
    self.polyLine = [MAPolyline polylineWithCoordinates:self.coordinates count:self.count];
    [self.mapView setVisibleMapRect:self.polyLine.boundingMapRect edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:YES];
    
    // 开始获取点
    CGPoint *points = [self pointsForCoordinates:self.coordinates count:self.count];
    CGPathRef path = [self pathForPoints:points count:_count];
    self.shapeLayer.path = path;
    [self.mapView.layer addSublayer:self.shapeLayer];
    MAAnnotationView *annotationView = [self.mapView viewForAnnotation:self.annotation];
    if (annotationView != nil) {
        CAAnimation *shapeLayerAnimation = [self constructShapeLayerAnimation];
        shapeLayerAnimation.delegate = self;
        [self.shapeLayer addAnimation:shapeLayerAnimation forKey:@"shapeLayer"];
        
        CAAnimation *annotationAnimation = [self constructAnnotationAnimationPath:path];
        [annotationView.layer addAnimation:annotationAnimation forKey:@"annotation"];
        [annotationView.annotation setCoordinate:self.coordinates[_count - 1]];
    }
    free(points);
    points = NULL;
    CGPathRelease(path);
    path = NULL;
}

- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSInteger )count{
    
    if (points == NULL || count < 1) {
        return NULL;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, NULL, points, count);
    return path;
}


- (CAAnimation *)constructShapeLayerAnimation{
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3;
    animation.values = @[@0.0,@0.5,@1];
    animation.keyTimes = @[@0.0,@0.4,@1];
    animation.removedOnCompletion = YES;
    return animation;
}

- (CAAnimation *)constructAnnotationAnimationPath:(CGPathRef )path{
    
    if (path == NULL) {
        return nil;
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 3;
    animation.path = path;
    animation.calculationMode = kCAAnimationPaced;
    return animation;
}

- (void)clearAnamation{
    [self.mapView removeAnnotation:self.annotation];
    [self.mapView removeOverlay:self.polyLine];
    [self.shapeLayer removeAllAnimations];
    [self.shapeLayer removeFromSuperlayer];
}

#pragma mark ------ CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim{
    
    [self makeMapViewEnable:NO];
    if (self.deleagte != nil && [self.deleagte respondsToSelector:@selector(animationStartTrack:)]) {
        [self.deleagte animationStartTrack:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if (flag) {
        [self.mapView addOverlay:self.polyLine];
        [self.shapeLayer removeAllAnimations];
        [self.shapeLayer removeFromSuperlayer];
    }
    [self makeMapViewEnable:YES];
    if (self.deleagte != nil && [self.deleagte respondsToSelector:@selector(animationEndTrack:)]) {
        [self.deleagte animationEndTrack:self];
    }
}

- (void)makeMapViewEnable:(BOOL)enabled
{
    self.mapView.scrollEnabled          = enabled;
    self.mapView.zoomEnabled            = enabled;
}

- (void)dealloc{
    
    free(self.coordinates);
    self.coordinates = nil;
}

@end
