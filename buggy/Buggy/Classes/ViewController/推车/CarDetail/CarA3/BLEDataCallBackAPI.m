//
//  BLEDataCallBackAPI.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BLEDataCallBackAPI.h"
#import "CarDetailsViewModel.h"
#import "BlueToothManager.h"
#import "CalendarHelper.h"
#import "NSUserDefaults+SafeAccess.h"

typedef void(^DeviceTravelCallBack)(void);
typedef void(^BrakeStatusCallBack)(void);
typedef void(^BatteryCallBack)(void);
typedef void(^DeviceVersionCallBack)(void);

@interface BLEDataCallBackAPI()

@property (nonatomic ,copy) DeviceTravelCallBack DTCaLLBack;
@property (nonatomic ,copy) BrakeStatusCallBack BSCaLLBack;
@property (nonatomic ,copy) BatteryCallBack BCaLLBack;
@property (nonatomic ,copy) DeviceVersionCallBack DVCallBack;

@end

@implementation BLEDataCallBackAPI{
    NSMutableDictionary *_deviceDetailDic;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceDetailDic = [NSMutableDictionary dictionary];
    }
    return self;
}

/**le
 获取当前设备的所有起始状态（今日平均时速、今日里程、总里程、刹车状态、电量获取、版本号、背光起始状态）
 */
- (void)sendOrderToAchieveCurrentDeviceStatus{
    
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel getDeviceStatus]];    //向设备写入 请求设备状态的指令
    
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel getDeviceTravelData]];

    self.DVCallBack = ^{
        [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setSynchronizationTime]];   //向设备写入 请求设备同步时间的指令
    };

}

//- (void)sendOrderToGetBrakeStatus{
//    
//    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel getBrakeStatus]];
//}

//智能刹车
- (void)sendOrderToSetDeviceBrake:(BOOL)brake{
    if (brake) {//开启智能刹车
       [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setBraking]];
    }
    
    if (!brake) { //关闭智能刹车
        [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setRelieveBraking]];
    }
    [NSUserDefaults setObject:@(brake) forKey:BRAKINGSTATUS];
}
//一键防盗
- (void)sendOrderToSetCancleDeviceBrake:(BOOL)brake{
    if (brake) {
        [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setAntiTheft]];
    }
    if (!brake) {
        [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setCancelAntiTheft]];
    }
    [NSUserDefaults setObject:@(brake) forKey:AntiTheftStatus];
}


- (void)sendOrderToCloseDevice{
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setCloseDevice]];
}

- (void)sendOrderToRepair{
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel checkAndRepairDevice]];
}

- (void)sendOrderToSetBackLight:(int)lightNum{
    BACKLIGHT_TYPE backLightType;
    switch (lightNum) {
        case 0:
            backLightType = BACKLIGHT_CLOSE;
            break;
        case 1:
            backLightType = BACKLIGHT_ONE;
            break;
        case 2:
            backLightType = BACKLIGHT_TWO;
            break;
        case 3:
            backLightType = BACKLIGHT_THREE;
            break;
        case 4:
            backLightType = BACKLIGHT_FOUR;
            break;
        case 5:
            backLightType = BACKLIGHT_FIVE;
            break;
        case 6:
            backLightType = BACKLIGHT_SIX;
            break;
        default:
            backLightType = BACKLIGHT_CLOSE;
            break;
    }
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setBacklight:backLightType]];
}

- (void)sendorderToSyncTime{
    [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel setSynchronizationTime]];
}
//根据蓝牙信息进行ui布局
- (void)parserData:(NSArray *)dataArray{

    NSLog(@"dataArray = %@  count = %lu",dataArray,(unsigned long)dataArray.count);
    //有数据
    if (dataArray.count != 0) {
        NSData *data = [dataArray objectAtIndex:0];
        Byte *byte = (Byte *)[data bytes];
     
//        NSMutableString *hexStr = [[NSMutableString alloc]init];
//        int i = 0;
//        if(byte)
//        {
//            while (byte[i] != '\0')
//            {
//                NSString *hexByte = [NSString stringWithFormat:@"%x",byte[i] & 0xff];///16进制数
//                if([hexByte length]==1)
//                    [hexStr appendFormat:@"0%@", hexByte];
//                else
//                    [hexStr appendFormat:@"%@", hexByte];
//                
//                i++;
//            }
//        }
        //  既然每次只会返回一条数据 ，那么就只有一个if会匹配到  可以到if里面加retain
        if (byte[3] == 0x8b && byte[4] == 0x01) { // 获取里程和速度
            
            NSMutableDictionary *travelDic = [NSMutableDictionary dictionaryWithCapacity:0];
            Byte bytAverageSpeed = byte[5] << 8;
            Byte numAverageSpeed = bytAverageSpeed + byte[6];
            NSString *numStrAverageSpeed = [NSString stringWithFormat:@"%hhu",numAverageSpeed];
            CGFloat asF = [numStrAverageSpeed floatValue] / 10;
            numStrAverageSpeed = [NSString stringWithFormat:@"%0.1f",asF];
            [travelDic setValue:numStrAverageSpeed forKey:@"averageSpeed"];
            
//            Byte byteTodayMileage = byte[7] << 8;
//            Byte numTodayMileage = byteTodayMileage + byte[8];
//            NSString *numStrTodayMileage = [NSString stringWithFormat:@"%hhu",numTodayMileage];
//            CGFloat toMF = [numStrTodayMileage floatValue] / 100;
//            numStrTodayMileage = [NSString stringWithFormat:@"%0.2f",toMF];
            int j = (byte[7] << 8) | byte[8];  //今日里程
            
            int k = (byte[9] << 8) | byte[10];  //总里程
            [travelDic setValue:[NSString stringWithFormat:@"%d",j*10] forKey:@"todayMileage"];
            
//            Byte byteTotalMileage = byte[9] << 8;
//            Byte numTotalMileage = byteTotalMileage + byte[10];
//            NSString *numStrTotalMileage = [NSString stringWithFormat:@"%hhu",numTotalMileage];
//            CGFloat tmF = [numStrTotalMileage floatValue] / 10;
//            numStrTotalMileage = [NSString stringWithFormat:@"%0.1f",tmF];
            [travelDic setValue:[NSString stringWithFormat:@"%0.2f",k/10.0] forKey:@"totalMileage"];
            [travelDic setValue:[CalendarHelper getDate] forKey:@"time"];
            [travelDic setValue:[BLEMANAGER.currentPeripheral.identifier UUIDString] forKey:@"bluetoothUUID"];
            
            if (travelDic.count != 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(deviceuploadTravel:)]) {
                    [self.delegate deviceuploadTravel:travelDic];
                    //                    self.DTCaLLBack();
                }
            }
            NSLog(@"dataArray = %@  count = %lu   里程和速度= %@",dataArray,(unsigned long)dataArray.count,travelDic);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x04) {   // 获取刹车状态
            //            self.BSCaLLBack();
            if (byte[5] == 0x00) { // 解刹状态
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrake:)]) {
                    [self.delegate deviceBrake:NO];
                }
                [NSUserDefaults setObject:@(NO) forKey:BRAKINGSTATUS];
                NSLog(@"dataArray = %@  count = %lu  解刹状态 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
                return;
            }
            
            if (byte[5] == 0x55) { // 刹车状态
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrake:)]) {
                    [self.delegate deviceBrake:YES];
                }
                [NSUserDefaults setObject:@(YES) forKey:BRAKINGSTATUS];
                NSLog(@"dataArray = %@  count = %lu  刹车状态 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
                return;
            }
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x05) {   // zheng -一键防盗开启
            if (byte[5] == 0x01) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceAntiTheftSuccess:)]) {
                    [self.delegate deviceAntiTheftSuccess:YES];
                }
                [NSUserDefaults setObject:@(YES) forKey:AntiTheftStatus];
            }else{
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceAntiTheftSuccess:)]) {
                    [self.delegate deviceAntiTheftSuccess:NO];
                }
                [NSUserDefaults setObject:@(NO) forKey:AntiTheftStatus];
            }
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x06) {      // zheng 一键防盗关闭
            if (byte[5] == 0x00) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceAntiTheftSuccess:)]) {
                    [self.delegate deviceAntiTheftSuccess:NO];
                }
                [NSUserDefaults setObject:@(NO) forKey:AntiTheftStatus];
                return;
            }
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x0e) {     // 智能刹车开启
            if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrakeOrderSuccess:)]) {
                [self.delegate deviceBrakeOrderSuccess:YES];
            }
            [NSUserDefaults setObject:@(YES) forKey:BRAKINGSTATUS];
            NSLog(@"dataArray = %@  count = %lu  智能刹车开启 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
            return;
        }
        
        
        if (byte[3] == 0x8b && byte[4] == 0x0d) {     // 智能刹车关闭
            if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrakeOrderSuccess:)]){
                [self.delegate deviceBrakeOrderSuccess:NO];
            }
            [NSUserDefaults setObject:@(NO) forKey:BRAKINGSTATUS];
            NSLog(@"dataArray = %@  count = %lu  智能刹车关闭 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x05) {      // 防盗反馈
            if (byte[5] == 0x67) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrakeOrderSuccess:)]) {
                    [self.delegate deviceBrakeOrderSuccess:YES];
                }
                [NSUserDefaults setObject:@(YES) forKey:BRAKINGSTATUS];
                NSLog(@"dataArray = %@  count = %lu  防盗反馈 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
                return;
            }
        }
        
        
        if (byte[3] == 0x8b && byte[4] == 0x06) {    // 解除防盗反馈
            if (byte[5] == 0x00) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deviceBrakeOrderSuccess:)]) {
                    [self.delegate deviceBrakeOrderSuccess:NO];
                }
                [NSUserDefaults setObject:@(NO) forKey:BRAKINGSTATUS];
                NSLog(@"dataArray = %@  count = %lu  解除防盗反馈 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
                return;
            }
        }
        
        
        if (byte[3] == 0x8b && byte[4] == 0X0D) {    // 关闭所有刹车系统
            if (byte[5] == 0X00) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(deviceCancleBrakeSystom:)]) {
                    [self.delegate deviceCancleBrakeSystom:YES];
                }
                NSLog(@"dataArray = %@  count = %lu  关闭所有刹车系统 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
                return;
            }
        }
       
        if (byte[3] == 0x0E && byte[4] == 0x0e) {      // 打开所有刹车系统
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceCancleBrakeSystom:)]) {
                [self.delegate deviceCancleBrakeSystom:NO];
            }
            NSLog(@"dataArray = %@  count = %lu  打开所有刹车系统 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x07) {     // 获取电量
            Byte numEnergy = byte[5];
            NSString *numStr = [NSString stringWithFormat:@"%hhu",numEnergy];
            [_deviceDetailDic setValue:numStr forKey:@"battery"];
            [[CacheManager manager] saveLocalData:_deviceDetailDic name:A3DEVICEDATA];
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceBattery:)]) {
                [self.delegate deviceBattery:numStr];
                //                self.BCaLLBack();
            }
            NSLog(@"dataArray = %@  count = %lu  获取电量 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0xAA) { // 一键关机回调
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceCloseDevice:)]) {
                [self.delegate deviceCloseDevice:YES];
            }
            NSLog(@"dataArray = %@  count = %lu  一键关机回调 = %hhu",dataArray,(unsigned long)dataArray.count,byte[5]);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x0b) { // 获取版本号
            
            NSString *lastStr = [NSString stringWithFormat:@"%hhu",byte[7]];
            NSString *centerStr = [NSString stringWithFormat:@"%hhu",byte[6]];
            NSString *firstStr = [NSString stringWithFormat:@"%hhu",byte[5]];
            NSString *version = [[[[firstStr stringByAppendingString:@"."] stringByAppendingString:centerStr] stringByAppendingString:@"."] stringByAppendingString:lastStr];
            
            KUserDefualt_Set(version, KA3Version);
            [_deviceDetailDic setValue:version forKey:@"version"];
            [[CacheManager manager] saveLocalData:_deviceDetailDic name:A3DEVICEDATA];
            if (self.DVCallBack) {
                self.DVCallBack();
            }
            NSLog(@"dataArray = %@  count = %lu  获取版本号 = %@",dataArray,(unsigned long)dataArray.count,version);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x55) { // 检测修复
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceRepairFinish:)]) {
                [self.delegate deviceRepairFinish:data];
            }
            NSLog(@"dataArray = %@  count = %lu  检测修复",dataArray,(unsigned long)dataArray.count);
            return;
            // 解析修复的数据
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x08) { // 获取从机的相关数据
            // 解析修复的数据
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDetailLog:)]) {
                [self.delegate deviceDetailLog:data];
            }
            NSLog(@"dataArray = %@  count = %lu  获取从机相关数据",dataArray,(unsigned long)dataArray.count);
            return;
        }
        
        if (byte[3] == 0x8b && byte[4] == 0x09) { // 按钮背光设置
            NSInteger backLightType = 0;
            if (byte[5] == 0x00) {
                backLightType = 0;
            }
            if (byte[5] == 0x01) {
                backLightType = 1;
            }
            if (byte[5] == 0x02) {
                backLightType = 2;
            }
            if (byte[5] == 0x03) {
                backLightType = 3;
            }
            if (byte[5] == 0x04) {
                backLightType = 4;
            }
            if (byte[5] == 0x05) {
                backLightType = 5;
            }
            if (byte[5] == 0x06) {
                backLightType = 6;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceSetBackLightFinish:)]) {
                [self.delegate deviceSetBackLightFinish:backLightType];
            }
            NSLog(@"dataArray = %@  count = %lu  按钮背光 = %ld",dataArray,(unsigned long)dataArray.count,(long)backLightType);
            return;
        }
        if (byte[3] == 0x8b && byte[4] == 0x0A) { // 同步时间成功
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceSyncTime:)]) {
                [self.delegate deviceSyncTime:YES];
            }
            NSLog(@"dataArray = %@  count = %lu  同步时间成功",dataArray,(unsigned long)dataArray.count);
            return;
        }
        
    }
}

@end
