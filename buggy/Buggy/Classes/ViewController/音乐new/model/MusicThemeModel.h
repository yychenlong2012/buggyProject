//
//  MusicThemeModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicThemeModel : NSObject

/**
 主题
 */
@property (nonatomic ,copy) NSString *themeTitle;

/**
 主题模板颜色
 */
@property (nonatomic ,copy) NSString *themeColor;

/**
 主题颜色的透明度
 */
@property (nonatomic ,assign) NSInteger themeColorOpacity;

/**
 主题的图片
 */
@property (nonatomic ,strong) AVFile *themeImage;

/**
 主题副标题
 */
@property (nonatomic ,copy) NSString *themeDetails;

/**
 主题的类型
 */
@property (nonatomic ,copy) NSString *themeType;  // 1、儿歌  2、古诗   3、故事  4、英语 5、三字经

@end
