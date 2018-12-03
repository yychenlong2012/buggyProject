//
//  YFCulture.h
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 *  国际化 调用时直接使用 YFCulture(key)即可
 *
 *  @param str 要国际化的文字内容
 *
 *  @return 国际化后的文字内容
 */
#define YFCulture(str) str

#define kLMDefaultLanguage  @"en"
#define kLMEnglish          @"en"
#define kLMEnglish2         @"en-CN"
#define kLMChinese          @"zh-Hans"
#define kLMChinese2         @"zh-Hans-CN"

@interface AYCulture : NSObject {
    
}

/**
 *  判断App是否支持该语言
 *
 *  @param language 该语言
 *
 *  @return Bool
 */
+ (BOOL)isSupportedLanguage:(NSString *)language;
/**
 *  语言本地化
 *
 *  @param key 需要本地化的文字
 *
 *  @return 本地化后的文字
 */
+ (NSString *)localizedString:(NSString *) key;
+ (void)setSelectedLanguage:(NSString *)language;
+ (NSString *)selectedLanguage;
+ (NSString *)getPreferredLanguage;

/**
 *  判断系统语言是否是中文
 */
+ (BOOL)isChinese;

@end
