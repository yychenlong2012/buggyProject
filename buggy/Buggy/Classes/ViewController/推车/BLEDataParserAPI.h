//
//  BLEDataParserAPI.h
//  Buggy
//
//  Created by 孟德林 on 2016/12/20.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarHelper.h"

@protocol BLEDataParserDelegate <NSObject>

@optional
/**
 上传数据，并从新获服务器数据

 @param parm 上传的参数（为字典格式）
 */
- (void)G_postTravel:(NSDictionary *)parm;

/**
 更行宝宝的体重信息

 @param babyHeight 宝宝体重
 */
- (void)G_refreshBabyWeight:(NSString *)babyWeight;

/**
 向蓝牙设备发送信息

 @param time 发送内容
 */
- (void)G_sendDataToBLEDevice:(NSString *)time;


/**
 更新温度

 @param Temperature 温度
 */
- (void)G_refreshTemperature:(NSString *)Temperature;

//12月2号更改的内容 上面的代理将废弃
-(void)updateTemperatureAndBattery;
-(void)updateAverageSpeed;



@end


@interface BLEDataParserAPI : NSObject


#pragma mark --- 高景观车专用
+(instancetype)shareInstance;
/**
 解析数据(高景观车专用数据解析API)

 @param dataStr 要解析的字符串
 */
- (void)G_parserData:(NSString *)dataStr;


@property (nonatomic ,weak) id<BLEDataParserDelegate> delegate;

@end
