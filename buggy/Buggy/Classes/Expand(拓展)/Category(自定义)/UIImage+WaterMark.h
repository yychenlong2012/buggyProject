//
//  UIImage+WaterMark.h
//  Image+watermark
//
//  Created by zyq on 13-5-8.
//  Copyright (c) 2013年 zyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WaterMark)
// 文字水印
- (UIImage *) imageWithStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font;
- (UIImage *) imageWithStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font;
- (UIImage *)imageWithLogoText:(UIImage *)img text:(NSString *)text1;

// 图片水印
- (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect;
- (UIImage *)imageWithLogoImage:(UIImage *)img logo:(UIImage *)logo;//图片水印

//透明水印
- (UIImage *)imageWithTransImage:(UIImage *)useImage addtransparentImage:(UIImage *)transparentimg;


+(CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView;
@end
