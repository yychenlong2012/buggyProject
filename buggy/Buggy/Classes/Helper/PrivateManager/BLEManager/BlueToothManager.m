//
//  BLEManager.m
//  bluetooth
//
//  Created by goat on 2017/10/10.
//  Copyright © 2017年 goat. All rights reserved.
//

#import "BlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Tools.h"
#import "MusicManager.h"
#import "MusicPlayNewController.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"
#import "WNJsonModel.h"
#import "DeviceModel.h"
#import "BLEA4API.h"
#import "pushDataAPI.h"
#import "NetWorkStatus.h"
#import "CarA4DetailViewController.h"
#import "CarA3DetailsViewController.h"
#import "NSDate+travelDate.h"
#import "TripAndMusicViewController.h"
#import "CarDetailsViewModel.h"
#import "CarOldDetailViewController.h"
#import "NSString+Additions.h"
#import "DeviceViewController.h"
#import "MusicMainViewController.h"

#define RSSI_blueTooth 200    //可接受的外围蓝牙信号强度最低值 rssi通常为负数 只要大于-50 蓝牙信号强度就可接受
typedef struct _CHAR{
    char buff[1000];
}CHAR_STRUCT;

@interface BlueToothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,strong)NSArray *deviceType;   //设备类型列表
//扫描状态
@property (nonatomic,assign) BOOL isScan;
//扫描超时定时器
@property (nonatomic,strong) NSTimer *timeoutTimer;
//准备连接的蓝牙外设
@property (nonatomic,strong) CBPeripheral *prepareConnectPeripheral;
//特征值
@property (nonatomic,strong) CBCharacteristic *writeCharacteristic;  //写入通道
@property (nonatomic,strong) CBCharacteristic *readCharacteristic;   //读取通道
@property (nonatomic,strong) CBCharacteristic *notifyCharacteristic; //监听通道

@property (nonatomic,strong) NSString *currentDeviceIdentify;   //设备标识
@property (nonatomic,strong) NSString *carOldData;         //用于保存高景观数据 高景观的每一条命令可能太长 会分段传来
@property (nonatomic,strong) NSMutableArray *onceDataArray;     //分段里程数据
@end


@implementation BlueToothManager
-(NSArray *)deviceType{
    if (_deviceType == nil) {
        //获得设备类型列表用于筛选蓝牙deviceTypeList.plist
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = @"deviceTypeList.plist";
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        _deviceType = [NSMutableArray arrayWithContentsOfFile:filePath];
    }
    return _deviceType;
}

#pragma mark - 初始化管理者
+ (instancetype)manager{
    static BlueToothManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//初始化中心管理者  只需在appdelegate中初始化一次即可
- (void)CL_initializeCentralManager{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.isScan = NO;
    self.discoveredPeripherals = [NSMutableArray array];
    self.deviceCallBack = [NSMutableArray array];
    self.A4Version = @"000";
    self.onceDataArray = [NSMutableArray array];
}

#pragma mark - 蓝牙的扫描
//开始扫描外围设备 设置超时
- (void)startScanBLEWithTimeout:(NSTimeInterval)timeout{
    //设置默认超时时间
    if (timeout <= 0 || timeout > 60) {
        timeout = 5;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"手机蓝牙未开启??");
        return;
    }
    //停止上一次的定时器
    [self destroyTimeoutTimer];
    //扫描前清空之前的设备记录
    [self.discoveredPeripherals removeAllObjects];
    //再重新开启一个定时器
    if (self.timeoutTimer == nil) {
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(isOvertime) userInfo:nil repeats:NO];
    }
    [self.centralManager stopScan];
    //开始扫描之前一定要判断centralManager的state是否为CBManagerStatePoweredOn 否则将不会扫描
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    self.isScan = YES;
}

//扫描超时回调
-(void)isOvertime{
    NSLog(@"11111");
    [self destroyTimeoutTimer];
    [self.centralManager stopScan];
    self.isScan = NO;
    
    if ([self.delegate respondsToSelector:@selector(stopScanDevices)])
        [self.delegate stopScanDevices];
}

//销毁定时器
-(void)destroyTimeoutTimer{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

-(void)stopScanBLE{
    [self destroyTimeoutTimer];
    [self.centralManager stopScan];
}

#pragma mark - 连接和断开蓝牙
//开始连接指定的蓝牙外设
-(void)connectPeripheralDevice:(CBPeripheral *)peripheral{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"手机的蓝牙没有开启");
        return;
    }
    if (peripheral) {
//        self.prepareConnectPeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

//断开当前连接的蓝牙
-(void)cancelConnect{
    if (self.currentPeripheral == nil) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
}

//蓝牙是否已连接
-(BOOL)isConnectedBluetooth{
    if (self.currentPeripheral != nil && self.currentPeripheral.state == CBPeripheralStateConnected) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - 通用读写监听方法
/**
 *  通用写入数据，发送给外设
 */
-(void)CL_writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data{
    CBUUID *su = [self UUIDWithNumber:serviceUUID];      //获得serviceUUID         服务uuid
    CBUUID *cu = [self UUIDWithNumber:characteristicUUID];      //获得characteristicUUID  特征uuid
    CBService *service = [self searchServiceWithUUID:su];        //搜索对应的服务
    if (service) {
        CBCharacteristic *characteristic = [self searchCharacteristicWithUUID:cu andService:service];
        if (characteristic) {
//            NSLog(@"写入数据%@",characteristic);
            [self.currentPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }else{   //干脚器项目添加
        if (self.writeCharacteristic != nil) {
            [self.currentPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

// 通用从外设读取数据
-(void)CL_readValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID{
    CBUUID *su = [self UUIDWithNumber:serviceUUID];             //获得serviceUUID         服务uuid
    CBUUID *cu = [self UUIDWithNumber:characteristicUUID];      //获得characteristicUUID  特征uuid
    CBService *service = [self searchServiceWithUUID:su];        //搜索对应的服务
    if (service) {
        CBCharacteristic *characteristic = [self searchCharacteristicWithUUID:cu andService:service];
        if (characteristic) {
//            NSLog(@"读取数据%@",characteristic);
            [self.currentPeripheral readValueForCharacteristic:characteristic];       //读取成功会有系统回调
        }
    }
}

// 通用该外设注册通知状态是否活跃   根据isActive值 开启或者关闭对某个特征值的监听
-(void)CL_notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID isActive:(BOOL)isActive{
    CBUUID *su = [self UUIDWithNumber:serviceUUID];      //获得serviceUUID         服务uuid
    CBUUID *cu = [self UUIDWithNumber:characteristicUUID];      //获得characteristicUUID  特征uuid
    CBService *service = [self searchServiceWithUUID:su];
    if (service) {
        CBCharacteristic *characteristic = [self searchCharacteristicWithUUID:cu andService:service];
        if (characteristic) {
            //设置特征值变化的通知
            [self.currentPeripheral setNotifyValue:isActive forCharacteristic:characteristic];
        }
    }
}

//在服务中搜索特征
-(CBCharacteristic *)searchCharacteristicWithUUID:(CBUUID *)cu andService:(CBService *)service{
    CBCharacteristic *characteristic = nil;   //在服务中搜索特征
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID isEqual:cu]) {
            characteristic = c;
            break;
        }
    }
    return characteristic;
}

//搜索服务
-(CBService *)searchServiceWithUUID:(CBUUID *)su{
    CBService *service = nil;   //搜索对应的服务
    for(int i = 0; i < self.currentPeripheral.services.count; i++) {
        CBService *s = [self.currentPeripheral.services objectAtIndex:i];
        if ([s.UUID isEqual:su]) {
            service = s;
            break;
        }
    }
    return service;
}

-(CBUUID *)UUIDWithNumber:(int)number{
    UInt16 s = [self _swap:number];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    return [CBUUID UUIDWithData:sd];
}

#pragma mark - 数据写入和读取 A3新车
/**
 *  新版本数据写入  发给蓝牙外设
 *  serviceUUID           0xA032
 *  characteristicUUID    0xA040
 */
- (void)writeValueForPeripheral:(NSData *)data{
    [self CL_writeValue:0xA032 characteristicUUID:0xA040 data:data];
    if (self.deviceCallBack.count > 0) {    //清除之前的数据
        [self.deviceCallBack removeAllObjects];
    }
}

- (void)readValue{
    [self CL_readValue:0x0000 characteristicUUID:0x0000];
}


#pragma mark - 读取数据A1 高景观
//A1高景观车 获取推车信息 接收数据
- (void)startReceiveData{
    if (self.currentPeripheral.state == CBPeripheralStateConnected) {    //如果外设已连接上
        //获取外设中的服务，获取服务中的特征值，监听特征值的变化
        //serviceUUID           0xFFE0
        //characteristicUUID    0xFFE4
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self CL_notification:0xFFE0 characteristicUUID:0xFFE4 isActive:YES];
        });
    }
}

//A1结束接受数据
- (void)A1_stopReceiveData{
    //结束对特征值的监听
    //serviceUUID           0xFFE0
    //characteristicUUID    0xFFE4
    [self CL_notification:0xFFE0 characteristicUUID:0xFFE4 isActive:NO];
}

//A1同步时间
-(void)A1_SynchronizationTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"HH-mm-ss"];
    NSString *time = [formate stringFromDate:date];
    NSMutableString *cleanString = [NSMutableString stringWithString:time];
    [cleanString replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [cleanString length])];
    time = [NSString stringWithFormat:@"CMD:TM%@%@%@",cleanString,@"\r",@"\n"];
    [self A1_sendDataToDevice:time];
}

//向外设发送数据（本质就是写入中心和外设协议好的格式数据，然后发送）  高景观的方法
- (void)A1_sendDataToDevice:(NSString *)data{
    NSString  *message = data;
   
    int   length = (int)message.length;         //一个ascii码占一个字节   一个NSString包含许多字符，将每个字符都占一个字节
    Byte  messageByte[length];                 //定义一个长度为length 存放Byte类型数据的 数组
    
    for(int index = 0; index < length; index++) {   //生成和字符串长度相同的字节数据  也就是初始化一个数组
        messageByte[index] = 0x00;
    }
    
    NSString   *tmpString;                           //转化为ascii码
    for(int index = 0; index < length; index++){
        tmpString = [message substringWithRange:NSMakeRange(index, 1)];    //去除逐个字节的数据
        if([tmpString isEqualToString:@" "]){
            messageByte[index] = 0x20;
        }else{
            if ([tmpString isEqualToString:@"\r"]) {
                messageByte[index] = 0x0d;
            }else if([tmpString isEqualToString:@"\n"]){
                messageByte[index] = 0x0a;
            }else{
                sscanf([tmpString cStringUsingEncoding:NSASCIIStringEncoding],"%s",&messageByte[index]);
            }
        }
    }
    //    NSLog(@" 老车发送的数据 message   : %@  end",message);
    char lengthChar = 0 ;    //发送多长的数据
    int  p = 0 ;             //从哪个位置开始发送
    
    //将数据发送给蓝牙，每次发送的数据量控制在20个字节以内
    while (length>0) {   //蓝牙数据通道 可写入的数据为20个字节
        if (length>20) {
            lengthChar = 20 ;
        }else if (length>0){
            lengthChar = length;
        }else
            return;
        NSData *data = [[NSData alloc]initWithBytes:&messageByte[p] length:lengthChar];
        
        //serviceUUID            0xFFE5
        //characteristicUUID     0xFFE9
        [self CL_writeValue:0xFFE5 characteristicUUID:0xFFE9 data:data];
        length -= lengthChar;
        p += lengthChar;
    }
}
#pragma mark - 数据处理 数据转换 转换成蓝牙可接受的命令
//根据背光等级生成命令
- (NSData *)transformDataForBacklight:(NSInteger)lightClass{
    Byte typeBy;
    switch (lightClass) {
        case 0:
            typeBy = 0x00;
            break;
        case 1:
            typeBy = 0x01;
            break;
        case 2:
            typeBy = 0x02;
            break;
        case 3:
            typeBy = 0x03;
            break;
        case 4:
            typeBy = 0x04;
            break;
        case 5:
            typeBy = 0x05;
            break;
        case 6:
            typeBy = 0x06;
            break;
        default:
            typeBy = 0x00;
            break;
    }
    Byte byte[] = {0x55,0xAA,0x01,0x0b,0x09,typeBy,0 - (1 + 0x09 + 0x0b + typeBy)};
    NSData *data = [[NSData alloc] initWithBytes:byte length:7];
    return data;
}

- (UInt16)_swap:(UInt16) s{
    UInt16 temp = s << 8;
    temp |= (s >> 8);      //表示 temp = temp | (s >> 8)  按位或
    return temp;
}

#pragma mark - CBCentralManagerDelegate 中心设备代理方法
/**
 *  中心管理者更新状态
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"当前蓝牙状态%ld",(long)central.state);
    if (central.state == CBCentralManagerStatePoweredOff) {   //如果中心设备关闭了 那么也没有当前连接的蓝牙了 连接也就断了
        self.currentPeripheral.delegate = nil;
        self.currentPeripheral = nil;
//        [MBProgressHUD showToast:@"手机蓝牙关闭"];
        if ([self.delegate respondsToSelector:@selector(didDisconnectPeripheral:)])
            [self.delegate didDisconnectPeripheral:self.currentPeripheral];
    }
    if (central.state == CBCentralManagerStatePoweredOn) {   //手机蓝牙已开启
//        [MBProgressHUD showToast:@"手机蓝牙开启"];
        if ([self.delegate respondsToSelector:@selector(BLE_BlueToothOpen)]) {
            [self.delegate BLE_BlueToothOpen];
        }
    }
}

//恢复状态
//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
//{
//    NSLog(@"%@",dict);
//}

//中心设备发现外围设备的回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"扫描到的蓝牙%@",peripheral);
    if (peripheral.name == nil) {
        return;
    }
    
    //按名字筛选蓝牙设备
    BOOL flag = NO;
    for (NSDictionary *dict in self.deviceType) {
        NSString *bluetoothName = dict[@"bluetoothName"];
        if ([bluetoothName isEqualToString:peripheral.name]) {
            flag = YES;
            break;
        }
    }
    //未通过上面检测  下面提供最后一道检测
    if (flag == NO) {
        if ([peripheral.name containsString:@"3POMELOS"]) {
            flag = YES;
        }
    }
    //按信号强度筛选蓝牙设备
    if (RSSI.intValue > -RSSI_blueTooth && flag == YES) {
        NSLog(@"扫描过滤后的蓝牙%@",peripheral);
        BOOL isRepetitive = NO;   //重复标记
        for (CBPeripheral *peripher in self.discoveredPeripherals){    //查重
            if ([peripheral.identifier.UUIDString isEqualToString:peripher.identifier.UUIDString])
                isRepetitive = YES;   //有重复的
        }
        if (!isRepetitive){
            [self.discoveredPeripherals addObject:peripheral];
            //通知代理
            if ([self.delegate respondsToSelector:@selector(didDiscoverPeripheral:)])
                [self.delegate didDiscoverPeripheral:self.discoveredPeripherals];
        }
    }
}


//中心设备成功连接外围设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self stopScanBLE];
    self.currentPeripheral = peripheral;
    self.currentPeripheral.delegate = self;
    //搜索服务
    [self.currentPeripheral discoverServices:nil];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(didConnectPeripheral:)]){
        [self.delegate didConnectPeripheral:peripheral];
    }
//    [MBProgressHUD showToast:@"蓝牙已连接"];
    //已连接蓝牙的设备标识
    for (NSDictionary *dict in self.deviceType) {
        if ([dict[@"bluetoothName"] isEqualToString:peripheral.name]) {
            self.currentDeviceIdentify = dict[@"deviceIdentifier"];
            break;
        }
    }

    /*---------用于连接了推车但是没有进入推车界面，来接收数据---------*/
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_8101"] || [self.currentDeviceIdentify isEqualToString:@"3POMELOS_A6"]) {   //牛顿1
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //在推车界面那么这里不处理
            if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                MainViewController *main = (MainViewController *)[UIViewController presentingVC];
                if ([[main selectedViewController] isKindOfClass:[DYBaseNaviagtionController class]]) {
                    DYBaseNaviagtionController *navi = [main selectedViewController];
                    if ([[navi topViewController] isKindOfClass:[CarA4DetailViewController class]]) {
                        return;
                    }
                }
            }
            [BLEMANAGER writeValueForPeripheral:[BLEA4API synchronizationTime]];  //时间同步
        });
        return;
    }
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_A3"]) {   //A3
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel getDeviceStatus]];  //开启监听
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BLEMANAGER writeValueForPeripheral:[CarDetailsViewModel getDeviceTravelData]];   //请求推行数据
            });
        });
        return;
    }
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_G"]) {   //G
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BLEMANAGER startReceiveData];
        });
        return;
    }
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if ([self.delegate respondsToSelector:@selector(BLE_connectError)])
        [self.delegate BLE_connectError];
}

//设备断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    self.currentPeripheral.delegate = nil;
    self.currentPeripheral = nil;
    self.currentDeviceIdentify = nil;
    //通知代理
    if ([self.delegate respondsToSelector:@selector(didDisconnectPeripheral:)])
        [self.delegate didDisconnectPeripheral:peripheral];
//    [MBProgressHUD showToast:@"蓝牙已断开"];
}

//获取数据表中最新的一条记录的日期
-(void)getTheLatestDate:(void(^)(NSDate *date))block{
    [NETWorkAPI requestNewestMileageDataCallback:^(NSString * _Nullable msg, NSError * _Nullable error) {
        if (error) {
            block([NSDate date]);
            return ;
        }
        if ([msg isKindOfClass:[NSString class]]) {
            NSDateFormatter *forma = [[NSDateFormatter alloc] init];
            forma.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            block([forma dateFromString:msg]);
        }else{
            block([NSDate dateWithTimeInterval:-30*24*60*60 sinceDate:[NSDate date]]);
        }
    }];
}
#pragma mark - CBPeripheralDelegate 蓝牙外设代理
//信号强度更新
//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
//    //    DLog(@"_____ RSSI : %d\r\n",[peripheral.RSSI intValue]);
//
//}

//发现蓝牙的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    if (error) {
        return;
    }
    NSLog(@"发现服务 = %@ count = %lu",peripheral.services,peripheral.services.count);
    //去发现所有服务中的所有特征
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//发现服务中的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    if (error) {
        return;
    }
    NSLog(@"发现特征 = %@",service.characteristics);
    /*
     发现的所有特征 = (
     "<CBCharacteristic: 0x1700aee20, UUID = A042, properties = 0x20, value = (null), notifying = NO>",
     "<CBCharacteristic: 0x1700aefa0, UUID = A040, properties = 0x8, value = (null), notifying = NO>",
     "<CBCharacteristic: 0x1700aeca0, UUID = A041, properties = 0x2, value = (null), notifying = NO>")
     */
    for (CBCharacteristic *character in service.characteristics) {
        NSLog(@"发现服务中的特征%@",character);
        // 写入数据的特征值 0x0A40
        if ([character.UUID isEqual:[CBUUID UUIDWithString:@"0000a040-0000-1000-8000-00805F9B34FB"]]) {   //这里写或者不写都没有问题 这个if可以注释
            self.writeCharacteristic = character;
            continue;
        }
        // 读取数据的特征值 0x0A41
        if ([character.UUID isEqual:[CBUUID UUIDWithString:@"0000a041-0000-1000-8000-00805F9B34FB"]] ) {
            self.readCharacteristic = character;
//            [self CL_readValue:0xA032 characteristicUUID:0xA041];
            continue;
        }
        // 注册监听通道的特征值 0x0A42
        if ([character.UUID isEqual:[CBUUID UUIDWithString:@"0000a042-0000-1000-8000-00805F9B34FB"]] ) {
            self.notifyCharacteristic = character;
            [self.currentPeripheral setNotifyValue:YES forCharacteristic:character];    //监听通道开启监听
            continue;
        }
        
        //=======================================干脚器
        // 注册监听通道的特征值
        if ([character.UUID isEqual:[CBUUID UUIDWithString:@"00010203-0405-0607-0809-0A0B0C0D2B10"]]) {
            self.notifyCharacteristic = character;
            self.readCharacteristic = character;
            [self.currentPeripheral setNotifyValue:YES forCharacteristic:character];    //监听通道开启监听
            continue;
        }
        
        // 写入数据的特征值
        if ([character.UUID isEqual:[CBUUID UUIDWithString:@"00010203-0405-0607-0809-0A0B0C0D2B11"]]) {
            self.writeCharacteristic = character;
            NSLog(@"写入通道");
        }
    }
    
//    2019-02-25 11:05:07.327741+0800 Buggy[360:45268] 发现特征 = (
//                                                             "<CBCharacteristic: 0x101795af0, UUID = 00010203-0405-0607-0809-0A0B0C0D2B10, properties = 0x12, value = (null), notifying = NO>",
//                                                             "<CBCharacteristic: 0x10178c360, UUID = 00010203-0405-0607-0809-0A0B0C0D2B11, properties = 0x6, value = (null), notifying = NO>"
//                                                             )
//    2019-02-25 11:05:25.886525+0800 Buggy[360:45268] 发现特征 = (
//                                                             "<CBCharacteristic: 0x1071cdb90, UUID = 00010203-0405-0607-0809-0A0B0C0D2B12, properties = 0x6, value = (null), notifying = NO>"
//                                                             )
    
    
    
    /*
     180A 为获取设备信息的服务UUID,          service
     2A23为系统ID，及模块芯片的物理地址的 特征UUID,
     2A26 模块软件的版本号UUID.
     */
    if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"180A"]]){
        for (CBCharacteristic * characteristic in service.characteristics){
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"2A23"]]){
                [peripheral readValueForCharacteristic:characteristic];
            }
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"2A26"]]){

            }
        }
    }
}


//特征值更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"特征值更新错误%@",error);
        return;
    }
//    NSLog(@"推车反馈的数据%@",characteristic.value);
#pragma mark 适配新版本通道
    if (characteristic == self.readCharacteristic) {
        NSData *receiveData = characteristic.value;
        Byte *byte = (Byte *)[receiveData bytes];           //字节数组  一个字节为一个元素  一个字节决定两个16进制数
        [self.deviceCallBack removeAllObjects];
        [self.deviceCallBack addObject:receiveData];
        if (byte[2] == (receiveData.length - 6)) {
            if (receiveData.length >= 6) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(getValueForPeripheral)]) {
                    [self.delegate getValueForPeripheral];
                }
            }
        }
    }else if (characteristic == self.notifyCharacteristic){
        NSData *receiveData = characteristic.value;
        Byte *byte = (Byte *)[receiveData bytes];
        [self.deviceCallBack removeAllObjects];
        [self.deviceCallBack addObject:receiveData];
        if (byte[2] == (receiveData.length - 6)) {
            if (receiveData.length >= 6) {
                //音乐播放器
                MusicPlayNewController *player;
                if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
                    MainViewController *main = (MainViewController *)[UIViewController presentingVC];
                    if ([[main selectedViewController] isKindOfClass:[DYBaseNaviagtionController class]]) {
                        DYBaseNaviagtionController *navi = [main selectedViewController];
                        if ([[navi topViewController] isKindOfClass:[MusicPlayNewController class]]) {
                            player = (MusicPlayNewController *)[navi topViewController];
                        }
                    }
                }
                
                Byte *byte = (Byte *)[receiveData bytes];
                if (byte[3] == 0x83 && byte[4] == 0x05) {       //上一曲
                    NSLog(@"上一曲");
                    [MUSICMANAGER previous];
                }
                else if (byte[3] == 0x83 && byte[4] == 0x04) {   //下一曲
                    NSLog(@"下一曲");
                    [MUSICMANAGER next];
                }
                else if (byte[3] == 0x83 && byte[4] == 0x01) {   //播放暂停
                    NSLog(@"暂停");
                    [MUSICMANAGER pause];
                    if (player) {
                        [player musicPlayerPauseOrPlay];
                    }
                }
            }
            if ([self.delegate respondsToSelector:@selector(getValueForPeripheral)]) {
                [self.delegate getValueForPeripheral];
            }
        }
    }
    
#pragma mark 适配老版本通道  高景观A1
    /*
     <15fced00 00c2b5d0>
     <4441543a 4d492020 302e302c 20202033 2c20342e>
     <330d0a>
     数据<330d0a>是属于<4441543a 4d492020 302e302c 20202033 2c20342e>的  ，由于数据过长，所以分包发送（数据包最大为20字节）
     */
    CHAR_STRUCT buf1;
    [characteristic.value getBytes:&buf1 length:characteristic.value.length];
    NSMutableString *muString = [NSMutableString new];
    //将数据转成可见命令ascii转码 如DAT:TS
    for(int i =0;i<characteristic.value.length;i++){
        NSString *hexString = [NSString stringWithFormat:@"%02X",buf1.buff[i]&0x000000ff];
        NSString *getString = [Tools stringFromHexString:hexString];
//        NSLog(@"高景观：%@ %@",hexString,getString);
        [muString appendString:getString];
    }
//    NSLog(@"高景观处理的data = %@",muString);
    if ([self.delegate respondsToSelector:@selector(receiveData:)]) {
        [self.delegate receiveData:muString];
    }

#pragma mark 推车已连接但是没有进入推车界面
    if (![NetWorkStatus isNetworkEnvironment]) {
        return;
    }
    //在推车界面那么这里不处理
    if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)[UIViewController presentingVC];
        if ([[main selectedViewController] isKindOfClass:[DYBaseNaviagtionController class]]) {
            DYBaseNaviagtionController *navi = [main selectedViewController]; 
            if ([[navi topViewController] isKindOfClass:[CarOldDetailViewController class]] || [[navi topViewController] isKindOfClass:[CarA3DetailsViewController class]] || [[navi topViewController] isKindOfClass:[CarA4DetailViewController class]] || [[navi topViewController] isKindOfClass:[DeviceViewController class]]) {
                return;
            }
        }
    }
    
    //    牛顿1
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_8101"] || [self.currentDeviceIdentify isEqualToString:@"3POMELOS_A6"]) {
        NSArray *dataArray = self.deviceCallBack;
        if (dataArray == nil || dataArray.count == 0){
            return;
        }
        NSData *data = [dataArray firstObject];
        Byte *byte = (Byte *)[data bytes];
        if (byte[3] == 0x8b && byte[4] == 0x01) { // 获取里程和速度
            int i = (byte[5] << 8) | byte[6];  //平均速度
            int j = (byte[7] << 8) | byte[8];  //今日里程
            int k = (byte[9] << 8) | byte[10];  //总里程
            
            //上传今日里程 速度 总里程
            [NETWorkAPI uploadAverageSpeed:i/10.0 todayMileage:j*10 totalMileage:k/10.0 callback:^(BOOL success, NSError * _Nullable error) {
                //上传成功 重新请求数据
                [self refreshHomeVcMileageData:j*10];
            }];
            return;
        }else if (byte[3] == 0x8b && byte[4] == 0x0A){    //时间同步成功后 请求数据
            [BLEMANAGER writeValueForPeripheral:[BLEA4API notifySuccess]];  //请求界面数据
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getTheLatestDate:^(NSDate *date) {
                    [self.onceDataArray removeAllObjects];
                    if ([BLEMANAGER.A4Version integerValue] >= 102) {
                        [BLEMANAGER writeValueForPeripheral:[BLEA4API getPushDataOnce:date]];   //逐条获取推行数据
                    }else{
                        [BLEMANAGER writeValueForPeripheral:[BLEA4API getPushData:date]];   //全部获取
                    }
                }];
            });
            return;
        }else if (byte[3] == 0x8b && byte[4] == 0x10){    //推行数据
            if (byte[5] == 0xFF) {   //表示为最后一条数据
                //上传数据
                if ([NetWorkStatus isNetworkEnvironment] && [self.onceDataArray isKindOfClass:[NSMutableArray class]] && self.onceDataArray.count > 0) {
                    [self.onceDataArray removeObjectAtIndex:0];   //最新一条数据不上传
                    if (self.onceDataArray.count > 0) {
                        NSDictionary *dict = @{ @"data":self.onceDataArray };
                        [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
                            
                        }];
                    }
                }
            }
            
            if (data.length == 19) {
                long time1   = (byte[6]<<24) + (byte[7]<<16) + (byte[8]<<8) + byte[9];        //开始推行时间
                long time2   = (byte[10]<<24) + (byte[11]<<16) + (byte[12]<<8) + byte[13];    //结束推行时间
                int distance = (byte[14]<<8) + byte[15];
                int pushTime = (byte[16]<<8) + byte[17];

                NSDateFormatter *forme = [[NSDateFormatter alloc] init];
                forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
                NSDate *baseDate = [forme dateFromString:@"1980 01 02 00 00 00"];
                NSDate *beginTime = [NSDate dateWithTimeInterval:time1 sinceDate:baseDate];
                NSDate *endTime = [NSDate dateWithTimeInterval:time2 sinceDate:baseDate];
//                forme.dateFormat = @"YYYY-MM-dd HH:mm:";
//                NSString *beginStr = [NSString stringWithFormat:@"%@00",[forme stringFromDate:beginTime]];
                forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//                beginTime = [forme dateFromString:beginStr];
//                CarA4PushDataModel *model = [[CarA4PushDataModel alloc] initWithStartTime:beginTime endTime:endTime mileage:distance useTime:pushTime];

//                [[pushDataAPI sharedInstance].pushDateArray addObject:model];
//                [[pushDataAPI sharedInstance] startUploadPushData]; //开始上传数据
                if (distance > 0) {
                    [self.onceDataArray addObject:@{  @"mileage":@(distance),
                                                      @"useTime":@(pushTime),
                                                      @"startTime":[forme stringFromDate:beginTime],
                                                      @"endTime":[forme stringFromDate:endTime],
                                                      @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString }];
                }
                
            }
            return;
        }else if (byte[3] == 0x8b && byte[4] == 0x20){    //
            if (byte[2] == 0x00) {   //数据域为0 表示开始获取推行数据的回调
                [BLEMANAGER writeValueForPeripheral:[BLEA4API getSurplusPushData]];  //获取一条数据
            }else if (byte[2] == 0x01){    //数据域为1 表示底层没有数据
                //上传数据
                if ([NetWorkStatus isNetworkEnvironment] && [self.onceDataArray isKindOfClass:[NSMutableArray class]] && self.onceDataArray.count > 0) {
                    [self.onceDataArray removeObjectAtIndex:0];   //最新一条数据不上传
                    if (self.onceDataArray.count > 0) {
                        NSDictionary *dict = @{ @"data":self.onceDataArray };
                        [NETWorkAPI uploadTravelOnce:dict callback:^(BOOL success, NSError * _Nullable error) {
                            
                        }];
                    }
                }
            }else if (byte[2] == 0x0E){    //数据域为14 表示有推行数据
    
                //处理推行数据
                long time1   = (byte[7]<<24) + (byte[8]<<16) + (byte[9]<<8) + byte[10];    //开始推行时间
                long time2   = (byte[11]<<24) + (byte[12]<<16) + (byte[13]<<8) + byte[14];    //结束推行时间
                int distance = (byte[15]<<8) + byte[16];
                int pushTime = (byte[17]<<8) + byte[18];
                
                NSDateFormatter *forme = [[NSDateFormatter alloc] init];
                forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
                NSDate *baseDate = [forme dateFromString:@"1980 01 02 00 00 00"];
                NSDate *beginTime = [NSDate dateWithTimeInterval:time1 sinceDate:baseDate];
                NSDate *endTime = [NSDate dateWithTimeInterval:time2 sinceDate:baseDate];
//                forme.dateFormat = @"YYYY-MM-dd HH:mm:";
//                NSString *beginStr = [NSString stringWithFormat:@"%@00",[forme stringFromDate:beginTime]];
                forme.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//                beginTime = [forme dateFromString:beginStr];
//                CarA4PushDataModel *model = [[CarA4PushDataModel alloc] initWithStartTime:beginTime endTime:endTime mileage:distance useTime:pushTime];
                
//                [[pushDataAPI sharedInstance].pushDateArray addObject:model];
//                [[pushDataAPI sharedInstance] startUploadPushData]; //开始上传数据
                if (distance > 0) {
                    [self.onceDataArray addObject:@{  @"mileage":@(distance),
                                                      @"useTime":@(pushTime),
                                                      @"startTime":[forme stringFromDate:beginTime],
                                                      @"endTime":[forme stringFromDate:endTime],
                                                      @"bluetoothAddress":BLEMANAGER.currentPeripheral.identifier.UUIDString  }];
                }
                
                [BLEMANAGER writeValueForPeripheral:[BLEA4API getSurplusPushData]];  //请求下一条
            }
            return;
        }else if (byte[3] == 0x8b && byte[4] == 0x08){    //刹车次数
//            NSLog(@"%@",BLEMANAGER.deviceCallBack);
            int smartBrakeNum = byte[5] << 24 | byte[6] << 16 | byte[7] << 8 | byte[8];
            int autoBrakeNum = byte[9] << 24 | byte[10] << 16 | byte[11] << 8 | byte[12];
            int sleepNum = byte[13] << 8 | byte[14];
            int shutdownNum = byte[15] << 8 | byte[16];
            //上传智能刹车次数 睡眠次数、、、
            [pushDataAPI uploadSmartBrakeNum:smartBrakeNum autoBrakeNum:autoBrakeNum sleepNum:sleepNum shutdownNum:shutdownNum peri:BLEMANAGER.currentPeripheral];
            return;
            
        }else if (byte[3] == 0x8b && byte[4] == 0x0B){    //固件版本
            BLEMANAGER.A4Version = [NSString stringWithFormat:@"%hhu%hhu%hhu",byte[5],byte[6],byte[7]];
        }
        return;
    }
    
    //    A3
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_A3"]) {
        NSArray *dataArray = self.deviceCallBack;
        if (dataArray.count != 0) {
            NSData *data = [dataArray objectAtIndex:0];
            Byte *byte = (Byte *)[data bytes];
            if (byte[3] == 0x8b && byte[4] == 0x01) { // 获取里程和速度
                int i = (byte[5] << 8) | byte[6];   //平均速度
                int j = (byte[7] << 8) | byte[8];   //今日里程
                int k = (byte[9] << 8) | byte[10];  //总里程
                
                //上传今日里程 速度 总里程
                [NETWorkAPI uploadAverageSpeed:i/10.0 todayMileage:j*10 totalMileage:k/10.0 callback:^(BOOL success, NSError * _Nullable error) {
                    //上传成功 重新请求数据
                    [self refreshHomeVcMileageData:j*10];
                }];
            }
        }
        return;
    }
    
    //    G
    if ([self.currentDeviceIdentify isEqualToString:@"Pomelos_G"]) {
        //拼接数据
        if ([muString containsString:@"DAT"]) {   //如果包含DAT 那么就是一条新命令 清空覆盖之前的命令  一条命令可能需要多个数据包发送过来
            self.carOldData = muString;
        }else{
            self.carOldData = [NSString stringWithFormat:@"%@%@",self.carOldData,muString];
        }
        
        //解析数据  // DAT:MIXXX.X,XXXX,XX.X\r\n  每条完整的命令都是DAT：开头  \r\n结尾
        if ([self.carOldData containsString:@"DAT"] && [self.carOldData containsString:@"\r\n"]) {
            self.carOldData = [self.carOldData substringFromIndex:6];
            NSArray *receives = [self.carOldData componentsSeparatedByString:@","];
            if ([self.carOldData containsString:@"MI"]) { //里程
                if (receives.count == 3) {
                    __block NSInteger todayMileage = 0;
                    __block CGFloat   totalMileage = 0.0;
                    __block CGFloat   averageSpeed = 0.0;
                    [receives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (idx == 0) {  //0 今日里程
                            NSString *item = obj;
                            item = [NSString cleanString:item];
                            todayMileage = [item floatValue]*1000;
                        }
                        if (idx == 1) {  //1 总里程
                            NSString *item = obj;
                            item = [NSString cleanString:item];
                            totalMileage = [item floatValue];
                        }
                        if (idx == 2) {  //2 速度
                            NSString *item = obj;
                            item = [NSString cleanString:item];
                            averageSpeed = [item floatValue];
                            KUserDefualt_Set(item, @"A1_averageSpeed");
                        }
                    }];
                    
                    //上传今日里程 速度 总里程
                    [NETWorkAPI uploadAverageSpeed:averageSpeed todayMileage:todayMileage totalMileage:totalMileage callback:^(BOOL success, NSError * _Nullable error) {
                        //上传成功 重新请求数据
                        [self refreshHomeVcMileageData:todayMileage];
                    }];
                }
            }
            if ([self.carOldData containsString:@"TS"]) { //同步时间信息
                [BLEMANAGER A1_SynchronizationTime];
            }
            if ([self.carOldData containsString:@"FR"]) {
                if (self.carOldData.length > 6) {
                    self.carOldData = [self.carOldData substringFromIndex:6];
                    self.carOldData = [NSString cleanString:self.carOldData];
                    KUserDefualt_Set(self.carOldData, @"A1_Version");
                }
            }
            if ([self.carOldData containsString:@"ET"]) {
                if (receives.count == 2) {
                    [receives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (idx == 1) {
                            NSString *item = obj;
                            item = [NSString cleanString:item];
                            KUserDefualt_Set(item, @"A1_battery");
                        }
                        if (idx == 0) {
                            NSString *item = obj;
                            item = [NSString cleanString:item];
                            item = [NSString stringWithFormat:@"%@",item];
                            KUserDefualt_Set(item, @"A1_temperature");
                        }
                    }];
                }
            }
            //处理完一条命令删除一条
            self.carOldData = nil;
        }
    }
}

-(void)refreshHomeVcMileageData:(NSInteger)todayMileage{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIViewController presentingVC] isKindOfClass:[MainViewController class]]) {
            MainViewController *main = (MainViewController *)[UIViewController presentingVC];
            if ([[main selectedViewController] isKindOfClass:[DYBaseNaviagtionController class]]) {
                DYBaseNaviagtionController *navi = [main selectedViewController];
                if ([[navi topViewController] isKindOfClass:[TripAndMusicViewController class]]) {
                    //刷新首页
                    TripAndMusicViewController *home = (TripAndMusicViewController *)[navi topViewController];
//                    [home requestData:NO];
                    [home updateTodayMileage:todayMileage];
                }
            }
        }
    });
}

//特征值写入(修改)成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
//        NSLog(@"写入失败%@",error);
    }else{
//        NSLog(@"写入成功");
        [self CL_readValue:0xA032 characteristicUUID:0xA041];
    }
}

//特征值监听状态改变
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"特征监听状态改变 = %@",characteristic);
}

////从活跃的正在操作的特征值描述中获得特征描述
//- (id)_getCharcteristicDiscriptorFromCurrnetActiveDescriptorsArray:(CBCharacteristic *)characteristic{
//    for (NSInteger i = 0; i < self.currentActiveDescriptors.count; i ++) {
//        CBDescriptor *p = [self.currentActiveDescriptors objectAtIndex:i];
//        if (p.characteristic.UUID == characteristic.UUID) {
//            return p.value;
//        }
//    }
//    return nil;
//}
// 判断当前特征值是否是活跃的(正在连接中的)
//- (BOOL)_isActiveCharacteristic:(CBCharacteristic *)characteristic{
//    for(int i = 0; i < self.currentActiveCharacteristics.count; i++) {      //看看当前在活跃状态的特征数组中有没有指定的特征
//        CBCharacteristic *p = [self.currentActiveCharacteristics objectAtIndex:i];
//        if (p.UUID == characteristic.UUID) {
//            return YES;
//        }
//    }
//    DLog(@"isn't Active characteristics !\r\n");
//    return NO;
//}
// 打印特征值描述
//- (void)_logCharacteristicDescriptorMessage:(CBDescriptor *)descriptor{
//    CBCharacteristic *c = descriptor.characteristic;
//    DLog(@" service.UUID:%@ (%s)",c.service.UUID,[self CBUUIDToString:c.service.UUID]);
//    DLog(@"         UUID:%@ (%s)",c.UUID,[self CBUUIDToString:c.UUID]);
//    DLog(@"   properties:0x%02lx",(unsigned long)c.properties);
//    DLog(@" value.length:%lu",c.value.length);
//    INT_STRUCT buf1;
//    [c.value getBytes:&buf1 length:c.value.length];
//    DLog(@"                                                       value:");
//    for(int i=0; i < c.value.length; i++) {
//        DLog(@"%02x ",buf1.buff[i]&0x000000ff);
//    }
//    DLog(@"\r\n");
//    DLog(@"  isNotifying:%d\r\n",c.isNotifying);
//    DLog(@"      :%@ ",c.UUID);
//    DLog(@"  UUID:%@ ",descriptor.UUID);
//    DLog(@"    id:%@ ",descriptor.value);
//}
@end
