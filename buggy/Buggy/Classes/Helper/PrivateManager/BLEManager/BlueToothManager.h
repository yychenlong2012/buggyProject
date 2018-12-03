//
//  BLEManager.h
//  bluetooth
//
//  Created by goat on 2017/10/10.
//  Copyright © 2017年 goat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BLEMANAGER [BlueToothManager manager]

@protocol BlueToothManagerDelegate <NSObject>

@optional
//已经发现蓝牙设备
-(void)didDiscoverPeripheral:(NSMutableArray<CBPeripheral *>*)peripherals;
//已经连接到蓝牙设备
-(void)didConnectPeripheral:(CBPeripheral*)peripherial;
//连接错误
-(void)BLE_connectError;
//已经断开蓝牙外设
-(void)didDisconnectPeripheral:(CBPeripheral*)peripheral;  
//已经扫描完毕
-(void)stopScanDevices;
//手机蓝牙设备已经打开
-(void)BLE_BlueToothOpen;
//接收到蓝牙数据A3
-(void)getValueForPeripheral;  
//接收数据A1
- (void)receiveData:(NSString *)data;

@end


@interface BlueToothManager : NSObject

@property (nonatomic,weak) id<BlueToothManagerDelegate> delegate;

@property (nonatomic,strong) NSMutableArray<CBPeripheral*> *discoveredPeripherals; //扫描到的蓝牙设备(通过了名字和信号强度rssi的筛选)
@property (nonatomic,strong) CBPeripheral *currentPeripheral;             //当前已经连接的蓝牙外设     不为空即为已连接蓝牙
//@property (nonatomic,strong) NSString *currentIdentifer;                  //当前已经连接蓝牙的型号标识
@property (nonatomic,strong) NSMutableArray *deviceCallBack;                    //蓝牙返回数据 或命令
@property (nonatomic,strong) CBCentralManager *centralManager;                 //蓝牙中心管理者
@property (nonatomic,strong) NSString *A4Version;     //牛顿推车固件版本

+ (instancetype)manager;                 //单粒方法
- (void)CL_initializeCentralManager;    //初始化中心管理者

#pragma mark - d
- (void)startScanBLEWithTimeout:(NSTimeInterval)timeout;   //开始扫描外围设备 设置超时
- (void)stopScanBLE;
- (void)connectPeripheralDevice:(CBPeripheral *)peripheral;    //开始连接指定的蓝牙设备
- (void)cancelConnect;       //断开当前连接的蓝牙设备
- (BOOL)isConnectedBluetooth;          //蓝牙是否已连接
#pragma mark - 数据写入和读取
/**
 *  A3新版本数据写入  发给蓝牙外设
 *  serviceUUID           0xA032
 *  characteristicUUID    0xA040
 */
- (void)writeValueForPeripheral:(NSData *)data;

#pragma mark - 数据处理 数据转换 转换成蓝牙可接受的命令
//根据背光等级生成命令
- (NSData *)transformDataForBacklight:(NSInteger)lightClass;

/*---------A1高景观车开始接收数据---------*/
- (void)startReceiveData;                   //接收数据
- (void)A1_stopReceiveData;                    //停止接收
- (void)A1_SynchronizationTime;                //同步时间
- (void)A1_sendDataToDevice:(NSString *)data;   //发送数据
@end
