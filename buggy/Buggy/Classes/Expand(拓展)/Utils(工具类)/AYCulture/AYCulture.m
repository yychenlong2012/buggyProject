//
//  YFCulture.m
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//

#import "AYCulture.h"

#define kLMSelectedLanguageKey  @"kLMSelectedLanguageKey"

@implementation AYCulture

//在此处设置App所支持的系统语言  可以拓展
+ (BOOL)isSupportedLanguage:(NSString*)language {
    
    if ([language isEqualToString:kLMEnglish]) {
        return YES;
    }
    if ([language isEqualToString:kLMEnglish2]) {
        return YES;
    }
    if ([language isEqualToString:kLMChinese]) {
        return YES;
    }
    
    if ([language isEqualToString:kLMChinese2]) {
        return YES;
    }
    
    if ([language hasPrefix:kLMChinese]) {
        return YES;
    }
    
    if ([language hasPrefix:kLMEnglish]) {
        return YES;
    }
    
    return NO;
}

//外面调用  结合InfoPlist.strings使用
+ (NSString *)localizedString:(NSString *)key {
    
    NSString *selectedLanguage = [AYCulture getPreferredLanguage];
    
    if ([selectedLanguage hasPrefix:kLMChinese]) {
        selectedLanguage = kLMChinese;
    }else if ([selectedLanguage hasPrefix:kLMEnglish]){
        selectedLanguage = kLMEnglish;
    }
    
    //获取当前语言文件的 bundle path.
    NSString *path = [[NSBundle mainBundle] pathForResource:selectedLanguage ofType:@"lproj"];
    
    //获取当前的strings文件.
    NSBundle * languageBundle = [NSBundle bundleWithPath:path];
    NSString * str = [languageBundle localizedStringForKey:key value:@"" table:@"InfoPlist"];
    return str;
}

//设置选择的语言到本地userDefaults
+ (void)setSelectedLanguage:(NSString *)language {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //判断语言App是否支持.
    if ( [self isSupportedLanguage:language] ) {
        [userDefaults setObject:language forKey:kLMSelectedLanguageKey];
    } else {
        //如果不支持 将语言设置为nil
        [userDefaults setObject:nil forKey:kLMSelectedLanguageKey];
    }
    [userDefaults synchronize];
}

+ (NSString *)selectedLanguage {
    //从user defaults中无处选择的语言.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedLanguage = [userDefaults stringForKey:kLMSelectedLanguageKey];
    NSArray *userLangs = [userDefaults objectForKey:@"AppleLanguages"];
    NSString *systemLanguage = [userLangs objectAtIndex:0];
    //判断是否已经选择支持语言
    if (selectedLanguage == nil) {
        //获取系统语言
        // 如果系统语言App支持,将选择系统语言
        if ( [self isSupportedLanguage:systemLanguage] ) {
            [self setSelectedLanguage:systemLanguage];
            //否则
        } else {
            //设置默认语言作为选择语言
            [self setSelectedLanguage:kLMDefaultLanguage];
        }
    }
    return [userDefaults stringForKey:kLMSelectedLanguageKey];
}

+ (NSString *)getPreferredLanguage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [userDefaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
//    DLog(@"当前语言:%@",preferredLang);
    if ( [self isSupportedLanguage:preferredLang] ) {
        return preferredLang;
    }else{
        NSString * flag  = [userDefaults objectForKey:@"SelectLanguageTip"];
        if (flag.boolValue == NO) {
            [self alert:@"Your system language does not support!App will set 'English' as selected language."];
            [userDefaults setObject:@"1" forKey:@"SelectLanguageTip"];
            [userDefaults synchronize];
        }
        return kLMDefaultLanguage;
    }
}

+ (void)alert:(NSString *)massage
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notice" message:massage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  判断系统语言是否是中文
 */
+ (BOOL)isChinese
{
    return ([[AYCulture getPreferredLanguage] isEqualToString:kLMChinese] || [[AYCulture getPreferredLanguage] isEqualToString:kLMChinese2])?YES:NO;
}

@end
