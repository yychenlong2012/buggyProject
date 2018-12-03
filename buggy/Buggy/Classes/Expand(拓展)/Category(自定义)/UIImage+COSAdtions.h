//
//  UIImage+COSAdtions.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/2.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    Horizontal,
    Vertical
} ImageDirection;

@interface UIImage (COSAdtions)

- (UIImage *)resizableImageWithOffsetTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

- (UIImage *)getScaledImage:(CGFloat) fscale;

- (UIImage *)getSubImage:(CGRect)rect;

- (UIImage*)scaleToSize:(CGSize)size;

- (UIImage *)fixOrientation:(UIImage *)aImage;

/*
 param:
 */
- (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy;

+ (NSData *)getData:(UIImage *)image limit:(NSInteger)limit; //得到一个一定大小的数据  单位 kb 误差在：100byte内
+ (UIImage *)combin:(UIImage *)firstImage second:(UIImage *)secondImage direction:(ImageDirection)direction;

+ (UIImage *)imageWithUIView:(UIView *)view;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
