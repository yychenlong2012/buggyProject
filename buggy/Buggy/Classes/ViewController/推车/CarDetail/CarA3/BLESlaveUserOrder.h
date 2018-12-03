//
//  BLESlaveUserOrder.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#ifndef BLESlaveUserOrder_h
#define BLESlaveUserOrder_h


#define SLAVE_USER_GET_REPONSE_DEFAULTA3      0X8B //A3设备默认的 HH 的响应指令
#define SLAVE_USER_GET_REQUEST_DEFAULTA3      0X0B //A3设备默认的 HH 的发出指令


#define SLAVE_USER_GET_SPEED_MILEAGE  0X01 //获取今日平均速度
#define SLAVE_USER_GET_BREAK_STATUS   0X04 //获取刹车状态
#define SLAVE_USER_SET_BREAK_ON       0X05 //刹车
#define SLAVE_USER_SET_BREAK_OFF      0X06 //解刹
#define SLAVE_USER_GET_POWER_STATUS   0X07 //电量获取
#define SLAVE_USER_SET_POWER_DOWN     0XAA //一键关机
#define SLAVE_USER_SET_CHECK_REPEAR   0X55 //检测修复
#define SLAVE_USER_GET_STROLLER_DATA  0X08 //获取推车参数
#define SLAVE_USER_SET_BACKLIGHT      0X09 //设置按键背光
#define SLAVE_USER_SET_TIME           0X0A //设置时间同步


#endif /* BLESlaveUserOrder_h */
