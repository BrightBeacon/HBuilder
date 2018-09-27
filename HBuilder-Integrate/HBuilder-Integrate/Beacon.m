//
//  wxBeacon.m
//  HBuilder
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 DCloud. All rights reserved.
//

#import "Beacon.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface Beacon ()<CLLocationManagerDelegate,CBCentralManagerDelegate>

@property (nonatomic,strong) CLLocationManager      *locationManager;
@property (nonatomic,strong) NSMutableDictionary    *iBeacons;
@property (nonatomic,strong) NSString *onBeaconUpdateCBID;
@property (nonatomic,strong) NSString *onBeaconServiceChangeCBID;
@property (nonatomic,strong) CBCentralManager       *centralManager;

@end

@implementation Beacon

- (void)dealloc {
    [super dealloc];
    [self startBeaconDiscovery:nil];
    self.locationManager = nil;
    self.iBeacons = nil;
    self.centralManager = nil;
}

- (void)startBeaconDiscovery:(PGMethod *)command {
    NSString *cbid = [command.arguments objectAtIndex:0];
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    self.iBeacons = [NSMutableDictionary dictionary];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    NSArray *uuids = [command.arguments objectAtIndex:1][@"uuids"];
    for (NSString *uuidStr in uuids) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        [self.locationManager startRangingBeaconsInRegion:[[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuidStr]];
    }
    [self toSucessCallback:cbid withJSON:@{@"errMsg":@"ok"}];
}
- (void)stopBeaconDiscovery:(PGMethod *)command {
    NSSet *regions = [self.locationManager rangedRegions];
    for (CLBeaconRegion *region in regions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    if (command) {
        NSString *cbid = [command.arguments objectAtIndex:0];
        [self toSucessCallback:cbid withJSON:@{@"errMsg":@"ok"}];
    }
}
- (NSData *)getBeacons:(PGMethod *)command {
    NSString *cbid = [command.arguments objectAtIndex:0];
    NSDictionary *dic = @{@"beacons":[self beaconJson],@"errMsg":@"ok"};
    [self toSucessCallback:cbid withJSON:dic];
    return [self resultWithJSON:dic];
}
- (void)onBeaconUpdate:(PGMethod *)command {
    self.onBeaconUpdateCBID = [command.arguments objectAtIndex:0];
}
- (void)onBeaconServiceChange:(PGMethod *)command {
    NSString *cbid = [command.arguments objectAtIndex:0];
    self.onBeaconServiceChangeCBID = cbid;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (NSArray *)beaconJson {
    NSMutableArray *result = [NSMutableArray array];
    for (NSArray *ibeacons in self.iBeacons.allValues) {
        for (CLBeacon *beacon in ibeacons) {
            [result addObject:@{@"uuid":beacon.proximityUUID.UUIDString,@"major":beacon.major.stringValue,@"minor":beacon.minor.stringValue,@"rssi":@(beacon.rssi),@"accuracy":@(beacon.accuracy),@"proximity":@(beacon.proximity)}];
        }
    }
    return result;
}
#pragma mark - **************** delegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    [self.iBeacons setObject:beacons forKey:region.proximityUUID.UUIDString];
    if (self.onBeaconUpdateCBID) {
        [self toSucessCallback:self.onBeaconUpdateCBID withJSON:@{@"beacons":[self beaconJson]} keepCallback:YES];
    }
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL discovering = !!self.locationManager.rangedRegions.count;
    BOOL available = [CLLocationManager isRangingAvailable] && (central.state == 5);
    NSString *errMsg = @"ok";
    if (!available) {
        errMsg = @"unsupport";
    }
    if (central.state != 5) {
        errMsg = @"bluetooth service unavailable";
    }else if (([CLLocationManager locationServicesEnabled]) && ([CLLocationManager authorizationStatus] >= 3)){
        if (self.locationManager.rangedRegions.count) {
            errMsg = @"already start";
        }
    }else {
        errMsg = @"location service unavailable";
    }
    [self toSucessCallback:self.onBeaconServiceChangeCBID withJSON:@{@"available":@(available),@"discovering":@(discovering),@"errMsg":errMsg} keepCallback:YES];
}
@end
