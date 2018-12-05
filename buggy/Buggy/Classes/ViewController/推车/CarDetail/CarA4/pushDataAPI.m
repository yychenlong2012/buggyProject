//
//  pushDataAPI.m
//  Buggy
//
//  Created by goat on 2018/5/23.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "pushDataAPI.h"
#import "NetWorkStatus.h"
#import "BlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface pushDataAPI()
@property(nonatomic,assign) BOOL isUploading;  //是否正在上传
@end
@implementation pushDataAPI
+ (instancetype)sharedInstance {
    static id sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
-(instancetype)init{
    if (self = [super init]) {
        self.pushDateArray = [NSMutableArray array];
        self.isUploading = NO;
    }
    return self;
}
- (id)copyWithZone:(NSZone*)zone{
    return self;
}

#pragma mark - 上传推行数据最开始的版本 一条一条上传
-(void)startUploadPushData{
    if (self.isUploading == NO) {  //如果没有开始上传则开始
        [self uploadFirstData];
    }
}

-(void)uploadFirstData{
    if (self.pushDateArray.count > 0) {
        self.isUploading = YES;
        CarA4PushDataModel *model = [self.pushDateArray firstObject];
        [self uploadLastPushDataWithData:model];
    }else{
        self.isUploading = NO;
    }
}

//上传推行数据
-(void)uploadPushDataWithData:(CarA4PushDataModel *)model{
    if(model.mileage <= 0){  //里程为0则不上传
        [self.pushDateArray removeObjectAtIndex:0];
        [self uploadFirstData];
        return;
    }
    NSDictionary *dict = @{    @"startTime":model.startTime,
                              @"endTime":model.endTime,
                              @"useTime":@(model.useTime),
                              @"mileage":@(model.mileage),
                              @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString };
    
    [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self.pushDateArray removeObjectAtIndex:0];   //上传成功则删除这条数据
            [self uploadFirstData];
        }else{
            //上传失败则保存数据到本地
            [self saveInLocal:model];
            [self.pushDateArray removeObjectAtIndex:0];
            [self uploadFirstData];
        }
    }];
}

//最后一条记录上传时做覆盖处理
-(void)uploadLastPushDataWithData:(CarA4PushDataModel *)model{
    if(model.mileage <= 0){  //里程为0则不上传
        [self.pushDateArray removeObjectAtIndex:0];
        [self uploadFirstData];
        return;
    }
    
    NSDictionary *dict = @{    @"startTime":model.startTime,
                               @"endTime":model.endTime,
                               @"useTime":@(model.useTime),
                               @"mileage":@(model.mileage),
                               @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString };
    
    [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self.pushDateArray removeObjectAtIndex:0];   //上传成功则删除这条数据
            [self uploadFirstData];
        }else{
            //上传失败则保存数据到本地
            [self saveInLocal:model];
            [self.pushDateArray removeObjectAtIndex:0];
            [self uploadFirstData];
        }
    }];
}

#pragma mark - 开线程上传  速度快
//-(void)uploadLoadPushDataInBackGround:(CarA4PushDataModel *)model{
//    NSLog(@"开始上传le");
//    if(model.mileage > 0){
//        AVQuery *query = [AVQuery queryWithClassName:@"TravelInfoOnce"];
//        [query whereKey:@"userId" equalTo:[AVUser currentUser]];
//        [query whereKey:@"startTime" equalTo:model.startTime];  //看是否有相同的记录 有则覆盖
//        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//            if (error == nil && object) {   //有相同记录
//                [object setObject:model.endTime forKey:@"endTime"];
//                [object setObject:@(model.mileage) forKey:@"mileage"];
//                [object setObject:@(model.useTime) forKey:@"useTime"];
//                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                    NSLog(@"是否成功 %d %@",succeeded,error);
//                    if (succeeded == NO && error != nil) {
//                        [self saveInLocal:model];//保存本地
//                    }
//                }];
//            }else{
//                if (object == nil && error.code == 101) {
//                    AVObject *obj = [AVObject objectWithClassName:@"TravelInfoOnce"];
//                    [obj setObject:[AVUser currentUser] forKey:@"userId"];
//                    [obj setObject:model.startTime forKey:@"startTime"];
//                    [obj setObject:model.endTime forKey:@"endTime"];
//                    [obj setObject:@(model.mileage) forKey:@"mileage"];
//                    [obj setObject:@(model.useTime) forKey:@"useTime"];
//                    if (BLEMANAGER.currentPeripheral != nil) {
//                        [obj setObject:BLEMANAGER.currentPeripheral.identifier.UUIDString forKey:@"bluetoothAddress"];
//                    }
//
//                    NSDateFormatter *form = [[NSDateFormatter alloc] init];
//                    form.dateFormat = @"YYYY-MM-dd";
//                    NSString *travelDate = [NSString stringWithFormat:@"%@ 00:00:00",[form stringFromDate:model.startTime]];
//                    form.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//                    [obj setObject:[form dateFromString:travelDate] forKey:@"travelDate"];
//                    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                        NSLog(@"是否成功 %d %@",succeeded,error);
//                        if (succeeded == NO && error != nil) {
//                            [self saveInLocal:model];//保存本地
//                        }
//                    }];
//                }else{
//                    [self saveInLocal:model];   //保存本地
//                }
//            }
//        }];
//    }
//}

#pragma mark - 上传失败保存本地
//保存到本地
-(void)saveInLocal:(CarA4PushDataModel *)model{
    NSLog(@"上传失败 保存到本地");
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@_PushData.plist",KUserDefualt_Get(USER_ID_NEW)];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    if (temp) {//有字典 则更新
        BOOL isRepeat = NO;
        for (NSDictionary *dict in temp) {
            if ([dict[@"startTime"] isEqualToString:[form stringFromDate:model.startTime]]) {
                isRepeat = YES;
            }
        }
        if (isRepeat == NO) {
            [temp addObject:@{@"startTime":[form stringFromDate:model.startTime],
                              @"endTime":[form stringFromDate:model.endTime],
                              @"mileage":@(model.mileage),
                              @"useTime":@(model.useTime) }];
        }
        array = temp;
    }else{
        temp = [NSMutableArray arrayWithArray:@[@{@"startTime":[form stringFromDate:model.startTime],
                                                  @"endTime":[form stringFromDate:model.endTime],
                                                  @"mileage":@(model.mileage),
                                                  @"useTime":@(model.useTime) }]];
        array = temp;
    }
//    BOOL success = [array writeToFile:filePath atomically:YES];
//    NSLog(@"是否保存成功%d",success);
}

//上传本地记录
-(void)uploadLocalData{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@_PushData.plist",KUserDefualt_Get(USER_ID_NEW)];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    
    if ([NetWorkStatus isNetworkEnvironment]) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
        if (temp != nil && temp.count>0) {
            for (NSDictionary *dict in temp) {
                
                CarA4PushDataModel *model = [[CarA4PushDataModel alloc] init];
                model.startTime = [form dateFromString:dict[@"startTime"]];
                model.endTime = [form dateFromString:dict[@"endTime"]];
                model.mileage = [dict[@"mileage"] integerValue];
                model.useTime = [dict[@"useTime"] integerValue];
                
                [self.pushDateArray addObject:model];
            }
        }
        [self startUploadPushData];
        [temp removeAllObjects];
        [temp writeToFile:filePath atomically:YES];
    }
}

//上传蓝牙板子内部数据  关机次数 睡眠次数、、
+(void)uploadSmartBrakeNum:(int)smartBrakeNum autoBrakeNum:(int)autoBrakeNum sleepNum:(int)sleepNum shutdownNum:(int)shutdownNum peri:(CBPeripheral *)peri{
    if (peri) {
        NSDictionary *parma = @{   @"bluetoothDeviceId":peri.identifier.UUIDString,
                                   @"aiBrakeTimes":@(smartBrakeNum),
                                   @"autoBrakeTimes":@(autoBrakeNum),
                                   @"sleepTimes":@(sleepNum),
                                   @"closeTimes":@(shutdownNum)};
        [NETWorkAPI uploadDeviceSleepTimes:parma callback:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }
}

//上传刹车灵敏度
+(void)uploadBrakeSensitivity:(NSInteger)sensitivity{
    [NETWorkAPI uploadDeviceSensitivity:[NSString stringWithFormat:@"%ld",sensitivity] callback:^(BOOL success, NSError * _Nullable error) {
        
    }];
}
@end
