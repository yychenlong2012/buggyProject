//
//  pushDataAPI.h
//  Buggy
//
//  Created by goat on 2018/5/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarA4PushDataModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface pushDataAPI : NSObject

@property(nonatomic,strong) NSMutableArray<CarA4PushDataModel *> *pushDateArray;  //存放需要上传的数据

+ (instancetype)sharedInstance;

-(void)startUploadPushData;   //开始上传数据

//-(void)uploadLoadPushDataInBackGround:(CarA4PushDataModel *)model;

//上传本地记录   分段数据
-(void)uploadLocalData;

//上传一天的数据 日里程
//+(void)uploadDaysMileage:(NSInteger)mileage;

//上传总里程 、、、、、
//+(void)uploadTodayMileage:(NSInteger)todayMileage TotalMileage:(CGFloat)totalMileage averageSpeed:(CGFloat)averageSpeed;

//上传蓝牙板子内部数据  关机次数 睡眠次数、、
+(void)uploadSmartBrakeNum:(int)smartBrakeNum autoBrakeNum:(int)autoBrakeNum sleepNum:(int)sleepNum shutdownNum:(int)shutdownNum peri:(CBPeripheral *)peri;

//上传刹车灵敏度
+(void)uploadBrakeSensitivity:(NSInteger)sensitivity;
@end
