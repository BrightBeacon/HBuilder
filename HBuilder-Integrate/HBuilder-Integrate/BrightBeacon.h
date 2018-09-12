//
//  iBeacon.h
//  HBuilder
//
//  Created by apple on 2018/8/27.
//  Copyright © 2018年 DCloud. All rights reserved.
//
#include "PGPlugin.h"
#include "PGMethod.h"
#import <Foundation/Foundation.h>

@interface BrightBeacon : PGPlugin


/**
 检测CLLocationManager、CBCentralManager可用性。持续监测蓝牙状态并callback
 */
- (void)isRangingAvailable:(PGMethod *)command;

/**
 请求完全定位权限
 */
- (void)requestAlwaysAuthorization:(PGMethod *)cmd;

/**
 请求运行时定位权限
 */
- (void)requestWhenInUseAuthorization:(PGMethod *)cmd;

/**
 监听中的Region，返回参数：[{uuid,major,minor,in,out,display,identifier},...]
 */
- (NSData *)monitoredRegions:(PGMethod *)cmd;

/**
 扫描中的Region，返回参数：[{uuid,major,minor,identifier},...]
 */
- (NSData *)rangedRegions:(PGMethod *)cmd;

/**
 扫描符合region中的iBeacon设备
 传入参数：{uuid,major,minor,identifier}
 持续返回参数：[{uuid,major,minor,identifier},...]
 */
- (void)startRangingBeaconsInRegion:(PGMethod *)cmd;

/**
 停止扫描符合region中的iBeacon设备，传入参数：{uuid,major,minor,identifier}
 */
- (void)stopRangingBeaconsInRegion:(PGMethod *)cmd;

/**
 监听符合region中的iBeacon设备
 传入参数：{uuid,major,minor,in,out,display,identifier}
 持续返回参数：{region:{uuid,major,minor,in,out,display,identifier},state:1}
 */
- (void)startMonitoringForRegion:(PGMethod *)cmd;

/**
 停止监听符合region中的iBeacon设备，传入参数：{uuid,major,minor,identifier}
 */
- (void)stopMonitoringForRegion:(PGMethod *)cmd;

/**
 请求是否有iBeacon设备在区域region内，传入参数：{uuid,major,minor,identifier}
 */
- (void)requestStateForRegion:(PGMethod *)cmd;

/**
 请求本地通知权限
 */
- (void)registerLocalNotification:(PGMethod *)cmd;

/**
 发送本地通知，传入参数：{title,subtitle,body,info}
 */
- (void)sendLocalNotification:(PGMethod *)cmd;

/**
 获取点击通知中心点击启动APP的通知信息，返回参数：{title,subtitle,body,info}
 */
- (void)onAppStartByLocalNotification:(PGMethod *)cmd;

/**
 开始广播iBeacon信号，传入参数：{uuid,major,minor,identifier} （或广播serviceUUIDs，传入参数：{services:[服务CBUUID,...]}）
 */
- (void)startAdvertising:(PGMethod *)commands;

/**
 停止广播信息
 */
- (void)stopAdvertising:(PGMethod *)commands;

/**
 扫描蓝牙信号
 传入可选参数：{uuids,duplicate}，默认扫描所有uuids，duplicate为YES
 持续返回参数：{peripheral,rssi,设备广播信息...}
 */
- (void)scanForPeripheralsWithServices:(PGMethod *)commands;

/**
 停止扫描蓝牙信号
 */
- (void)stopScan:(PGMethod *)commands;

/**
 连接蓝牙设备，请传人扫描返回的设备peripheral参数。持续返回参数：{service,characteristics}
*/
 - (void)connectPeripheral:(PGMethod *)commands;

/**
 断开连接蓝牙设备，传人扫描的peripheral参数或空串""，空串尝试断开所有peripheral
 */
- (void)disconnectPeripheral:(PGMethod *)commands;

/**
 读取连接蓝牙设备特征，传人依次参数：peripheral,characteristic。返回参数：{data:}
 */
- (void)readPeripheralCharacteristic:(PGMethod *)commands;

/**
 写入连接蓝牙设备特征，传人依次参数：peripheral,service,characteristic,data,response。返回参数：{data:}
 */
- (void)writePeripheralCharacteristic:(PGMethod *)commands;

@end
