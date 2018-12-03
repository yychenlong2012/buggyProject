//
//  AlertManager.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/2.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYPE_VIEW){
    
    TYPE_VIEW_ALERT = 1217,
    TYPE_VIEW_POPUP,
    TYPE_VIEW_MOMENT,
};
typedef void(^IndexBlock)(NSInteger index);

@interface AlertManager : NSObject

@property (nonatomic ,copy) IndexBlock indexBlock;
@property (nonatomic ,assign) BOOL isGuardOpen;     //是否开启了一键防盗功能
@property (nonatomic ,assign) BOOL haveNewVersion;  //有新版本

#pragma mark --- 提示信息

- (void)showAlertMessage:(NSString *)message title:(NSString *)title cancle:(NSString *)cancle confirm:(NSString *)confirm others:(NSArray<NSString *> *)others;


#pragma mark --- 功能列表

- (void)showFunctionList:(NSArray *)imageList titleList:(NSArray *)titleList IndexBlock:(IndexBlock)index;

#pragma mark --- 展示和消失

- (void)show;

- (void)dismiss;
@end
