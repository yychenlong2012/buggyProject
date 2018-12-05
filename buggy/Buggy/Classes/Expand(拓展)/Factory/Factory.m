//
//  Factory.m
//  Buggy
//
//  Created by 孟德林 on 16/9/13.
//  Copyright © 2016年 ningwu. All rights reserved.
//
#import "Factory.h"
#import "NSObject+Block.h"
#import "UIButton+MAC.h"

#define BUTTON_IMAGE(_button_,_image_)   \
[_button_ setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@H.png",_image_]] forState:UIControlStateHighlighted]; \
[_button_ setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_image_]] forState:UIControlStateNormal];

@implementation Factory

+(UIView *)viewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor onView:(UIView *)view{
    UIView *vv = [[UIView alloc] initWithFrame:frame];
    if (bgColor) vv.backgroundColor = bgColor;
    if (view) [view addSubview:vv];
    return vv;
}

+(UIImageView *)imageViewWithFrame:(CGRect)frame image:(UIImage *)image onView:(UIView *)view{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:frame];
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    if (image) imageV.image = image;
    if (view) [view addSubview:imageV];
    return imageV;
}

+(UIImageView *)imageViewWithCenter:(CGPoint)center image:(UIImage *)image onView:(UIView *)view{
    return [Factory imageViewWithFrame:(CGRect){{center.x - image.size.width/2,center.y - image.size.height/2},image.size} image:image onView:view];
}

+(UIImageView *)imageViewWithCenter:(CGPoint)center imageRightHeight:(UIImage *)image onView:(UIView *)view{
    return [Factory imageViewWithFrame:(CGRect){{center.x - RealWidth(image.size.width)/2,center.y - image.size.height/2},RealWidth(image.size.width),RealHeight(image.size.height)} image:image onView:view];
}

+(UIImageView *)imageViewWithOriginal:(CGPoint)original image:(UIImage *)image onView:(UIView *)view{
    return [Factory imageViewWithFrame:(CGRect){original,image.size} image:image onView:view];
}

+(UIImageView *)imageViewWithImage:(UIImage *)image onView:(UIView *)view position:(void (^)(UIImageView *, CGSize))position{
    UIImageView *imageV = [Factory imageViewWithOriginal:CGPointMake(0, 0) image:image onView:view];
    if (position) position(imageV,image.size);
    return imageV;
}

+(CALayer *)layerWithImage:(UIImage *)image onLayer:(CALayer*)superLayer position:(void (^)(CALayer *, CGSize))position{
    CALayer *layer = [CALayer layer];
    layer.contents = (id)image.CGImage;
    layer.bounds = (CGRect){{0,0},image.size};
    [superLayer addSublayer:layer];
    if (position) position(layer, image.size);
    return layer;
}

+(UILabel *)labelWithFrame:(CGRect)frame font:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor onView:(UIView *)view textAlignment:(NSTextAlignment)textAlignment{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = textAlignment;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.font = font;
    if (text) [label setText:text];
    if (textColor) label.textColor = textColor;
    if (view) [view addSubview:label];
    return label;
}

+(UILabel *)flabelWithCenter:(CGPoint)center font:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor onView:(UIView *)view resetSizeFinish:(void (^)(UILabel *))finish{
    
    FLabel *flabel = [[FLabel alloc] initWithMaxWidth:ScreenWidth resetSizeFinish:^(UILabel *label) {
        label.center = center;
        if (finish) {
            finish(label);
        }
    }];
    if (font) flabel.font = font;
    if (text) flabel.text = text;
    if (textColor) flabel.textColor = textColor;
    if (view) [view addSubview:flabel];
    
    return flabel;
}

+(UILabel *)flabelWithWidth:(CGFloat)width font:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor onView:(UIView *)view resetSizeFinish:(void (^)(UILabel *))finish{
    FLabel *flabel = [[FLabel alloc] initWithMaxWidth:width resetSizeFinish:^(UILabel *label) {
        if (finish) {
            finish(label);
        }
    }];
    if (font) flabel.font = font;
    if (text) flabel.text = text;
    if (textColor) flabel.textColor = textColor;
    if (view) [view addSubview:flabel];
    
    return flabel;
}

+(UITextField *)textFieldWithFrame:(CGRect)frame hideText:(BOOL)hide defaultText:(NSString *)text onView:(UIView *)view{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.secureTextEntry = hide;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.placeholder = text;
    textField.font = FONT_TEXTFIELD;
    if (view) [view addSubview:textField];
    return textField;
}

+(UIButton *)buttonWithFrame:(CGRect)frame withImageName:(NSString *)imageName click:(void (^)())click onView:(UIView *)view{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    if (imageName) {
        BUTTON_IMAGE(button, imageName);
    }
    [button setExclusiveTouch:YES];
    [button lf_setEnlargeEdge:22];
    if (click) [button onlyHangdleUIControlEvent:UIControlEventTouchUpInside withBlock:click];
    if (view) [view addSubview:button];
    return button;
}

+(UIButton *)buttonWithCenter:(CGPoint)center withImage:(UIImage *)image click:(void (^)())click onView:(UIView *)view{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    button.center = center;
    [button setImage:image forState:UIControlStateNormal];
    [button setExclusiveTouch:YES];
    [button lf_setEnlargeEdge:22];
    if (click) [button onlyHangdleUIControlEvent:UIControlEventTouchUpInside withBlock:click];
    if (view) [view addSubview:button];
    return button;
}

+(UIButton *)buttonWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor title:(NSString *)title textColor:(UIColor *)textColor click:(void (^)())click onView:(UIView *)view{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    if(title){
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = FONT_BUTTON;
    }
    [button setExclusiveTouch:YES];
    [button lf_setEnlargeEdge:22];
    if (bgColor) [button setBackgroundColor:bgColor];
    if (textColor) [button setTitleColor:textColor forState:UIControlStateNormal];
    if (click) [button onlyHangdleUIControlEvent:UIControlEventTouchUpInside withBlock:click];
    if (view) [view addSubview:button];
    return button;
}

+(UIButton *)buttonEmptyWithFrame:(CGRect)frame click:(void (^)())click onView:(UIView *)view{
    return [Factory buttonWithFrame:frame bgColor:[UIColor clearColor] title:nil textColor:nil click:click onView:view];
}

+(UIButton *)buttonInsertTypeWithFrame:(CGRect)frame
                               bgColor:(UIColor *)bgColor
                                 title:(NSString *)title
                             textColor:(UIColor *)textColor
                                 click:(void (^)())click
                                onView:(UIView *)view{
//    UIButton *button = [Factory buttonWithFrame:frame bgColor:bgColor title:title textColor:textColor click:click onView:view];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    return button;
}

+(UIButton *)buttonTitle:(NSString *)title fontSize:(CGFloat)fontSize click:(void(^)())click normalColor:(UIColor *)normalColor highlightedColor:(UIColor *)highlightedColor backgroundImageName:(NSString *)backgroundImageName {
    
    UIButton *button = [[UIButton alloc] init];
    if (title) [button setTitle:title forState:UIControlStateNormal];
    if (normalColor)  [button setTitleColor:normalColor forState:UIControlStateNormal];
    if (highlightedColor)  [button setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    if (title)  button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    if (backgroundImageName != nil) {
        [button setBackgroundImage:[UIImage imageNamed:backgroundImageName] forState:UIControlStateNormal];
        NSString *backgroundImageNameHL = [backgroundImageName stringByAppendingString:@"_highlighted"];
        [button setBackgroundImage:[UIImage imageNamed:backgroundImageNameHL] forState:UIControlStateHighlighted];
    }
    [button setExclusiveTouch:YES];
    [button lf_setEnlargeEdge:22];
    if (click) [button onlyHangdleUIControlEvent:UIControlEventTouchUpInside withBlock:click];
    [button sizeToFit];
    return button;
}

+(UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)viewController{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [nav.navigationBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            [obj setHidden:YES];
        }
    }];
    return nav;
}

+(UIBarButtonItem *)costomBackBarWithTitle:(NSString *)title
                                    click:(void (^)())click
                                    isback:(BOOL)isback
{
    UIButton *buttton = [Factory buttonTitle:title fontSize:16 click:click normalColor:[UIColor whiteColor] highlightedColor:[UIColor darkGrayColor] backgroundImageName:nil];
    if (isback) {
        [buttton setImage:[UIImage imageNamed:@"top_btn_back_nor"] forState:UIControlStateNormal];
//        [buttton setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    }
    [buttton sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:buttton];
}


@end
