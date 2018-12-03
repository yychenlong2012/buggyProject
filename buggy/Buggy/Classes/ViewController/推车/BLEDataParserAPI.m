//
//  BLEDataParserAPI.m
//  Buggy
//
//  Created by 孟德林 on 2016/12/20.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BLEDataParserAPI.h"
#import "NSString+Additions.h"
#import "CacheManager.h"

@interface BLEDataParserAPI(){
    
    NSString *_dataStr;
    NSMutableDictionary *_deviceDetailDic;
}
@end

@implementation BLEDataParserAPI
//单粒
static BLEDataParserAPI* _instance = nil;
+(instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _deviceDetailDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)G_parserData:(NSString *)dataStr{
    
    /*
     特征值更新 我是传递过来的数据<4441543a 4d492020 302e302c 20202030 2c20322e>
     2017-11-05 09:03:18.827259 Buggy[795:342250] DAT:MI  0.0,   0, 2.
     特征值更新 我是传递过来的数据<380d0a>
     2017-11-05 09:03:18.829570 Buggy[795:342250] 8
     */
    //拼接数据
    if ([dataStr containsString:@"DAT"]) {   //如果包含DAT 那么就是一条新命令 清空覆盖之前的命令  一条命令可能需要多个数据包发送过来
        _dataStr = dataStr;
    }else{
        _dataStr = [NSString stringWithFormat:@"%@%@",_dataStr,dataStr];
    }

    //解析数据
    if ([_dataStr containsString:@"\r\n"]) {
        //TODO:这里判断接受信息
        /*
         DAT:MIXXX.X,XXXX,XX.X\r\n 里程
         */
        if ([_dataStr containsString:@"MI"]) {
            [self postMI];
        }
        if ([_dataStr containsString:@"FR"]) {
            if (_dataStr.length > 6) {
                _dataStr = [_dataStr substringFromIndex:6];
                _dataStr = [NSString cleanString:_dataStr];
                KUserDefualt_Set(_dataStr, @"A1_Version");
                [_deviceDetailDic setValue:_dataStr forKey:@"FR"];
                [[CacheManager manager] saveLocalData:_deviceDetailDic name:DeviceData];
            }
        }
        if ([_dataStr containsString:@"ET"]) {
            [self postET];
        }
        
        if ([_dataStr containsString:@"TS"]) { //同步时间信息
            NSDate *date = [NSDate date];
            NSDateFormatter *formate = [[NSDateFormatter alloc] init];
            [formate setDateFormat:@"HH-mm-ss"];
            NSString *time = [formate stringFromDate:date];
            NSMutableString *cleanString = [NSMutableString stringWithString:time];
            [cleanString replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [cleanString length])];
            time = [NSString stringWithFormat:@"CMD:TM%@%@%@",cleanString,@"\r",@"\n"];
            if (time != nil) {
                if ([self.delegate respondsToSelector:@selector(G_sendDataToBLEDevice:)]) {
                    [self.delegate G_sendDataToBLEDevice:time];
                }
            }
        }
        
        if ([_dataStr containsString:@"WH"] && [_dataStr  hasPrefix:@"DAT:WH"]) {   //体重
            if (_dataStr.length > 6) {
                _dataStr = [_dataStr substringFromIndex:6];
                _dataStr = [NSString cleanString:_dataStr];
                if (_dataStr != nil) {
                    if ([self.delegate respondsToSelector:@selector(G_refreshBabyWeight:)]) {
                        [self.delegate G_refreshBabyWeight:_dataStr];
                    }
                }
            }
        }
        _dataStr = nil;
    }
}

- (void)postET{
    if (_dataStr.length > 6 && [_dataStr hasPrefix:@"DAT:ET"]) {
        _dataStr  = [_dataStr substringFromIndex:6];
        NSArray *receives = [_dataStr componentsSeparatedByString:@","];
        if (receives.count == 2) {
            __weak typeof(self) wself = self;
            [receives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (idx == 1) {
                    NSString *item = obj;
                    item = [NSString cleanString:item];
                    [self->_deviceDetailDic setValue:item forKey:@"Battery"];    //电量
                    [[CacheManager manager] saveLocalData:self->_deviceDetailDic name:DeviceData];
                    KUserDefualt_Set(item, @"A1_battery");
                }
                
                if (idx == 0) {
                    NSString *item = obj;
                    item = [NSString cleanString:item];
                    item = [NSString stringWithFormat:@"%@",item];
                    [self->_deviceDetailDic setValue:item forKey:@"Tem"];        //温度
                    [[CacheManager manager] saveLocalData:self->_deviceDetailDic name:DeviceData];
                    KUserDefualt_Set(item, @"A1_temperature");
                    if (item != nil) {
                        if ([wself.delegate respondsToSelector:@selector(G_refreshTemperature:)]) {
                            [wself.delegate G_refreshTemperature:item];
                        }
                    }
                }
            }];
            
            if ([wself.delegate respondsToSelector:@selector(updateTemperatureAndBattery)]) {
                [wself.delegate updateTemperatureAndBattery];
            }
        }
    }
}

- (void)postMI{
    if (_dataStr.length > 6 && [_dataStr hasPrefix:@"DAT:MI"]) {
        _dataStr = [_dataStr substringFromIndex:6];
        NSArray *receives = [_dataStr componentsSeparatedByString:@","];
        if (receives.count == 3) {
            if (receives.count == 3) {
                __block NSMutableDictionary *param = [NSMutableDictionary dictionary];
                __weak typeof(self) wself = self;
                [receives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == 0) {//0 今日里程
                        NSString *item = obj;
                        item = [NSString cleanString:item];
                        [param setValue:item forKey:@"todayMileage"];
                    }
                    if (idx == 1) {//1 总里程
                        NSString *item = obj;
                        item = [NSString cleanString:item];
                        [param setValue:item forKey:@"totalMileage"];
                    }
                    if (idx == 2) {//2 速度
                        NSString *item = obj;
                        item = [NSString cleanString:item];
                        [param setValue:item forKey:@"averageSpeed"];
                        KUserDefualt_Set(item, @"A1_averageSpeed");
                    }
                }];
                //反馈给界面
                if ([wself.delegate respondsToSelector:@selector(updateAverageSpeed)]) {
                    [wself.delegate updateAverageSpeed];
                }
                [param setValue:[CalendarHelper getDate] forKey:@"time"];
                //上传总信息到后台
                if ([wself.delegate respondsToSelector:@selector(G_postTravel:)]) {
                    [wself.delegate G_postTravel:param];
                }
            }
        }
    }
}


@end
