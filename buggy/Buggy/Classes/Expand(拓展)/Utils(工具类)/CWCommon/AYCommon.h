//
//  CWCommon.h
//  CarWins
//
//  Created by zheng on 16/3/22.
//  Copyright © 2016年 CarWins Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import <EventKit/EventKit.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#define ISPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface AYCommon : NSObject <UIAlertViewDelegate>

+ (AYCommon *)shareCommon;

/** 判断是否为整形： */
+ (BOOL)isPureInt:(NSString*)string;
/** 判断是否为浮点形： */
+ (BOOL)isPureFloat:(NSString*)string;
/** 判断是否是新版本 */
+ (BOOL)isNewVersion:(NSString *)newVer ver2:(NSString *)oldVer;
/** 获取文本高度 */
+ (CGFloat)getTextHeight:(NSString *)string;
/** 获取文本宽度 */
+ (CGFloat)getTextWidth:(NSString *)string;
/** 获取文本高度 */
+ (CGFloat)getTextHeight:(NSString *)string
            fontSize:(CGFloat)size
           viewWidth:(CGFloat)width;
+ (CGFloat)getLabelHeight:(NSString *)string
                 fontSize:(CGFloat)size
                viewWidth:(CGFloat)width;
+ (CGFloat) getLabelHeight:(NSString *)string
              boldFontSize:(CGFloat)size
                 viewWidth:(CGFloat)width;
+ (CGFloat)getLabelWidth:(NSString *)string
            fontSize:(CGFloat)size;
+ (CGFloat)getLabelWidthForBoldFont:(NSString *)string
                       fontSize:(CGFloat)size;

+ (CGFloat)getStringHeight:(NSString *)str
            withFontSize:(CGFloat)fontSize
                    bold:(BOOL)_bold
              labelWidth:(CGFloat)waith;
/** 根据固定的高度获取文本宽度;传UILabel */
+ (CGRect)getLabelWidthForString:(UILabel *)strLabel;
/** 根据固定的宽度获取文本高度;传UILabel */
+ (CGRect)getLabelHeightForString:(UILabel *)strLabel;
/** 获取宽度>iOS7.0*/
+ (CGFloat)getWidthForString:(NSString *)string fontSize:(CGFloat)size viewHeight:(CGFloat)height;
/** 获取高度>iOS7.0*/
+ (CGFloat)getHeightForString:(NSString *)string fontSize:(CGFloat)size viewWidth:(CGFloat)width;

/**
 *  用“,”分割字符串
 *
 *  @param array 字符串数组
 *
 *  @return 拼接后的字符串
 */
+ (NSString *)getStringFromArray:(NSArray *)array;

/**
 *  获取评分对应图片 0-－5
 *
 *  @param evaluate 评分
 *
 *  @return 评分图片
 */
+ (UIImage *)getImageByScore:(NSInteger)score;

/**
 *  根据颜色创建图片
 *
 *  @param color color
 *
 *  @return image
 */
+ (UIImage *)createImageWithColor: (UIColor *) color;

/**
 *  获取App版本号
 *
 *  @return 版本号
 */
+ (NSString *)getAppVersion;

#pragma mark camera utility
/**
 *  验证相机是否可用
 */
+ (BOOL)isCameraAvailable;
/**
 *  验证后置相机是否可用
 */
+ (BOOL)isRearCameraAvailable;
/**
 *  验证前置相机是否可用
 */
+ (BOOL)isFrontCameraAvailable;
/**
 *  验证拍照功能是否可用
 */
+ (BOOL)doesCameraSupportTakingPhotos;
/**
 *  验证相册是否可用
 */
+ (BOOL)isPhotoLibraryAvailable;

/**
 *  验证相册模式下能否摄像
 */
+ (BOOL)canUserPickVideosFromPhotoLibrary;
/**
 *  验证相册模式下能否拍照
 */
+ (BOOL)canUserPickPhotosFromPhotoLibrary;
/**
 *  验证指定模式下是否支持某种媒体类型
 */
+ (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;

/**
 *  将图片缩放到指定大小
 */
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;
/**
 *  将图片缩放到最大大小 （width：640）
 */
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

/**
 *  根据frame 获取一个圆形的imageView
 */
+ (UIImageView *)getRoundImageViewWithFrame:(CGRect)frame;

/**
 *  在指定文本中设置指定文字的颜色
 */
+ (NSAttributedString *)getAttributedStr:(NSString *)keyWord
                                inString:(NSString *)string
                          highlightColor:(UIColor *)color;
/**
 *  在指定文本中设置指定文字的字体
 */
+ (NSAttributedString *)getAttributedStr:(NSString *)keyWord
                                inString:(NSString *)string
                                    font:(UIFont *)font;

/**
 *  去html标签
 */
+ (NSString *)filterHTML:(NSString *)html;

/**
 *  字符串拼接Html
 */
+ (NSMutableString *)getHtmlString:(NSString *)str;

#pragma mark 图片处理
/**
 *  把图片切成菱形
 */
+ (UIImage *)clipImage:(UIImage *)sourceImage;

/**
 *  在程序中如何把两张图片合成为一张图片
 */
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

/**
 *  根据URL获取图片
 */
+ (UIImage *)getImageFromURL:(NSString *)fileURL;

#pragma mark - 验证字段
/**
 *  验证邮箱
 */
+ (BOOL)isValidateEmail:(NSString *)email;
/**
 *  验证手机号
 */
+ (BOOL)isValidateMobile:(NSString *)mobile;

/**
 *  验证车牌号
 */
+ (BOOL)isValidateCarNumber:(NSString *)carNum;


#pragma mark - lijianfan  2016/4/18
/**
 *  vin码验证
 */
+ (BOOL)isValidVinCode:(NSString *)VinCode;

/**
 *  银行卡验证
 */
+ (BOOL)validateBankCardNumber:(NSString *)bankCardNumber;

/**
 *  银行卡验证后4位
 */
+ (BOOL)validateBankCardLastNumber:(NSString *)bankCardNumber;

/**
 *  用指定字符分割关键字
 */
+ (NSString *)getKeywordsFromText:(NSString *)keywordsText
                        withSplit:(NSString *)split;
/**
 *  用指定字符替换连词分割关键字
 */
+ (NSString *)getKeywordsFromText:(NSString *)keywordsText
       replaceConjStringWithSplit:(NSString *)split;

/**
 *  创建定时器
 */
+ (void)createTimer:(UIButton *)btn andTime:(int)times andEndBackgroundColor:(UIColor *)color;
/**
 *  从二进制文件中动态获取图片格式
 *
 *  @param data 图片的二进制
 *
 *  @return 图片的类型 如: jpg
 */
+ (NSString *)getImageTypeForImageData:(NSData *)data;
/**
 *  获取图片的mimeType
 */
+ (NSString *)getImageMineTypeForImageData:(NSData *)data;

/**
 *  遍历文件夹获得文件夹大小，返回多少M
 */
+ (CGFloat)folderSizeAtPath:(NSString *)folderPath;
/**
 *  单个文件的大小 返回多少K
 */
+ (CGFloat)fileSizeAtPath:(NSString *)filePath;
/**
 *  截取指定大小的图片   size = CGSizeMake(image.width/4,image.height/4) 实现等比例缩放4倍
 */
+ (UIImage *)scaleFromImage:(UIImage *)image size:(CGSize)size;
/**
 *  播放音乐
 *
 *  @param name 音乐文件名
 *  @param type 文件类型
 */
+ (void)playSoundWithName:(NSString *)name type:(NSString *)type;

/**
 *  将事件和提醒添加到系统日历
 *
 *  @param title        事件和提醒标题
 *  @param location     location description
 *  @param startDate    开始时间
 *  @param endDate      结束事件
 *  @param completeDate 完成时间
 *  @param allDay       是否全天
 *  @param alarmArray   闹钟提醒时间数组 为 nil 则取默认 事件前15min/5min/当前
 */
+ (void)saveEventWithTitle:(NSString *)title
                  location:(NSString *)location
                 startDate:(NSDate *)startDate
                   endDate:(NSDate *)endDate
              completeDate:(NSDate *)completeDate
                    allDay:(BOOL)allDay
                alarmArray:(NSArray <EKAlarm *> *)alarmArray;

/**
 *  将官方常用号码写入用户通讯录
 */
+ (void)creatNewRecord;

/**
 *  输入金额是小数点后面不能超过3位
 */
+ (NSString *)returnFormatInputAmountOfMoney:(NSString *)momeyText;

/**
 *  根据NSDictionary转换成NSData
 *
 *  @param dict NSDictionary
 *
 *  @return NSData
 */
+ (NSData *)getDataWithDictionary:(NSDictionary *)dict;

/**
 *  根据本地NSData文件路径获取NSDictionary
 *
 *  @param path NSData文件路径
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)getDictionaryWithDataPath:(NSString *)path;

/*!
 * @brief 把对象（Model）转换成字典
 * @param model 模型对象
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithModel:(id)model;

/**
 * 获取指定view的viewController
 */
- (UIViewController *)getViewControllerOfView:(UIView *)view;
/**
 *  价格保留几位小数，但只舍不入
 */
- (NSString *)notRounding:(CGFloat)price
               afterPoint:(int)position;

@end
