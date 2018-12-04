//
//  UIImage+COSAdtions.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/2.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "UIImage+COSAdtions.h"

@implementation UIImage (COSAdtions)

- (UIImage *)resizableImageWithOffsetTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right
{
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }else{
        return [self stretchableImageWithLeftCapWidth:left topCapHeight:top];
    }
}

- (UIImage *)getScaledImage:(CGFloat) fscale{
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width*fscale, self.size.height*fscale));
    [self drawInRect:CGRectMake(0.0f, 0.0f, self.size.width*fscale, self.size.height*fscale)];
    UIImage *imgScale = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgScale;
}

-(UIImage*)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIImage* smallImage = [[UIImage alloc] initWithCGImage:subImageRef scale:1 orientation:self.imageOrientation];     //用上面的方法 在截图后会改变图片的显示方向
    UIGraphicsEndImageContext();
    
    return smallImage;
}

-(UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (NSData *)getData:(UIImage *)image limit:(NSInteger)limit
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    long max = limit * 1024;
    if (data.length > max) {
        CGFloat scale = max/data.length;
        data = UIImageJPEGRepresentation(image, scale);
    }
    
    return data;
}
/**
 *  压缩图片质量，返回值为可直接转化成UIImage对象的NSData对象
 *  aimLength: 目标大小，单位：字节（b）
 *  accuracyOfLength: 压缩控制误差范围(+ / -)，本方法虽然给出了误差范围，但实际上很难确定一张图片是否能压缩到误差范围内，无法实现精确压缩。
 */
- (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy{
    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(width, width * image.size.height / image.size.width)];
    
    NSData  * data = UIImageJPEGRepresentation(newImage, 1);
    NSInteger imageDataLen = [data length];
    
    if (imageDataLen <= length + accuracy) {
        return data;
    }else{
        NSData * imageData = UIImageJPEGRepresentation( newImage, 0.99);
        if (imageData.length < length + accuracy) {
            return imageData;
        }
        
        CGFloat maxQuality = 1.0;
        CGFloat minQuality = 0.0;
        int flag = 0;
        
        while (1) {
            CGFloat midQuality = (maxQuality + minQuality)/2;
            
            if (flag == 6) {
                NSLog(@"************* %ld ******** %f *************",UIImageJPEGRepresentation(newImage, minQuality).length,minQuality);
                return UIImageJPEGRepresentation(newImage, minQuality);
            }
            flag ++;
            
            NSData * imageData = UIImageJPEGRepresentation(newImage, midQuality);
            NSInteger len = imageData.length;
            
            if (len > length+accuracy) {
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                maxQuality = midQuality;
                continue;
            }else if (len < length-accuracy){
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                minQuality = midQuality;
                continue;
            }else{
                NSLog(@"-----%d------%f------%ld--end",flag,midQuality,len);
                return imageData;
                break;
            }
        }
    }
}

+ (UIImage *)combin:(UIImage *)firstImage second:(UIImage *)secondImage direction:(ImageDirection)direction
{
    if (direction == Horizontal) {
        CGFloat width = firstImage.size.width + secondImage.size.width;
        CGFloat height = firstImage.size.height;
        CGSize offScreenSize = CGSizeMake(width, height);
        
        UIGraphicsBeginImageContextWithOptions(offScreenSize, YES, 2.0f);
        
        CGRect rect = CGRectMake(0, 0, firstImage.size.width * 2, height * 2);
        [firstImage drawInRect:rect];
        
        rect.origin.x += firstImage.size.width * 2;
        [secondImage drawInRect:rect];
        
        UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return imagez;
    }else{
        CGFloat width = firstImage.size.width;
        CGFloat height = firstImage.size.height  + secondImage.size.height;
        CGSize offScreenSize = CGSizeMake(width * 2, height * 2);
        
        UIGraphicsBeginImageContextWithOptions(offScreenSize, YES, 2.0f);
        
        CGRect rect = CGRectMake(0, 0, firstImage.size.width * 2, firstImage.size.height * 2);
        [firstImage drawInRect:rect];
        
        rect.origin.y = firstImage.size.height * 2;
        rect.size.height = secondImage.size.height * 2;
        [secondImage drawInRect:rect];
        
        UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return imagez;
    }
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithUIView:(UIView *)theView
{
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, 2.0f);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
