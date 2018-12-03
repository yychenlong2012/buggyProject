//
//  UIImage+WaterMark.m
//  Image+watermark
//
//  Created by zyq on 13-5-8.
//  Copyright (c) 2013年 zyq. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

#pragma mark -这是文字水印
//加文字，另有一个写了UIimage的category实现的添加水印
-(UIImage *)imageWithLogoText:(UIImage *)img text:(NSString *)text1
{
    /////注：此为后来更改，用于显示中文。zyq,2013-5-8
    CGSize size = CGSizeMake(200, img.size.height);          //设置上下文（画布）大小
    UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
    CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
    CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
    
    [[UIColor redColor] set];                                //上下文种的文字属性
    CGContextTranslateCTM(contextRef, 0, img.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    [text1 drawInRect:CGRectMake(0, 0, 200, 80) withAttributes:@{NSFontAttributeName:font}];//此处设置文字显示的位置
//    [text1 drawInRect:CGRectMake(0, 0, 200, 80) withFont:font];       //此处设置文字显示的位置
    UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
    UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
    return targetimg;
    
    
//    //注：此为原来，不能显示中文。无用。
//    //get image width and height
//    int w = img.size.width;
//    int h = img.size.height;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    //create a graphic context with CGBitmapContextCreate
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1);
//    char* text = (char *)[text1 cStringUsingEncoding:NSUnicodeStringEncoding];
//    CGContextSelectFont(context, "Georgia", 30, kCGEncodingMacRoman);
//    
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    CGContextSetRGBFillColor(context, 255, 0, 0, 1);
//    CGContextShowTextAtPoint(context, w/2-strlen(text)*5, h/2, text, strlen(text));
//    //Create image ref from the context
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    return [UIImage imageWithCGImage:imageMasked];
}

#pragma mark -也是文字水印
- (UIImage *) imageWithStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    //文字颜色
    [color set];
    
    //水印文字
//    [markString drawInRect:rect withFont:font];
    [markString drawInRect:rect withAttributes:@{NSFontAttributeName:font}];
    
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

#pragma mark -还是文字水印
- (UIImage *) imageWithStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    //文字颜色
    [color set];
    //水印文字
//    [markString drawAtPoint:point withFont:font];
    [markString drawAtPoint:point withAttributes:@{NSFontAttributeName:font}];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

#pragma mark - 加图片水印
-(UIImage *)imageWithLogoImage:(UIImage *)img logo:(UIImage *)logo
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int logoWidth = logo.size.width;
    int logoHeight = logo.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake(w-logoWidth, 0, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}

#pragma mark -还是图片水印
- (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //水印图
    [mask drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

//加半透明的水印
-(UIImage *)imageWithTransImage:(UIImage *)useImage addtransparentImage:(UIImage *)transparentimg
{
    UIGraphicsBeginImageContext(useImage.size);
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
    [transparentimg drawInRect:CGRectMake(0, useImage.size.height-transparentimg.size.height, transparentimg.size.width, transparentimg.size.height) blendMode:kCGBlendModeOverlay alpha:0.4f];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}
@end
