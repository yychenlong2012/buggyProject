//
//  weightDataLineView.m
//  Buggy
//
//  Created by goat on 2019/2/25.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import "weightDataLineView.h"



@implementation weightDataLineView

- (void)drawRect:(CGRect)rect {
    
    [self drawCurveChartWithPoints:self.pointArray];
}


-(void)setPointArray:(NSArray *)pointArray{
    _pointArray = pointArray;

//    UIBezierPath *path = [UIBezierPath bezierPath];
//    for (NSInteger i = 0; i<pointArray.count; i++) {
//        NSString *pointStr = pointArray[i];
//        if (i == 0) {
//            [path moveToPoint:CGPointFromString(pointStr)];
//        }else{
//            [path addLineToPoint:CGPointFromString(pointStr)];
//        }
//    }
    
    [self setNeedsDisplay];
}


//根据points中的点画出曲线
- (void)drawCurveChartWithPoints:(NSMutableArray *)points
{
    //描点  画字
    for (int i=0; i<points.count; i++) {
        //确认点的位置
        CGPoint point = CGPointMake((i+1)*LandScape, (maxWeight - [points[i] floatValue])/maxWeight * self.size.height);
        //描点
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:point];
        [path closePath];
        path.lineWidth = 5;
        path.lineCapStyle = kCGLineCapRound;
        [[UIColor redColor] set];
        [path strokeWithBlendMode:kCGBlendModeNormal alpha:0.8];
        
        //画字
        NSString *weightStr = points[i];
        [weightStr drawAtPoint:CGPointMake(point.x+3, point.y-12) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],
                                                      NSForegroundColorAttributeName:kBlackColor
                                                      }];
    }
    
    //连线
    UIBezierPath* path1 = [UIBezierPath bezierPath];
    [path1 setLineWidth:2];
    for(int i=0; i<[points count]-1; i++){
//        CGPoint startPoint = CGPointFromString([points objectAtIndex:i]);
//        CGPoint endPoint = CGPointFromString([points objectAtIndex:i+1]);
        CGPoint startPoint = CGPointMake((i+1)*LandScape, (maxWeight - [points[i] floatValue])/maxWeight * self.size.height);
        CGPoint endPoint = CGPointMake((i+2)*LandScape, (maxWeight - [points[i+1] floatValue])/maxWeight * self.size.height);
        [path1 moveToPoint:startPoint];
        [UIView animateWithDuration:.1 animations:^(){
            [path1 addCurveToPoint:endPoint controlPoint1:CGPointMake((endPoint.x-startPoint.x)/2+startPoint.x, startPoint.y) controlPoint2:CGPointMake((endPoint.x-startPoint.x)/2+startPoint.x, endPoint.y)];
        }];
    }
    
    [[UIColor redColor] set];       //设置画笔颜色
    path1.lineCapStyle = kCGLineCapRound;
    [path1 strokeWithBlendMode:kCGBlendModeNormal alpha:0.4];
    

    
    
    
    //辉光效果
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.strokeColor = kRedColor.CGColor;
//    layer.fillColor = kClearColor.CGColor;
//    layer.lineWidth = 1;
//    layer.path = path1.CGPath;
//    layer.shadowPath = path1.CGPath;
//    layer.shadowColor = kRedColor.CGColor;
//    layer.shadowRadius = 5;
//    layer.shadowOpacity = YES;
//    layer.shadowOffset = CGSizeMake(0, 5);
//    [self.layer addSublayer:layer];
}
@end
