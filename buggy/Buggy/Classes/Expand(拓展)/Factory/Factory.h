//
//  Factory.h
//  Buggy
//
//  Created by 孟德林 on 16/9/13.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLabel.h"
#import "UIButtonHeader.h"

@interface Factory : NSObject

#pragma mark 工厂生产UIView
/**
 工厂生产        UIView

 @param frame   frame
 @param bgColor 背景颜色
 @param view    父视图
 @return        实例类
 */
+(UIView *)viewWithFrame:(CGRect)frame
                 bgColor:(UIColor *)bgColor
                  onView:(UIView *)view;


#pragma mark 工厂生产UILabel
/**
 工厂生产       UILabel

 @param frame frame
 @param font  字体（拓展类里有不同的字体类型）
 @param text
 @param textColor
 @param view  父视图
 @param textAlignment 默认居中
 @return      实例类
 */
+(UILabel *)labelWithFrame:(CGRect)frame
                      font:(UIFont *)font
                      text:(NSString *)text
                 textColor:(UIColor *)textColor
                    onView:(UIView *)view
             textAlignment:(NSTextAlignment)textAlignment;


/**
 工厂生产      屏幕宽度UILabel，高度根据text多少而定

 @param center 中心点
 @param font   字体（拓展类里有不同的字体类型）
 @param text
 @param textColor
 @param view   父视图
 @param finish 完成回调(UILabel)
 @return       实例类
 */
+(UILabel *)flabelWithCenter:(CGPoint)center
                        font:(UIFont *)font
                        text:(NSString *)text
                   textColor:(UIColor *)textColor
                      onView:(UIView *)view
             resetSizeFinish:(void(^)(UILabel *label))finish;


/**
 工厂生产      自己设定宽度UILabel，高度根据text多少而定

 @param width 自定义的宽度
 @param font  字体（拓展类里有不同的字体类型）
 @param text
 @param textColor
 @param view   父视图
 @param finish 完成回调(UILabel)
 @return       实例类
 */
+(UILabel *)flabelWithWidth:(CGFloat)width
                       font:(UIFont *)font text:(NSString *)text
                  textColor:(UIColor *)textColor
                     onView:(UIView *)view
            resetSizeFinish:(void(^)(UILabel *label))finish;




#pragma mark 工厂生产 UIImageView
+(UIImageView *)imageViewWithCenter:(CGPoint)center
                   imageRightHeight:(UIImage *)image
                             onView:(UIView *)view;
/**
 工厂生产      UIImageView

 @param center 自定义中心点，图片大小根据图片自身而定
 @param image  image
 @param view   父视图
 @return       实例类
 */
+(UIImageView *)imageViewWithCenter:(CGPoint)center
                              image:(UIImage *)image
                             onView:(UIView *)view;


/**
 工厂生产      UIImageView

 @param original 自定义起始点，图片大小根据图片自身而定
 @param image    image
 @param view     父视图
 @return         实例类
 */
+(UIImageView *)imageViewWithOriginal:(CGPoint)original
                                image:(UIImage *)image
                               onView:(UIView *)view;



/**
 工厂生产      UIImageView

 @param image image
 @param view  父视图
 @param position 回调
 @return         实例类
 */
+(UIImageView *)imageViewWithImage:(UIImage *)image
                            onView:(UIView *)view
                          position:(void(^)(UIImageView *imageView,CGSize size))position;


/**
 工厂生产      UIImageView

 @param frame 自定义Frame,图片完全适配当前尺寸，会进行部分拉伸或者压缩
 @param image image
 @param view  父视图
 @return      实例类
 */
+(UIImageView *)imageViewWithFrame:(CGRect)frame
                             image:(UIImage *)image
                            onView:(UIView *)view;

#pragma mark 工厂生产CALayer

/**
 工厂生产      CALyer

 @param image  在CALyer层上的image
 @param superLayer 父视图
 @param position   回调
 @return           实例类
 */
+(CALayer *)layerWithImage:(UIImage *)image
                   onLayer:(CALayer *)superLayer
                  position:(void(^)(CALayer *layer, CGSize size))position;



#pragma mark 工厂生产UITextField
/**
 工厂生产     UITextField

 @param frame Frame
 @param hide  字体是否可见
 @param text  水印字体
 @param view  父视图
 @return      实例类
 */
+(UITextField *)textFieldWithFrame:(CGRect)frame
                          hideText:(BOOL)hide
                       defaultText:(NSString *)text
                            onView:(UIView *)view;


#pragma mark 工厂生产UIButton

/**
 工厂生产      UIButton (拓展里可以自定义图片和文字的位置)

 @param frame frame
 @param imageName  图片背景 注:imageName不加后缀.png  highlight图片命名是在normal图片后加H 例 normal => go.png highlight => goH.png
 @param click
 @param view  父视图
 @return      实例类
 */
+(UIButton *)buttonWithFrame:(CGRect)frame
               withImageName:(NSString *)imageName
                       click:(void(^)(void))click
                      onView:(UIView *)view;


/**
 工厂生产     UIButton 设置图片

 @param center 自定义中心点
 @param image  button上图片
 @param click  点击
 @param view   父视图
 @return       实例类
 */
+(UIButton *)buttonWithCenter:(CGPoint)center
                    withImage:(UIImage *)image
                        click:(void(^)(void))click
                       onView:(UIView *)view;


/**
 工厂生产      UIButton 无图片，纯文字

 @param frame   frame
 @param bgColor 背景颜色
 @param title   text
 @param textColor 字体颜色
 @param click
 @param view    父视图
 @return        实例类
 */
+(UIButton *)buttonWithFrame:(CGRect)frame
                     bgColor:(UIColor *)bgColor
                       title:(NSString *)title
                   textColor:(UIColor *)textColor
                       click:(void(^)(void))click
                      onView:(UIView *)view;


/**
 工厂生产     UIButton 无图片和文字

 @param frame frame
 @param click
 @param view  父视图
 @return      实例类
 */
+(UIButton *)buttonEmptyWithFrame:(CGRect)frame
                            click:(void(^)(void))click
                           onView:(UIView *)view;


/**
 工厂生产    UIButton  无图片，纯文字，点击具有高亮效果

 @param frame    frame
 @param bgColor  背景颜色
 @param title    文字
 @param textColor 文字颜色
 @param click
 @param view     父视图
 @return         实例类
 */
+(UIButton *)buttonInsertTypeWithFrame:(CGRect)frame
                               bgColor:(UIColor *)bgColor
                                 title:(NSString *)title
                             textColor:(UIColor *)textColor
                                 click:(void (^)(void))click
                                onView:(UIView *)view;


+ (UIButton *)buttonTitle:(NSString *)title
                 fontSize:(CGFloat)fontSize
                    click:(void(^)(void))click
              normalColor:(UIColor *)normalColor
         highlightedColor:(UIColor *)highlightedColor
      backgroundImageName:(NSString *)backgroundImageName;

/**
 *  工厂生产UINavigationController
 */
+(UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)viewController;

+(UIBarButtonItem *)costomBackBarWithTitle:(NSString *)title
                                     click:(void (^)(void))click
                                    isback:(BOOL)isback;


@end
