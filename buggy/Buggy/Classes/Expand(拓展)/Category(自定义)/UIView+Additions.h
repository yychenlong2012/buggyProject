//
//  UIView+Additions.h
//  XTWWK
//
//  Created by Ning on 14-5-9.
//  Copyright (c) 2014年 alen_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Additions)

@property (nonatomic)CGFloat left;
@property (nonatomic)CGFloat top;
@property (nonatomic)CGFloat right;
@property (nonatomic)CGFloat bottom;
@property (nonatomic)CGFloat width;
@property (nonatomic)CGFloat height;
@property (nonatomic)CGPoint origin;
@property (nonatomic)CGFloat originX;
@property (nonatomic)CGFloat originY;
@property (nonatomic)CGSize  size;
@property (nonatomic)CGFloat centerX;
@property (nonatomic)CGFloat centerY;


+ (void) drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius;
+ (instancetype)viewWithXib:(NSString *)nibName;

- (void)circleStyle;
- (void)addCornerStyle:(CGFloat)corner;
- (void)addBoundColor:(UIColor *)color;
+ (UIView*)duplicate:(UIView*)view;

@end
