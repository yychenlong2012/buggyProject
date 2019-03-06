//
//  CWCommon.m
//  CarWins
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 CarWins Inc. All rights reserved.
//

#import "AYCommon.h"
#include <sys/sysctl.h>
#include <objc/objc.h>
#define ORIGINAL_MAX_WIDTH 640.0f


@implementation AYCommon

static AYCommon *common = nil;
+ (AYCommon *)shareCommon
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        common = [[AYCommon alloc] init];
    });
    return common;
}

//判断是否为整形：

+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

+ (CGFloat) getTextHeight:(NSString *)string
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 280, 0)];
    textView.tag = 0x1001;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:14];
    
    textView.text = string;
    [textView sizeToFit];
    CGFloat height = textView.contentSize.height;
    
    return height;
}

+ (CGFloat) getTextWidth:(NSString *)string
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textView.tag = 0x1001;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:13];
    
    textView.text = string;
    [textView sizeToFit];
    CGFloat width = textView.contentSize.width;
    
    return width;
}

+ (CGFloat)getStringHeight:(NSString *)str withFontSize:(CGFloat)fontSize bold:(BOOL)_bold labelWidth:(CGFloat)width
{
    if ([AYDeviceManager currentVersion]>=7.0)
    {
        CGSize size = CGSizeMake(width,MAXFLOAT);
        CGRect textRect = [str
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:_bold ? [UIFont boldSystemFontOfSize:fontSize]:[UIFont systemFontOfSize:fontSize]}
                           context:nil];
        return textRect.size.height;
    }
    else
    {
        CGSize maximumLabelSize = CGSizeMake(width,MAXFLOAT);//1024-150=874/2=437  768-49=719-52=667  顶端和底端的空白部分高度共计52px
        CGSize expectedLabelSize = [str sizeWithFont:_bold ? [UIFont boldSystemFontOfSize:fontSize]:[UIFont systemFontOfSize:fontSize] constrainedToSize:maximumLabelSize
                                       lineBreakMode:NSLineBreakByWordWrapping];
        return expectedLabelSize.height;
    }
}

+ (CGRect)getLabelWidthForString:(UILabel *)strLabel
{
    return [strLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, strLabel.height)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:@{NSFontAttributeName: strLabel.font}
                                                                context:nil];
}

+ (CGRect)getLabelHeightForString:(UILabel *)strLabel
{
    return [strLabel.text boundingRectWithSize:CGSizeMake(strLabel.width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName: strLabel.font}
                                       context:nil];
}

#pragma mark - 获取宽度>iOS7.0
+ (CGFloat)getWidthForString:(NSString *)string fontSize:(CGFloat)size viewHeight:(CGFloat)height
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}
                                       context:nil];
    return rect.size.width;
}

#pragma mark - 获取高度>iOS7.0
+ (CGFloat)getHeightForString:(NSString *)string fontSize:(CGFloat)size viewWidth:(CGFloat)width
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}
                                       context:nil];
    return rect.size.height;
}


+ (CGFloat) getLabelHeight:(NSString *)string fontSize:(CGFloat)size viewWidth:(CGFloat)width
{
    CGFloat height = [string sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(width, 960) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    return height;
}

+ (CGFloat) getLabelHeight:(NSString *)string boldFontSize:(CGFloat)size viewWidth:(CGFloat)width
{
    CGFloat height = [string sizeWithFont:[UIFont boldSystemFontOfSize:size] constrainedToSize:CGSizeMake(width, 960) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    return height;
}

+ (CGFloat) getLabelWidth:(NSString *)string fontSize:(CGFloat)size
{
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}];
    CGFloat width = stringSize.width;
    return width;
}

+ (CGFloat)getLabelWidthForBoldFont:(NSString *)string fontSize:(CGFloat)size
{
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:size]}];
    CGFloat width = stringSize.width;
    return width;
}


+ (CGFloat) getTextHeight:(NSString *)string fontSize:(CGFloat)size viewWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    textView.tag = 0x1001;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:size];
    
    textView.text = string;
    [textView sizeToFit];
    int height = textView.frame.size.height;
    
    return height;
}

#pragma mark 判断是不是新版本
+ (BOOL)isNewVersion:(NSString *)newVer ver2:(NSString *)oldVer
{
    NSArray *ver1s = [newVer componentsSeparatedByString:@"."];
    NSArray *ver2s = [oldVer componentsSeparatedByString:@"."];
    
    int veri1 = 0;
    int veri2 = 0;
    
    if (ver1s.count>=2) {
        veri1 += [[ver1s objectAtIndex:0] intValue]*10000;
        veri1 += [[ver1s objectAtIndex:1] intValue]*100;
    }
    
    if (ver1s.count==3) {
        veri1 += [[ver1s objectAtIndex:2] intValue];
    }
    
    if (ver2s.count>=2) {
        veri2 += [[ver2s objectAtIndex:0] intValue]*10000;
        veri2 += [[ver2s objectAtIndex:1] intValue]*100;
    }
    
    if (ver2s.count==3) {
        veri2 += [[ver2s objectAtIndex:2] intValue];
    }
    
    if (veri1>veri2) {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 用“,”分割字符串
+(NSString *)getStringFromArray:(NSArray *)array
{
    @synchronized(self)
    {
        NSString *result = @"";
        for (int i = 0; i < array.count; i++)
        {
            if (i == array.count - 1)
            {
                result = [result stringByAppendingFormat:@"%@",[array objectAtIndex:i]];
            }
            else
            {
                result = [result stringByAppendingFormat:@"%@,",[array objectAtIndex:i]];
            }
        }
        return result;
    }
}

#pragma mark - 获取评分对应图片 0-－5
+ (UIImage *)getImageByScore:(NSInteger)score
{
    switch (score)
    {
        case 0:
        case 1:
        return [UIImage imageNamed:@"ico_star_1.png"];
        break;
        
        case 2:
        return [UIImage imageNamed:@"ico_star_2.png"];
        break;
        
        case 3:
        return [UIImage imageNamed:@"ico_star_3.png"];
        break;
        
        case 4:
        return [UIImage imageNamed:@"ico_star_4.png"];
        break;
        
        case 5:
        return [UIImage imageNamed:@"ico_star_5.png"];
        break;
        
        default:
        break;
    }
    
    return [UIImage imageNamed:@"ico_star_5.png"];
}

#pragma mark - 根据颜色创建图片
+ (UIImage *)createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 获取App版本号
+ (NSString *)getAppVersion
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    return developmentVersionNumber;
}


#pragma mark camera utility
/**
 *  验证相机是否可用
 */
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
/**
 *  验证后置相机是否可用
 */
+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
/**
 *  验证前置相机是否可用
 */
+(BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
/**
 *  验证拍照功能是否可用
 */
+ (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}
/**
 *  验证相册是否可用
 */
+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark image scale utility
/**
 *  将图片缩放到最大大小 （width：640）
 */
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH)
        return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

/**
 *  将图片缩放到指定大小
 */
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        scaleFactor = widthFactor; // scale to fit height
        else
        scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        DLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  根据frame 获取一个圆形的imageView
 */
+ (UIImageView *)getRoundImageViewWithFrame:(CGRect)frame
{
    UIImageView * roundImageView = [[UIImageView alloc] initWithFrame:frame];
    [roundImageView.layer setCornerRadius:(roundImageView.frame.size.height/2)];
    [roundImageView.layer setMasksToBounds:YES];
    [roundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [roundImageView setClipsToBounds:YES];
    roundImageView.layer.shadowColor = [UIColor clearColor].CGColor;
    roundImageView.layer.shadowOffset = CGSizeMake(0, 0);
    roundImageView.layer.shadowOpacity = 0.0;
    roundImageView.layer.shadowRadius = 0;
    roundImageView.layer.borderColor = [[UIColor clearColor] CGColor];
    roundImageView.layer.borderWidth = 0.0f;
    roundImageView.userInteractionEnabled = YES;
    roundImageView.backgroundColor = [UIColor clearColor];
    return roundImageView;
}

/**
 *  在指定文本中设置指定文字的颜色
 */
+ (NSAttributedString *)getAttributedStr:(NSString *)keyWord
                                inString:(NSString *)string
                          highlightColor:(UIColor *)color
{
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = [string rangeOfString:keyWord];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    return attributedStr;
}
/**
 *  在指定文本中设置指定文字的字体
 */
+ (NSAttributedString *)getAttributedStr:(NSString *)keyWord
                                inString:(NSString *)string
                                    font:(UIFont *)font
{
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = [string rangeOfString:keyWord];
    [attributedStr addAttribute:NSFontAttributeName value:font range:range];
    
    return attributedStr;
}

//去html标签
+ (NSString *)filterHTML:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html=[html stringByReplacingOccurrencesOfString:@"&#183;" withString:@"-"];
    html=[html stringByReplacingOccurrencesOfString:@"&quot;" withString:@" "];
    html=[html stringByReplacingOccurrencesOfString:@"&#160;" withString:@""];
    html=[html stringByReplacingOccurrencesOfString:@"���" withString:@" "];
    html=[html stringByReplacingOccurrencesOfString:@"��" withString:@" "];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        //html = [html stringByReplacingOccurrencesOfString:@"&#183;" withString:@"-"];
    }
//        NSString * regEx = @"<([^>]*)>";
//        html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}

//字符串拼接Html
+ (NSMutableString *)getHtmlString:(NSString *)str
{
    NSMutableString *strReturn=[NSMutableString stringWithCapacity:1];
    [strReturn appendString:@"<!DOCTYPE html>"];
    [strReturn appendString:@"<html>"];
    [strReturn appendString:@"<head>"];
    [strReturn appendString:@"<title></title>"];
    [strReturn appendString:[NSString stringWithFormat:@"<style type=\"text/css\">\
                             p { text-align:justify;text-justify:Distribute-all-lines;line-height:20px; font-size: 14px;word-wrap: break-word; white-space: pre-line; color:0x424242;} \
                             </style></head><body><div style=\"width:95%%;margin: 0 auto;\">"]];
    [strReturn appendString:[NSString stringWithFormat:@"<p>%@</p></div></body></html>",str]];
    return strReturn;
}

#pragma mark 图像处理
+ (UIImage *)clipImage:(UIImage *)sourceImage
{
    //start
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //clipPath
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 50, 0);
    CGPathAddLineToPoint(path, NULL, 0, 50);
    CGPathAddLineToPoint(path, NULL, 50, 100);
    CGPathAddLineToPoint(path, NULL, 100, 50);
    CGContextAddPath(ctx, path);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    //drawimage
    CGSize sourceSize = sourceImage.size;
    CGRect clipedRect;
    if (sourceSize.width > sourceSize.height) {
        clipedRect = CGRectMake((sourceSize.width-sourceSize.height)/2,
                                0,
                                sourceSize.height,
                                sourceSize.height);
    }
    else
    {
        clipedRect = CGRectMake(0,
                                (sourceSize.height-sourceSize.width)/2,
                                sourceSize.width,
                                sourceSize.width);
    }
    //放到中点
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -100);
    //changeCoodinate
    CGImageRef image = CGImageCreateWithImageInRect(sourceImage.CGImage, clipedRect);
    CGContextDrawImage(ctx, CGRectMake(0, 0, 100, 100), image);
    
    //output
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(image);
    CGPathRelease(path);
    
    UIGraphicsEndImageContext();
    return resultImage;
}

/*邮箱验证 MODIFIED BY HELENSONG*/
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY HELENSONG*/
+ (BOOL)isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，17, 18开头，八个 \d 数字字符
                         //@"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$"   原始版本
                         //@"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$"
                         //@"^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}$
    NSString *phoneRegex = @"^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}
/*车牌号格式验证 */
+ (BOOL)isValidateCarNumber:(NSString *)carNum
{
    NSString *carnumRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carnumTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carnumRegex];
    
    return [carnumTest evaluateWithObject:carNum];
}

/** VIN */
+ (BOOL)isValidVinCode:(NSString *)VinCode
{
    NSString *vinRegex = @"^[1-69ABCDEFGHLNPUMJKLRSTVWYZ][0-9A-HJ-NPR-Z]{16}$";
    NSPredicate *vinTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",vinRegex];
    
    return [vinTest evaluateWithObject:VinCode];
}

+ (UIImage *)getImageFromURL:(NSString *)fileURL {
    UIImage * result;

    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];

    return result;
    
}

+ (void)createTimer:(UIButton *)btn andTime:(int)times andEndBackgroundColor:(UIColor *)color
{
    //定时器
    NSString *btnTitle = [NSString stringWithString:btn.titleLabel.text];
    btn.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    __block int timeout = times; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [btn setTitle:btnTitle forState:UIControlStateNormal];
                btn.userInteractionEnabled = YES;
                btn.backgroundColor = color;
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [btn setTitle:[NSString stringWithFormat:YFCulture(@"%@秒后重新发送"), strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                btn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

//在程序中如何把两张图片合成为一张图片
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

/**
 *  格式化关键字
 */
+ (NSString *)getKeywordsFromText:(NSString *)keywordsText withSplit:(NSString *)split
{
    NSString *keywords = [[NSString alloc] initWithString:keywordsText];
    keywords = [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"：" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@":" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"," withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"/" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"、" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"，" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"." withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"。" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@";" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"；" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"\\" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"&" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"$" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"*" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"￥" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"#" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"（" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"）" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"(" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@")" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"[" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"]" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"\"" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"“" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"”" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"@" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"=" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"！" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"!" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"……" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"…" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"^" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"%" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"}" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"{" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"？" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"?" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"`" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"-" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"+" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"——" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"|" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"~" withString:split];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"||" withString:split];
    
    return keywords;
}

/**
 *  格式化关键字
 */
+ (NSString *)getKeywordsFromText:(NSString *)keywordsText replaceConjStringWithSplit:(NSString *)split
{
    NSString *keywords = [[NSString alloc] initWithString:keywordsText];
    keywords = [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *conjStr = @"以便、以免、为了、不管、只要、除非、虽然、可是、虽然、固然、尽管、纵然、即使、不但、不仅、而且、何况、好比、如同、似乎、等于、不如、不及、与其、不是、就是、如果、若是、假如、只要、除非、假使、倘若、即使、假若、要是、譬如、况且、何况、乃至、于是、然后、至于、说到、此外、一般、比方、接着、虽然、但是、然而、偏偏、只是、不过、不料、岂知、原来、因为、由于、以便、因此、所以、是故、以致、或者、还是、了解、至于、或、却、像、如、而、和、跟、与、既、同、及、而、况、则、乃、就、而、便、亦、非、即、若、像、若、则、并、且、以、等、的、么、阿、啊、啦、唉、呢、吧、了、哇、呀、吗、哦、噢、喔、呵、嘿、吁、吓、吖、吆、呜、咔、咚、呼、呶、呣、咝、咯、咳、呗、咩、哪、哎";
    NSArray *conjArr = [conjStr componentsSeparatedByString:@"、"];
    
    for (NSString *str in conjArr) {
        keywords = [keywords stringByReplacingOccurrencesOfString:str withString:split];
    }
    
    return keywords;
}

#pragma mark - 从二进制文件中动态获取图片格式
/**
 *  从二进制文件中动态获取图片格式
 *
 *  @param data 图片的二进制
 *
 *  @return 图片的类型 如: jpg
 */
+ (NSString *)getImageTypeForImageData:(NSData *)data
{
    uint8_t c;
    
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @".jpg";
        case 0x89:
            return @".png";
        case 0x47:
            return @".gif";
        case 0x49:
        case 0x4D:
            return @".tiff";
    }
    
    return nil;
}
/**
 *  获取图片的mimeType
 */
+ (NSString *)getImageMineTypeForImageData:(NSData *)data
{
    uint8_t c;
    
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    
    return nil;
}

#pragma mark - 遍历文件夹获得文件夹大小，返回多少M
+ (CGFloat)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/1024.0;
}

#pragma mark - 单个文件的大小 返回多少K
+ (CGFloat)fileSizeAtPath:(NSString *)filePath
{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/(1024.0);
    }
    return 0;
    
}

#pragma mark - 截取指定大小的图片
+ (UIImage *)scaleFromImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
        AudioServicesPlaySystemSound(sound);
    }
    else {
        NSLog(@"Error: audio file not found at path: %@", path);
    }
}

#pragma mark - 将事件和提醒添加到系统日历
+ (void)saveEventWithTitle:(NSString *)title
                  location:(NSString *)location
                 startDate:(NSDate *)startDate
                   endDate:(NSDate *)endDate
              completeDate:(NSDate *)completeDate
                    allDay:(BOOL)allDay
                alarmArray:(NSArray <EKAlarm *> *)alarmArray
{
    //事件市场
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    //6.0及以上通过下面方式写入事件
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        //事件
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误信息
                    DLog(@"error:%@",error.localizedDescription);
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                    DLog(@"被用户拒绝，不允许访问日历");
                    if ([AYDeviceManager currentVersion]>=8.0){
                        [AYMessage show:YFCulture(@"请在设置中允许App访问系统日历,以保证App能够及时将提醒事件保存到日历中")
                               tipTitle:YFCulture(@"无法访问日历")
                                okTitle:YFCulture(@"设置")
                                Clicked:^(NSInteger buttonIndex) {
                            
                            if (buttonIndex == 0) {
                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                    [[UIApplication sharedApplication] openURL:url];
                                }
                            }
                        }];
                    }else{
                        [AYMessage show:YFCulture(@"请在设置中允许App访问系统日历,以保证App能够及时将提醒事件保存到日历中")
                                  title:YFCulture(@"无法访问日历")];
                    }
                }
                else
                {
                    //事件保存到日历
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = title;
                    event.location  = location;
                    event.startDate = startDate;
                    event.endDate   = endDate;
                    event.allDay    = allDay;
                    
                    //添加提醒
                    if (alarmArray == nil) {
                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:-60*15]];
                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:-60*5]];
                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:0]];
                    }else {
                        for (EKAlarm *alarm in alarmArray) {
                            [event addAlarm:alarm];
                        }
                    }
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
//                    [eventStore removeEvent:event span:EKSpanThisEvent error:&err];
                    if ([eventStore saveEvent:event span:EKSpanThisEvent error:&err]){
                        DLog(@"保存成功");
                    }
                }
            });
        }];
        
        //提醒
//        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
//            if (granted) {
//                
//                EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
//                reminder.title = title;
//                NSCalendar *cal = [NSCalendar currentCalendar];
//                [cal setTimeZone:[NSTimeZone systemTimeZone]];
//                NSInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |
//                NSSecondCalendarUnit;
//                
//                reminder.startDateComponents    = [cal components:flags fromDate:startDate];   // 开始时间
//                reminder.dueDateComponents      = [cal components:flags fromDate:endDate];     // 结束时间
//                reminder.completionDate         = completeDate;                                // 完成时间
//                [reminder setCalendar:[eventStore defaultCalendarForNewReminders]];
//                reminder.priority = 1;  //优先级
//                
//                if (alarmArray == nil) {
//                    [reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-60*15]];
//                    [reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-60*5]];
//                    [reminder addAlarm:[EKAlarm alarmWithRelativeOffset:0]];
//                }else {
//                    for (EKAlarm *alarm in alarmArray) {
//                        [reminder addAlarm:alarm];
//                    }
//                }
//                
//                NSError *err = nil;
//                if([eventStore saveReminder:reminder commit:YES error:&err]){
//                     DLog(@"保存成功");
//                }else{
//                    DLog(@"error:%@",err);
//                }  
//            }else{  
//                DLog(@"error:%@",error);
//            }  
//        }];
    }
}

#pragma mark  - 写入联系人信息
+ (void)creatNewRecord
{
    if ([AYDeviceManager currentVersion] < 9.0){

        CFErrorRef error = NULL;
        
        //创建一个通讯录操作对象
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:YFCulture(@"无法访问通讯录")
                                                            message:YFCulture(@"访问通讯录是为了将上海车赢的官方客服电话添加到您的通讯录中，用来识别诈骗电话冒充车赢客服或用户来扰。车赢App遵从用户隐私协议，不会将您的通讯录信息私自上传到服务器。")
                                                           delegate:[AYCommon shareCommon]
                                                  cancelButtonTitle:YFCulture(@"设置")
                                                  otherButtonTitles:YFCulture(@"取消"), nil];
            alert.tag = 0x10000;
            [alert show];
            CFRelease(addressBook);
            return;
        }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
            __block BOOL tip = NO;
            //创建一个出事信号量为0的信号
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool greanted, CFErrorRef error)        {
                //greanted为YES是表示用户允许，否则为不允许
                if (!greanted) {
                    tip = YES;
                }
                //发送一次信号
                dispatch_semaphore_signal(sema);
            });
            //等待信号触发
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if (tip) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:YFCulture(@"无法访问通讯录")
                                                                message:YFCulture(@"访问通讯录是为了将上海车赢的官方客服电话添加到您的通讯录中，用来识别诈骗电话冒充车赢客服或用户来扰。车赢App遵从用户隐私协议，不会将您的通讯录信息私自上传到服务器。")
                                                               delegate:[AYCommon shareCommon]
                                                      cancelButtonTitle:YFCulture(@"设置")
                                                      otherButtonTitles:YFCulture(@"取消"), nil];
                alert.tag = 0x10000;
                [alert show];
                CFRelease(addressBook);
                return;
            }
        }
        
        //创建一条新的联系人纪录
        ABRecordRef newRecord = ABPersonCreate();
        
        //为新联系人记录添加属性值
        ABRecordSetValue(newRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)YFCulture(@"上海车赢信息技术有限公司"), &error);
        ABRecordSetValue(newRecord, kABPersonNicknameProperty, (__bridge CFTypeRef)YFCulture(@"上海车赢"), &error);
        
        //创建一个多值属性
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);

        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)@"021-55669167", (__bridge CFStringRef)YFCulture(@"工作电话"), NULL);
   
        ABPersonSetImageData(newRecord, (__bridge CFDataRef)(UIImagePNGRepresentation([UIImage imageNamed:@"shareIcon"])), NULL);
        
        //将多值属性添加到记录
        ABRecordSetValue(newRecord, kABPersonPhoneProperty, multi, &error);
        CFRelease(multi);
        
        ABMutableMultiValueRef urlti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(urlti, (__bridge CFTypeRef)@"http://www.carwins.com.cn", kABPersonHomePageLabel, NULL);
        ABRecordSetValue(newRecord, kABPersonURLProperty, urlti, &error);
        
        ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:YFCulture(@"中国") forKey:(__bridge NSString *)kABPersonAddressCountryKey];
        [dict setObject:YFCulture(@"上海") forKey:(__bridge NSString *)kABPersonAddressStateKey];
        [dict setObject:YFCulture(@"上海市") forKey:(__bridge NSString *)kABPersonAddressCityKey];
        [dict setObject:YFCulture(@"黄浦区鲁班路600号16楼") forKey:(__bridge NSString *)kABPersonAddressStreetKey];
        [dict setObject:@"200023" forKey:(__bridge NSString *)kABPersonAddressZIPKey];
        
        ABMultiValueAddValueAndLabel(multiAddress, (__bridge CFTypeRef)(dict), kABWorkLabel, NULL);
        ABRecordSetValue(newRecord, kABPersonAddressProperty, multiAddress, &error);
        CFRelease(multiAddress);
        
        //根据字符串查找前缀关键字
        CFStringRef cfSearchText = (CFStringRef)CFBridgingRetain(YFCulture(@"上海车赢"));
        CFArrayRef listContacts = ABAddressBookCopyPeopleWithName(addressBook, cfSearchText);
        CFRelease(cfSearchText);
        
        BOOL isExist = NO;
        for (NSInteger i=0; i<CFArrayGetCount(listContacts); i++) {
            ABRecordRef person          = CFArrayGetValueAtIndex(listContacts, i);
            NSData      *imageData      = (__bridge NSData *)(ABPersonCopyImageData(person));
            NSString    *organization   = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonOrganizationProperty));
            NSString    *nickName       = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonNicknameProperty));
            NSString    *firstName      = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            ABMultiValueRef phones      = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
                NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
                
                if ([phone isEqualToString:@"021-55669167"] &&
                    [organization isEqualToString:YFCulture(@"上海车赢信息技术有限公司")] &&
                    (int)ABMultiValueGetCount(phones)>1 &&
                    [nickName isEqualToString:YFCulture(@"上海车赢")] &&
                    imageData != nil &&
                    firstName.length == 0)
                {
                    isExist = YES;
                    break;
                }
            }

        }
        
        if (isExist) {
            DLog(@"已存在");
        }else{
            //添加记录到通讯录操作对象
            ABAddressBookAddRecord(addressBook, newRecord, &error);
        }
        
        //保存通讯录操作对象
        ABAddressBookSave(addressBook, &error);
        CFRelease(newRecord);
        CFRelease(addressBook);
    }else{
        
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied ||
            [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusRestricted) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:YFCulture(@"无法访问通讯录")
                                                            message:YFCulture(@"访问通讯录是为了将上海车赢的官方客服电话添加到您的通讯录中，用来识别诈骗电话冒充车赢客服或用户来扰。车赢App遵从用户隐私协议，不会将您的通讯录信息私自上传到服务器。")
                                                           delegate:[AYCommon shareCommon]
                                                  cancelButtonTitle:YFCulture(@"设置")
                                                  otherButtonTitles:YFCulture(@"取消"), nil];
            alert.tag = 0x10000;
            
            [alert show];
            return;
        }
        
        CNContactStore * store = [[CNContactStore alloc]init];
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        
        contact.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"shareIcon"]);
        contact.nickname = YFCulture(@"上海车赢");
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[CNLabeledValue labeledValueWithLabel:YFCulture(@"工作电话") value:[CNPhoneNumber phoneNumberWithStringValue:@"021-55669167"]]];

        contact.phoneNumbers = array;
        contact.organizationName = YFCulture(@"上海车赢信息技术有限公司");
        
        CNMutablePostalAddress * workAdress = [[CNMutablePostalAddress alloc] init];
        workAdress.street = YFCulture(@"黄浦区鲁班路600号16楼");
        workAdress.city = YFCulture(@"上海市");
        workAdress.state = YFCulture(@"上海");
        workAdress.country = YFCulture(@"中国");
        workAdress.postalCode = @"200023";
        contact.postalAddresses = @[[CNLabeledValue labeledValueWithLabel:CNLabelWork value:workAdress]];
        contact.urlAddresses = @[[CNLabeledValue labeledValueWithLabel:CNLabelURLAddressHomePage value:@"http://www.carwins.com.cn"]];
        
        //检索条件，检索所有名字中有zhang的联系人
        NSPredicate * predicate = [CNContact predicateForContactsMatchingName:YFCulture(@"上海车赢")];
        //提取数据
        NSArray * contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactGivenNameKey,CNContactNicknameKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey,CNContactImageDataKey] error:nil];
        BOOL isExist = NO;
#pragma mark -
        for (CNContact *person in contacts) {
            for (CNLabeledValue *lbValue in person.phoneNumbers) {
                CNPhoneNumber *phone = lbValue.value;
                if ([phone.stringValue isEqualToString:@"021-55669167"] &&
                    [person.organizationName isEqualToString:YFCulture(@"上海车赢信息技术有限公司")] &&
                    person.phoneNumbers.count>1 &&
                    [person.nickname isEqualToString:YFCulture(@"上海车赢")] &&
                    person.imageData != nil &&
                    person.givenName.length == 0)
                {
                    isExist = YES;
                    break;
                }
            }
        }
        
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
//#pragma mark - 此步为了清除多写的垃圾数据
//        NSMutableArray *lajiArray = [[NSMutableArray alloc] init];
//        for (CNContact *person in contacts) {
//            for (CNLabeledValue *lbValue in person.phoneNumbers) {
//                CNPhoneNumber *phone = lbValue.value;
//                if ([phone.stringValue isEqualToString:@"400-092-7600"] &&
//                    [person.organizationName isEqualToString:YFCulture(@"上海车赢信息技术有限公司")] &&
//                    person.phoneNumbers.count>1 &&
//                    [person.nickname isEqualToString:YFCulture(@"上海车赢")] &&
//                    person.imageData == nil &&
//                    person.givenName.length == 0)
//                {
//                    [lajiArray addObject:person];
//                    break;
//                }
//            }
//        }
//        
//        CNSaveRequest * saveRequest2 = [[CNSaveRequest alloc]init];
//        NSInteger lajiArraycount = lajiArray.count;
//        for (NSInteger i=0; i< lajiArraycount; i++) {
//            CNMutableContact *contact = lajiArray[i];
//            [saveRequest2 deleteContact:contact];
//        }
//        [store executeSaveRequest:saveRequest2 error:nil];
        if (isExist) {
            // 更新联系人
            [saveRequest updateContact:contact];
        }else {
            // 添加联系人
            [saveRequest addContact:contact toContainerWithIdentifier:nil];
        }
        
        // 写入联系人
        [store executeSaveRequest:saveRequest error:nil];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x10000) {
        if (buttonIndex == 0) {
//            if ([AYDeviceManager currentVersion]<8.0){
//                NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x70,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x49,0x4e,0x54,0x45,0x52,0x4e,0x45,0x54,0x5f,0x54,0x45,0x54,0x48,0x45,0x52,0x49,0x4e,0x47} length:29];
//                NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
//                NSURL *url = [NSURL URLWithString:string];
//                if (url != nil) {
//                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                        [[UIApplication sharedApplication] openURL:url];
//                    }
//                }
//
//            }else{
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            }
        }
    }
}

#pragma mark - 输入金额是小数点后面不能超过3位
+ (NSString *)returnFormatInputAmountOfMoney:(NSString *)momeyText
{
    if ([momeyText rangeOfString:@"."].location != NSNotFound) {
        NSRange range = [momeyText rangeOfString:@"."];
        if (momeyText.length - range.location > 3) {
            momeyText = [momeyText substringToIndex:range.location + 3];
        }
    }
    return momeyText;
}


+ (NSData *)getDataWithDictionary:(NSDictionary *)dict
{
    NSMutableData * data = [[NSMutableData alloc]init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"cacheData"];
    [archiver finishEncoding];
    return data;
}
//路径文件转dictonary
+ (NSDictionary *)getDictionaryWithDataPath:(NSString *)path
{
    NSData * data = [[NSMutableData alloc]initWithContentsOfFile:path];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSDictionary * myDictionary = [unarchiver decodeObjectForKey:@"cacheData"];
    [unarchiver finishDecoding];

    return myDictionary;
}

#pragma mark - 银行卡验证
+ (BOOL)validateBankCardNumber:(NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{15,30})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}
#pragma mark - 银行卡验证后四位
+ (BOOL)validateBankCardLastNumber:(NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length != 4) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{4})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}

/*!
 * @brief 把对象（Model）转换成字典
 * @param model 模型对象
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithModel:(id)model
{
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // 获取类名/根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    
    // 获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }
        
        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}

/**
 * 获取指定view的viewController
 */
- (UIViewController *)getViewControllerOfView:(UIView *)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 
- (NSString *)notRounding:(CGFloat)price
               afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
}


@end
