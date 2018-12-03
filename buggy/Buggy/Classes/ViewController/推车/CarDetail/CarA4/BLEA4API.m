//
//  BLEA4API.m
//  Buggy
//
//  Created by goat on 2018/5/8.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BLEA4API.h"

@implementation BLEA4API

//里程和速度获取
+ (NSData *)getDeviceTravelData{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x01,0x0C};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//数据监听准备完毕
+ (NSData *)notifySuccess{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0C,0xE9};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//刹车状态获取
+ (NSData *)getStateOfTheBrake{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x04,0x0F};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//一键防盗打开
+ (NSData *)openSafety{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x05,0xF0};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//一键防盗关闭
+ (NSData *)closeSafety{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x06,0xEF};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//电量获取
+ (NSData *)getDeviceElectric{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x07,0x12};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//一键关机
+ (NSData *)closeDevice{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0xAA,0x4B};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//检测修复 和A3的指令好像一样
+ (NSData *)DeviceRepair{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x55,0xA0};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//蓝牙数据获取
+ (NSData *)getDeviceData{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x08,0x13};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}
//时间同步
+ (NSData *)synchronizationTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    forma.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateStr = [forma stringFromDate:date];
    
    NSString *str16 = [self ToHex:[[dateStr substringWithRange:NSMakeRange(0, 4)] integerValue]];
    NSData *dateioero = [self convertHexStrToData:[self setZeroWithStr:str16]];
    Byte *year = (Byte *)[dateioero bytes];
    Byte mon   = [self getByte:[[dateStr substringWithRange:NSMakeRange(4, 2)] integerValue]];
    Byte day   = [self getByte:[[dateStr substringWithRange:NSMakeRange(6, 2)] integerValue]];
    Byte hour  = [self getByte:[[dateStr substringWithRange:NSMakeRange(8, 2)] integerValue]];
    Byte min   = [self getByte:[[dateStr substringWithRange:NSMakeRange(10, 2)] integerValue]];
    Byte second= [self getByte:[[dateStr substringWithRange:NSMakeRange(12, 2)] integerValue]];
    
//    NSLog(@"%hhu %hhu %hhu %hhu %hhu %hhu %hhu",year1,year2,mon,day,hour,min,second);
    Byte byte[] = {0x55,0xAA,0X07,0x0B,0x0A,year[0],year[1],mon,day,hour,min,second,0-(7+0x0B+0x0A+year[0]+year[1]+mon+day+hour+min+second)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:13];
    return data;
}
//获取固件版本号
+ (NSData *)getDeviceVersion{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x0B,0-(0x0B+0x0B)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//关闭电子刹车
+ (NSData *)closeBrake{
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x0F,0x00,0xE5};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}
//自动刹车 松手即刹
+ (NSData *)setAutoBrake{
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x0F,0x01,0xE4};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}
//智能刹车
+ (NSData *)setSmartBrake{
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x0F,0x02,0xE3};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

//获取推行数据   获取date以后的推行记录
+ (NSData *)getPushData:(NSDate *)date{
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    forma.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateStr = [forma stringFromDate:date];
    
    NSString *str16 = [self ToHex:[[dateStr substringWithRange:NSMakeRange(0, 4)] integerValue]];
    NSData *dateioero = [self convertHexStrToData:[self setZeroWithStr:str16]];
    Byte *year = (Byte *)[dateioero bytes];
    Byte mon   = [self getByte:[[dateStr substringWithRange:NSMakeRange(4, 2)] integerValue]];
    Byte day   = [self getByte:[[dateStr substringWithRange:NSMakeRange(6, 2)] integerValue]];
    Byte hour  = [self getByte:[[dateStr substringWithRange:NSMakeRange(8, 2)] integerValue]];
    Byte min   = [self getByte:[[dateStr substringWithRange:NSMakeRange(10, 2)] integerValue]];
    Byte second= [self getByte:[[dateStr substringWithRange:NSMakeRange(12, 2)] integerValue]];
   
    Byte byte[] = {0x55,0xAA,0X07,0x0B,0x10,year[0],year[1],mon,day,hour,min,second,0-(7+0x0B+0x10+year[0]+year[1]+mon+day+hour+min+second)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:13];
    return data;
}

//逐条获取推行数据
+ (NSData *)getPushDataOnce:(NSDate *)date{
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    forma.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateStr = [forma stringFromDate:date];
    
    NSString *str16 = [self ToHex:[[dateStr substringWithRange:NSMakeRange(0, 4)] integerValue]];
    NSData *dateioero = [self convertHexStrToData:[self setZeroWithStr:str16]];
    Byte *year = (Byte *)[dateioero bytes];
    Byte mon   = [self getByte:[[dateStr substringWithRange:NSMakeRange(4, 2)] integerValue]];
    Byte day   = [self getByte:[[dateStr substringWithRange:NSMakeRange(6, 2)] integerValue]];
    Byte hour  = [self getByte:[[dateStr substringWithRange:NSMakeRange(8, 2)] integerValue]];
    Byte min   = [self getByte:[[dateStr substringWithRange:NSMakeRange(10, 2)] integerValue]];
    Byte second= [self getByte:[[dateStr substringWithRange:NSMakeRange(12, 2)] integerValue]];
    
    Byte byte[] = {0x55,0xAA,0X07,0x0B,0x20,year[0],year[1],mon,day,hour,min,second,0-(7+0x0B+0x20+year[0]+year[1]+mon+day+hour+min+second)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:13];
    return data;
}

//读取一条剩余推行数据
+ (NSData *)getSurplusPushData{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x20,0-(0x0B+0x20)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//获取环境温度
+ (NSData *)getTemperature{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x11,0x1C};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//开关提示音和其他提示音
+ (NSData *)setupWarningSound:(BOOL)flag1 andOtherSound:(BOOL)flag2 bellsNumber:(NSInteger)num{
    flag2 = YES;   //其他提示音默认开启
    NSString *warningSound;
    if (flag1) {
        warningSound = @"10";
    }else{
        warningSound = @"00";
    }
    
    NSString *otherSound;
    if (flag2) {
        otherSound = @"01";
    }else{
        otherSound = @"00";
    }
    
    //铃声
    NSString *bells;
    if (num == 0) {
        bells = @"0000";
    }else if (num == 1){
        bells = @"0001";
    }else if (num == 2){
        bells = @"0010";
    }else{
        bells = @"0011";
    }
    
    //二进制字符串
    NSString *code = [NSString stringWithFormat:@"%@%@%@",warningSound,otherSound,bells];
    Byte codeByte = [self convertHexToBStr:code];

    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x12,codeByte,0-(1+0x0B+0x12+codeByte)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

//设置车灯  是否开启  车灯模式
+ (NSData *)setCarLight:(BOOL)isOpen lightMode:(NSInteger)mode{
    NSString *modeStr = @"0000001";
    if(mode == 1){
        modeStr = @"0000001";   //呼吸灯模式
    }else if(mode == 0){
        modeStr = @"0000000";   //常亮模式
    }
    
    //二进制字符串
    NSString *code = [NSString stringWithFormat:@"%@%@",isOpen?@"1":@"0",modeStr];
    Byte codeByte = [self convertHexToBStr:code];
    
    Byte byte[] = {0x55,0xAA,0x01,0x0B,0x30,codeByte,0-(1+0x0B+0x30+codeByte)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

//设置提示音量
+ (NSData *)setWarningVolume:(NSInteger)level{
    Byte levelByte = [self getByte:level];
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x13,levelByte,0-(1+0x0B+0x13+levelByte)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

//设定系统提示音语言
+ (NSData *)setSystemLanguage:(NSString *)language{
    Byte lang = 0x00;
    if ([language isEqualToString:@"中文"]) {
        lang = 0x00;
    }
    if ([language isEqualToString:@"英文"]) {
        lang = 0x01;
    }
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x15,lang,0-(1+0x0B+0x15+lang)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

//设置最小的有效推行间隔   单位是秒
+ (NSData *)setupMinTrvalLength:(NSInteger)seconds{
    //生成16进制的字符串
    NSString *str16 = [self ToHex:seconds];
    NSData *dateioero = [self convertHexStrToData:[self setZeroWithStr:str16]];
    Byte *bytetim = (Byte *)[dateioero bytes];
     
    Byte byte[] = {0x55,0xAA,0X02,0x0B,0x14,bytetim[0],bytetim[1],0x21};
    NSData *data = [[NSData alloc] initWithBytes:byte length:8];
    return data;
}

//获取刹车次数
+ (NSData *)getBrakeNumber{
    Byte byte[] = {0x55,0xAA,0X00,0x0B,0x08,0-(0x0B+0x15)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:6];
    return data;
}

//设置刹车灵敏度
+ (NSData *)setBrakeSensitivity:(NSInteger)sensitivity{
    NSString *code;
    if (sensitivity == 0) {
        code = @"00000000";
    }else if (sensitivity == 1){
        code = @"00000001";
    }else if (sensitivity == 2){
        code = @"00000010";
    }else if (sensitivity == 3){
        code = @"00000011";
    }else{
        code = @"00000100";
    }
    Byte codeByte = [self convertHexToBStr:code];
    Byte byte[] = {0x55,0xAA,0X01,0x0B,0x16,codeByte,0-(1+0x0B+0x16+codeByte)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

#pragma mark - tools
//10进制数转byte字节数据
+ (Byte)getByte:(NSUInteger)num{
    NSData *dateioero = [self convertHexStrToData:[self ToHex:num]];
    Byte *bytetim = (Byte *)[dateioero bytes];
    return bytetim[0];
}

//不足4位的前面补零
+ (NSString *)setZeroWithStr:(NSString *)str{
    //如果str大于4位
    if (str.length>=4) {
        return [str substringFromIndex:str.length-4];
    }
    switch (str.length) {
        case 0:
            str = @"0000";
            break;
        case 1:
            str = [NSString stringWithFormat:@"000%@",str];
            break;
        case 2:
            str = [NSString stringWithFormat:@"00%@",str];
            break;
        case 3:
            str = [NSString stringWithFormat:@"0%@",str];
    }
    return str;
}

//10进制数转16进制字符串
+ (NSString *)ToHex:(long long int)tmpid{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig){
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

//将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

//二进制字符串转16进制byte
+ (Byte)convertHexToBStr:(NSString *)bStr{
    NSUInteger num = 0;
    //2进制字符串转10进制数
    for (NSInteger i = 0; i<bStr.length; i++) {
        num += [[bStr substringWithRange:NSMakeRange(i, 1)] integerValue]*pow(2, bStr.length-i-1);
    }
    return [self getByte:num];
}

@end
