# iBeaconForHBuilder
=======

## Plugin for scan iBeacon
###  概述

智石iBeaconForHBuilder，提供了扫描iBeacon、ble设备、配置设备参数、模拟iBeacon等API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多iBeacon设备信息，或前往我们的[开发者社区（http://bbs.brtbeacon.com）](http://bbs.brtbeacon.com)交流和找到我们软硬件相关问题。

iBeacon需要手持设备硬件支持蓝牙4.0及其以上，并要求系统版本IOS7及其以上。
附：支持的IOS设备列表
iphone4s及以上、
itouch5及以上、
iPad3及以上、
iPad mini均可以
详情见：[http://en.wikipedia.org/wiki/List_of_iOS_devices](http://en.wikipedia.org/wiki/List_of_iOS_devices)

## 更新日志
 *  1.0.0 Plugin for scan iBeacon
 
## API使用说明

 
- 检测CLLocationManager、CBCentralManager可用性。持续监测蓝牙状态并callback
 


```
- (void)isRangingAvailable:(PGMethod *)command;
```

- 请求完全定位权限
 

```
- (void)requestAlwaysAuthorization:(PGMethod *)cmd;
```

- 请求运行时定位权限
 

```
- (void)requestWhenInUseAuthorization:(PGMethod *)cmd;
```

- 监听中的Region，返回参数：[{uuid,major,minor,in,out,display,identifier},...]
 

```
- (NSData *)monitoredRegions:(PGMethod *)cmd;
```

- 扫描中的Region，返回参数：[{uuid,major,minor,identifier},...]
 

```
- (NSData *)rangedRegions:(PGMethod *)cmd;
```

- 扫描符合region中的iBeacon设备
 传入参数：{uuid,major,minor,identifier}
 持续返回参数：[{uuid,major,minor,identifier},...]
 

```
- (void)startRangingBeaconsInRegion:(PGMethod *)cmd;
```

- 停止扫描符合region中的iBeacon设备，传入参数：{uuid,major,minor,identifier}
 

```
- (void)stopRangingBeaconsInRegion:(PGMethod *)cmd;
```

- 监听符合region中的iBeacon设备
 传入参数：{uuid,major,minor,in,out,display,identifier}
 持续返回参数：{region:{uuid,major,minor,in,out,display,identifier},state:1}
 

```
- (void)startMonitoringForRegion:(PGMethod *)cmd;
```

- 停止监听符合region中的iBeacon设备，传入参数：{uuid,major,minor,identifier}
 

```
- (void)stopMonitoringForRegion:(PGMethod *)cmd;
```

- 请求是否有iBeacon设备在区域region内，传入参数：{uuid,major,minor,identifier}
 

```
- (void)requestStateForRegion:(PGMethod *)cmd;
```

- 请求本地通知权限
 

```
- (void)registerLocalNotification:(PGMethod *)cmd;
```

- 发送本地通知，传入参数：{title,subtitle,body,info}
 

```
- (void)sendLocalNotification:(PGMethod *)cmd;
```

- 获取点击通知中心点击启动APP的通知信息，返回参数：{title,subtitle,body,info}
 

```
- (void)onAppStartByLocalNotification:(PGMethod *)cmd;
```

- 开始广播iBeacon信号，传入参数：{uuid,major,minor,identifier} （或广播serviceUUIDs，传入参数：{services:[服务CBUUID,...]}）
 

```
- (void)startAdvertising:(PGMethod *)commands;
```

- 停止广播信息
 

```
- (void)stopAdvertising:(PGMethod *)commands;
```

- 扫描蓝牙信号
 传入可选参数：{uuids,duplicate}，默认扫描所有uuids，duplicate为YES
 持续返回参数：{peripheral,rssi,设备广播信息...}
 

```
- (void)scanForPeripheralsWithServices:(PGMethod *)commands;
```

- 停止扫描蓝牙信号
 

```
- (void)stopScan:(PGMethod *)commands;
```

- 连接蓝牙设备，请传人扫描返回的设备peripheral参数。持续返回参数：{service,characteristics}


```
 - (void)connectPeripheral:(PGMethod *)commands;
```

- 断开连接蓝牙设备，传人扫描的peripheral参数或空串""，空串尝试断开所有peripheral
 

```
- (void)disconnectPeripheral:(PGMethod *)commands;
```

- 读取连接蓝牙设备特征，传人依次参数：peripheral,characteristic。返回参数：{data:}
 

```
- (void)readPeripheralCharacteristic:(PGMethod *)commands;
```

- 写入连接蓝牙设备特征，传人依次参数：peripheral,service,characteristic,data,response。返回参数：{data:}
 

```
- (void)writePeripheralCharacteristic:(PGMethod *)commands;
```

## 相关文档或网站
* [API文档](https://brightbeacon.github.io/iBeaconForHBuilder)
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)