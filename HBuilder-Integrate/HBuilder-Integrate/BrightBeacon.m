//
//  iBeacon.m
//  HBuilder
//
//  Created by apple on 2018/8/27.
//  Copyright © 2018年 DCloud. All rights reserved.
//

#import "BrightBeacon.h"
#import "PDRCoreAppFrame.h"
#import "H5WEEngineExport.h"
#import "PDRToolSystemEx.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

typedef NS_ENUM(NSUInteger, iBeaconError) {
    iBeaconRangingInvailable = 100,
    iBeaconLocationAuthoriztion,
    iBeaconBluetoothInvailable,
};

@interface BrightBeacon ()<CLLocationManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
//扫描iBeacon及蓝牙权限检测
@property (nonatomic,strong) CLLocationManager      *locationManager;
@property (nonatomic,strong) CBPeripheralManager    *peripheralManager;
@property (nonatomic,strong) CBCentralManager       *centralManager;

//暂存
@property (nonatomic,strong) NSMutableDictionary *callbackIds;
@property (nonatomic,strong) id onStartByNotification;

@property (nonatomic,strong) NSMutableDictionary *peripherals;
@property (nonatomic,strong) NSMutableDictionary *characteristics;
@end

@implementation BrightBeacon
#pragma mark 这个方法在使用WebApp方式集成时触发，WebView集成方式不触发

/*
 * WebApp启动时触发
 * 需要在PandoraApi.bundle/feature.plist/注册插件里添加autostart值为true，global项的值设置为true
 */
- (void) onAppStarted:(NSDictionary*)options{
    
    //NSLog(@"5+ WebApp启动时触发");
    // 可以在这个方法里向Core注册扩展插件的JS
    self.callbackIds = [NSMutableDictionary dictionary];
    /* APP未启动，点击推送消息的情况下 iOS10遗弃UIApplicationLaunchOptionsLocalNotificationKey，
     使用代理UNUserNotificationCenterDelegate方法didReceiveNotificationResponse:withCompletionHandler:获取本地推送
     */
    UILocalNotification *notification = options[UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        //NSLog(@"localUserInfo:%@",notification);
        //APP未启动，点击推送消息
        self.onStartByNotification = notification;
    }
}

// 监听基座事件事件
// 应用退出时触发
- (void) onAppTerminate{
    //NSLog(@"APPDelegate applicationWillTerminate 事件触发时触发");
}

// 应用进入后台时触发
- (void) onAppEnterBackground{
    //NSLog(@"APPDelegate applicationDidEnterBackground 事件触发时触发");
}

// 应用进入前天时触发
- (void) onAppEnterForeground{
    //NSLog(@"APPDelegate applicationWillEnterForeground 事件触发时触发");
}

#pragma mark 以下为插件方法，由JS触发， WebView集成和WebApp集成都可以触发

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)onAppStartByLocalNotification:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    if (self.onStartByNotification) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if ([self.onStartByNotification isKindOfClass:[UILocalNotification class]]) {
            UILocalNotification *notify = (UILocalNotification *)self.onStartByNotification;
            NSString *title = notify.alertTitle;
            NSString *body = notify.alertBody;
            NSString *subtitle = notify.alertAction;
            NSDictionary *userInfo = notify.userInfo;
            if (title.length) {
                [params setValue:title forKey:@"title"];
            }
            if (body.length) {
                [params setValue:body forKey:@"body"];
            }
            if (subtitle.length) {
                [params setValue:subtitle forKey:@"subtitle"];
            }
            if (userInfo) {
                [params setObject:userInfo forKey:@"info"];
            }
            
        }else if ([self.onStartByNotification isKindOfClass:[UNNotification class]]) {
            UNNotification *notify = (UNNotification *)self.onStartByNotification;
            NSString *title = notify.request.content.title;
            NSString *body = notify.request.content.body;
            NSString *subtitle = notify.request.content.subtitle;
            NSDictionary *userInfo = notify.request.content.userInfo;
            if (title.length) {
                [params setValue:title forKey:@"title"];
            }
            if (body.length) {
                [params setValue:body forKey:@"body"];
            }
            if (subtitle.length) {
                [params setValue:subtitle forKey:@"subtitle"];
            }
            if (userInfo) {
                [params setObject:userInfo forKey:@"info"];
            }
        }
        self.onStartByNotification = nil;
        PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsDictionary:params];
        return [self toCallback:pcbid withReslut:[result toJSONString]];
    }
}

- (void)isRangingAvailable:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    if (![CLLocationManager isRangingAvailable]) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"Ranging Not Available."}];
    }
    if ([CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@2,@"message":[NSString stringWithFormat:@"Location Authoriztion State %d.",[CLLocationManager authorizationStatus]]}];
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey, nil];
    if(!self.centralManager)self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:options];
    [self.callbackIds setObject:pcbid forKey:NSStringFromSelector(_cmd)];
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString *pcbId = [self.callbackIds objectForKey:@"isRangingAvailable:"];
    if (pcbId) {
        if (central.state == 5) {
            [self toSucessCallback:pcbId withJSON:@{@"error":@0} keepCallback:YES];
        }else{
            NSString *message = [NSString stringWithFormat:@"bluetooth state %ld",central.state];
            [self toSucessCallback:pcbId withJSON:@{@"error":@3,@"message":message} keepCallback:YES];
        }
    }
}

- (void)requestAlwaysAuthorization:(PGMethod *)cmd {
    [self.locationManager requestAlwaysAuthorization];
    NSString* pcbid = [cmd.arguments objectAtIndex:0];
    [self.callbackIds setObject:pcbid forKey:NSStringFromSelector(_cmd)];
}

- (void)requestWhenInUseAuthorization:(PGMethod *)cmd {
    [self.locationManager requestWhenInUseAuthorization];
    NSString* pcbid = [cmd.arguments objectAtIndex:0];
    [self.callbackIds setObject:pcbid forKey:NSStringFromSelector(_cmd)];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSString *pcbId = [self.callbackIds valueForKeyPath:@"requestWhenInUseAuthorization:"];
    if (pcbId) {
        [self toSucessCallback:pcbId withJSON:@{@"state":@(status)} keepCallback:YES];
    }
    pcbId = [self.callbackIds objectForKey:@"requestAlwaysAuthorization:"];
    if (pcbId) {
        [self toSucessCallback:pcbId withJSON:@{@"state":@(status)} keepCallback:YES];
    }
}

- (NSData *)monitoredRegions:(PGMethod *)cmd {
    NSSet<CLRegion*> *regions = [self.locationManager monitoredRegions];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:regions.count];
    for (CLBeaconRegion *region in regions) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            if (region.minor) {
                [marray addObject:@{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"minor":region.minor.stringValue,@"identifier":region.identifier}];
            }else if(region.major) {
                [marray addObject:@{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"identifier":region.identifier}];
            }else {
                [marray addObject:@{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"identifier":region.identifier}];
            }
        }
    }
    NSString* cbId = [cmd.arguments objectAtIndex:0];
    
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray:marray];
    [self toCallback:cbId withReslut:[result toJSONString]];
    return [self resultWithArray:marray];
}
- (NSData *)rangedRegions:(PGMethod *)cmd {
    NSSet<CLRegion*> *regions = [self.locationManager rangedRegions];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:regions.count];
    for (CLBeaconRegion *region in regions) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            if (region.minor) {
                [marray addObject:@{@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"minor":region.minor.stringValue,@"identifier":region.identifier}];
            }else if(region.major) {
                [marray addObject:@{@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"identifier":region.identifier}];
            }else {
                [marray addObject:@{@"uuid":region.proximityUUID.UUIDString,@"identifier":region.identifier}];
            }
        }
    }
    NSString* cbId = [cmd.arguments objectAtIndex:0];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray:marray];
    [self toCallback:cbId withReslut:[result toJSONString]];
    return [self resultWithArray:marray];
}

- (CLBeaconRegion *)createBeaconRegion:(PGMethod *)commands {
    NSDictionary* regionDic = [commands.arguments objectAtIndex:1];
    if ([regionDic isEqual:[NSNull null]]) {
        return nil;
    }
    NSString *uuid = [regionDic objectForKey:@"uuid"];
    NSString *major = [regionDic objectForKey:@"major"];
    NSString *minor = [regionDic objectForKey:@"minor"];
    NSString *identifier = [regionDic objectForKey:@"identifier"];
    if (uuid.length!=36) {
        return nil;
    }
    NSUUID *regionUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    CLBeaconRegion *region = nil;
    if (minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID major:major.intValue minor:minor.intValue identifier:identifier?:uuid];
    }else if(major) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID major:major.intValue identifier:identifier?:uuid];
    }else {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID identifier:identifier?:uuid];
    }
    region.notifyOnEntry = [[regionDic valueForKey:@"in"] boolValue];
    region.notifyOnExit = [[regionDic valueForKey:@"out"] boolValue];
    region.notifyEntryStateOnDisplay = [[regionDic valueForKey:@"display"] boolValue];
    return region;
}

- (void)startRangingBeaconsInRegion:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    if (!region) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"region is null"}];
    }else{
        [self.callbackIds setValue:pcbid forKey:[@"startRangingBeaconsInRegion:" stringByAppendingString:region.identifier]];
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

- (void)startMonitoringForRegion:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    if (!region) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"region is null"}];
    }else{
        [self.callbackIds setObject:pcbid forKey:region.identifier];
        [self.locationManager startMonitoringForRegion:region];
    }
}

- (void)stopMonitoringForRegion:(PGMethod *)commands {
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    if (region != nil) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)stopRangingBeaconsInRegion:(PGMethod *)commands {
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    if (region != nil) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

//待测同时多个，会不会覆盖回调id。。
- (void)requestStateForRegion:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    if (!region) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"region is null"}];
    }else{
        [self.callbackIds setObject:pcbid forKey:[NSStringFromSelector(_cmd) stringByAppendingString:region.identifier]];
        [self.locationManager requestStateForRegion:region];
    }
}

- (void)startAdvertising:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    CLBeaconRegion *region = [self createBeaconRegion:commands];
    NSDictionary *advertise = nil;
    if (region) {
        NSDictionary* regionDic = [commands.arguments objectAtIndex:1];
        NSNumber *mpower = [regionDic valueForKey:@"measuredpower"];
        advertise = [region peripheralDataWithMeasuredPower:mpower?@(mpower.intValue):@-65];
    }
    if (advertise == nil) {
        NSArray *services = [[commands.arguments objectAtIndex:1] valueForKey:@"services"];
        if (services.count) {
            NSMutableArray *marr = [NSMutableArray arrayWithCapacity:services.count];
            for (NSString *uuid in services) {
                CBUUID *cbuuid = [CBUUID UUIDWithString:uuid];
                [marr addObject:cbuuid];
            }
            advertise = @{CBAdvertisementDataServiceUUIDsKey:marr};
        }
    }
    if (!advertise) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"advertise data is null"}];
    }
    
    [self.callbackIds setObject:pcbid forKey:NSStringFromSelector(_cmd)];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey, nil];
    if(!self.peripheralManager)self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:options];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.peripheralManager startAdvertising:advertise];
        });
    });
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    NSString* pcbid = [self.callbackIds valueForKey:@"startAdvertising:"];
    if (pcbid) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@(!!error),@"message":error?error.localizedDescription:@""}];
    }
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    NSString* pcbid = [self.callbackIds valueForKey:@"startAdvertising:"];
    if (pcbid) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@(peripheral.state!=5),@"message":[NSString stringWithFormat:@"peripheral state %ld",peripheral.state]}];
    }
}


- (void)stopAdvertising:(PGMethod *)commands {
    [self.peripheralManager stopAdvertising];
    self.peripheralManager = nil;
}

- (void)scanForPeripheralsWithServices:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    [self.callbackIds setObject:pcbid forKey:NSStringFromSelector(_cmd)];
    NSMutableArray *services = nil;
    BOOL AllowDuplicate = YES;
    NSDictionary *params = [commands.arguments objectAtIndex:1];
    if (![params isEqual: [NSNull null]]) {
        services = [NSMutableArray array];
        for (NSString *uuid in [params valueForKey:@"uuids"]) {
            [services addObject:[CBUUID UUIDWithString:uuid]];
        }
        if([params valueForKey:@"duplicate"])AllowDuplicate = [[params valueForKey:@"duplicate"] boolValue];
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey, nil];
    if(!self.centralManager)
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:options];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(AllowDuplicate)}];
        });
    });
}

- (void)stopScan:(PGMethod *)commands {
    [self.centralManager stopScan];
}

#pragma mark - **************** scan Delegate
- (id)convertToString:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }else if ([obj isKindOfClass:[NSData class]]) {
        return [[[obj description] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    }else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
        for (id key in [obj allKeys]) {
            [mdic setObject:[self convertToString:obj[key]] forKey:[self convertToString:key]];
        }
        return mdic;
    }else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *marr = [NSMutableArray array];
        for (id o in obj) {
            [marr addObject:[self convertToString:o]];
        }
        return marr;
    }else if([obj isKindOfClass:[CBUUID class]]){
        return [self convertToString:[obj data]];
    }
    return [obj description];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI  {
    NSString *cbid = [self.callbackIds valueForKey:@"scanForPeripheralsWithServices:"];
    if (cbid) {
        if (self.peripherals == nil) {
            self.peripherals = [NSMutableDictionary dictionary];
        }
        NSString *identifier = peripheral.identifier.UUIDString;
        [self.peripherals setObject:peripheral forKey:identifier];
        NSMutableDictionary *desc  = [self convertToString:advertisementData];
        [desc setObject:identifier forKey:@"peripheral"];
        [desc setObject:RSSI forKey:@"rssi"];
        [self toSucessCallback:cbid withJSON:desc keepCallback:YES];
    }
}
- (void)connectPeripheral:(PGMethod *)commands  {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    NSString* identifier = [commands.arguments objectAtIndex:1];
    CBPeripheral *peripheral = [self.peripherals valueForKey:identifier];
    if (peripheral == nil) {
        [self toCallback:pcbid withReslut:nil];
    }
    if (peripheral.state == CBPeripheralStateConnected) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    [self.callbackIds setObject:pcbid forKey:identifier];
    [self.centralManager connectPeripheral:peripheral options:nil];
}
- (void)disconnectPeripheral:(PGMethod *)commands {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    NSString* identifier = [commands.arguments objectAtIndex:1];
    CBPeripheral *peripheral = [self.peripherals valueForKey:identifier];
    if (peripheral) {
        [self.centralManager cancelPeripheralConnection:peripheral];
        [self toSucessCallback:pcbid withJSON:@{@"error":@0}];
    }else if(identifier.length == 0){
        for (CBPeripheral *p in self.peripherals.allValues) {
            [self.centralManager cancelPeripheralConnection:p];
        }
        [self toSucessCallback:pcbid withJSON:@{@"error":@0,@"message":@"disconnect all."}];
    }else{
        [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"peripheral not found"}];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //call bracelet delegate
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString *cbid = [self.callbackIds valueForKey:peripheral.identifier.UUIDString];
    if (cbid)[self toSucessCallback:cbid withJSON:@{@"error":@3,@"message":error.localizedDescription}];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString *cbid = [self.callbackIds valueForKey:peripheral.identifier.UUIDString];
    if (cbid)[self toSucessCallback:cbid withJSON:@{@"error":@2,@"message":error.localizedDescription}];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (error) {
        NSString *cbid = [self.callbackIds valueForKey:peripheral.identifier.UUIDString];
        if (cbid)[self toSucessCallback:cbid withJSON:@{@"error":@1,@"message":error.localizedDescription}];
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSString *cbid = [self.callbackIds valueForKey:peripheral.identifier.UUIDString];
        if (cbid)[self toSucessCallback:cbid withJSON:@{@"error":@2,@"message":error.localizedDescription}];
        return;
    }
    if (self.characteristics == nil) {
        self.characteristics = [NSMutableDictionary dictionary];
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        [self.characteristics setObject:characteristic forKey:characteristic.UUID.UUIDString];
    }
    NSDictionary *json = @{@"error":@0,@"service":service.UUID.UUIDString,@"characteristics":[service.characteristics valueForKeyPath:@"UUID.UUIDString"]};
    NSString *cbid = [self.callbackIds valueForKey:peripheral.identifier.UUIDString];
    if (cbid) {
        [self toSucessCallback:cbid withJSON:json keepCallback:YES];
    }
}

#pragma mark - **************** readPeripheralCharacteristic
- (void)readPeripheralCharacteristic:(PGMethod *)commands  {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    NSString *peripheralKey = [commands.arguments objectAtIndex:1];
    assert(peripheralKey.length);
    CBPeripheral *peripheral = [self.peripherals valueForKey:peripheralKey];
    if (peripheral == nil) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"peripheral not found."}];
    }
    if (peripheral.state != 2) {
        NSString *message = [NSString stringWithFormat:@"peripheral connect state %ld.",peripheral.state];
        return [self toSucessCallback:pcbid withJSON:@{@"error":@3,@"message":message}];
    }
    NSString *characteristicKey = [commands.arguments objectAtIndex:2];
    CBCharacteristic *c = [self.characteristics valueForKey:characteristicKey];
    if (c == nil) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@2,@"message":@"characteristic not found."}];
    }
    [self.callbackIds setObject:pcbid forKey:[peripheralKey stringByAppendingString:characteristicKey]];
    [peripheral readValueForCharacteristic:c];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *key = [peripheral.identifier.UUIDString stringByAppendingString:characteristic.UUID.UUIDString];
    NSString *pcbid = [self.callbackIds valueForKey:key];
    if (pcbid) {
        if (error) {
            [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":error.localizedDescription} keepCallback:YES];
        }else{
            [self toSucessCallback:pcbid withJSON:@{@"error":@0,@"data":[self convertToString:characteristic.value]} keepCallback:YES];
        }
    }
}

#pragma mark - **************** title
-(NSData *)hexStringToData:(NSString *)hexString{
    const char *chars = [hexString UTF8String];
    int i = 0;
    int len = (int)hexString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i<len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

- (void)writePeripheralCharacteristic:(PGMethod *)commands  {
    NSString* pcbid = [commands.arguments objectAtIndex:0];
    NSString *peripheralKey = [commands.arguments objectAtIndex:1];
    assert(peripheralKey.length);
    CBPeripheral *peripheral = [self.peripherals valueForKey:peripheralKey];
    if (peripheral == nil) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@1,@"message":@"peripheral not found."}];
    }
    if (peripheral.state != 2) {
        NSString *message = [NSString stringWithFormat:@"peripheral connect state %ld.",peripheral.state];
        return [self toSucessCallback:pcbid withJSON:@{@"error":@3,@"message":message}];
    }
    NSString *characteristicKey = [commands.arguments objectAtIndex:2];
    assert(characteristicKey.length);
    CBCharacteristic *c = [self.characteristics valueForKey:characteristicKey];
    if (c == nil) {
        return [self toSucessCallback:pcbid withJSON:@{@"error":@2,@"message":@"characteristic not found."}];
    }
    [self.callbackIds setObject:pcbid forKey:[peripheralKey stringByAppendingString:characteristicKey]];
    NSString *data = [commands.arguments objectAtIndex:3];
    BOOL response = [[commands.arguments objectAtIndex:4] boolValue];
    [peripheral writeValue:[self hexStringToData:data] forCharacteristic:c type:response?CBCharacteristicWriteWithResponse:CBCharacteristicWriteWithoutResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSString *key = [peripheral.identifier.UUIDString stringByAppendingString:characteristic.UUID.UUIDString];
    NSString *pcbid = [self.callbackIds valueForKey:key];
    if (pcbid) {
        [self toSucessCallback:pcbid withJSON:@{@"error":@0,@"data":[self convertToString:characteristic.value]} keepCallback:YES];
    }
}

#pragma mark - delegate

- (NSDictionary *)regionToDic:(CLBeaconRegion *)region {
    NSDictionary *dic = nil;
    if (region.minor) {
        dic  = @{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"minor":region.minor.stringValue,@"identifier":region.identifier};
    }else if(region.major) {
        dic  =@{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"major":region.major.stringValue,@"identifier":region.identifier};
    }else {
        dic  =@{@"in":@(region.notifyOnEntry),@"out":@(region.notifyOnExit),@"display":@(region.notifyEntryStateOnDisplay),@"uuid":region.proximityUUID.UUIDString,@"identifier":region.identifier};
    }
    return dic;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    NSString *cbId = [self.callbackIds objectForKey:region.identifier];
    if (cbId&&[region isKindOfClass:[CLBeaconRegion class]]) {
        [self toSucessCallback:cbId withJSON:@{@"error":@0,@"region":[self regionToDic:region],@"state":@(CLRegionStateInside)} keepCallback:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region {
    NSString *cbId = [self.callbackIds objectForKey:region.identifier];
    if (cbId&&[region isKindOfClass:[CLBeaconRegion class]]) {
        [self toSucessCallback:cbId withJSON:@{@"error":@0,@"region":[self regionToDic:region],@"state":@(CLRegionStateOutside)} keepCallback:YES];
    }
}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region {
    NSString *requestKey = [@"requestStateForRegion:" stringByAppendingString:region.identifier];
    NSString *cbId = [self.callbackIds valueForKey:requestKey];
    if (cbId) {
        [self toSucessCallback:cbId withJSON:@{@"error":@0,@"region":[self regionToDic:region],@"state":@(state)}];
        [self.callbackIds removeObjectForKey:requestKey];
    }else{
        cbId = [self.callbackIds objectForKey:region.identifier];
        if (cbId) {
            [self toSucessCallback:cbId withJSON:@{@"error":@0,@"region":[self regionToDic:region],@"state":@(state)} keepCallback:YES];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    NSString *cbId = [self.callbackIds valueForKey:[@"startRangingBeaconsInRegion:" stringByAppendingString:region.identifier]];
    if (cbId) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:beacons.count];
        for (CLBeacon *beacon in beacons) {
            if(beacon.accuracy>0&&beacon.rssi!=127)[result addObject:@{@"uuid":beacon.proximityUUID.UUIDString,@"major":beacon.major,@"minor":beacon.minor,@"rssi":@(beacon.rssi),@"accuracy":[NSString stringWithFormat:@"%.2f",beacon.accuracy]}];
        }
        [self toSucessCallback:cbId withJSON:@{@"error":@0,@"beacons":result} keepCallback:YES];
    }
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSString *cbId = [self.callbackIds objectForKey:[@"startRangingBeaconsInRegion:" stringByAppendingString:region.identifier]];
    if (cbId) {
        [self toSucessCallback:cbId withJSON:@{@"error":@(error.code),@"message":error.localizedDescription?:@""}];
    }
}
#pragma mark - **************** 本地通知

#define IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 9.0)
#define IOS8_10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0)
#define IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

- (void)registerLocalNotification:(PGMethod *)cmd {
    if (IOS10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"succeeded!");
            }
        }];
    } else if (IOS8_10){//iOS8-iOS10
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {//iOS8以下
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
}
- (void)sendLocalNotification:(PGMethod *)commands {
    NSDictionary* dic = [commands.arguments objectAtIndex:1];
    NSString *title = [dic objectForKey:@"title"];
    NSString *subtitle = [dic objectForKey:@"subtitle"];
    NSDictionary *info = [dic objectForKey:@"info"];
    if (IOS10) {
        [self addlocalNotificationForNewVersion:title sub:subtitle info:info];
    }else{
        [self addLocalNotificationForOldVersion:title sub:subtitle info:info];
    }
}
/**
 iOS 10以前版本添加本地通知
 */
- (void)addLocalNotificationForOldVersion:(NSString *)msg sub:(NSString *)subtitle info:(NSDictionary *)info {
    
    //定义本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置调用时间
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];//通知触发的时间，1s以后
    notification.repeatInterval = 1;//通知重复次数
    notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
    
    //设置通知属性
    notification.alertBody = msg;//[NSString stringWithFormat:@"Agent-%d",arc4random()%100]; //通知主体
    notification.applicationIconBadgeNumber += 1;//应用程序图标右上角显示的消息数
    notification.alertAction = subtitle; //待机界面的滑动动作提示
    notification.alertLaunchImage = @"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.soundName = UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
    //    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
    
    //设置用户信息
    notification.userInfo = info?:nil;//绑定到通知上的其他附加信息
    
    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

/**
 iOS 10以后的本地通知
 */
- (void)addlocalNotificationForNewVersion:(NSString *)msg sub:(NSString *)subtitle info:(NSDictionary *)info {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:msg arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:subtitle arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = info?:nil;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];
}

#pragma mark - UNUserNotificationCenterDelegate
// iOS 10收到前台通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", body);
        self.onStartByNotification = notification;
    } else {
        // 判断为本地通知
        self.onStartByNotification = notification;
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
// iOS 10收到后台通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
//    [[UIApplication sharedApplication].delegate application:nil didReceiveLocalNotification:response.notification];
    self.onStartByNotification = response.notification;
    completionHandler();
}
@end
