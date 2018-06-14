//
//  CYLocationManager.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/10/20.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYLocationManager.h"

@interface CYLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) void (^successBlock)(NSArray<CLLocation *> *);
@property (nonatomic, copy) void (^geocodeBlock)(NSArray *geocodeArray);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

@end

@implementation CYLocationManager

+ (instancetype)manager {
    static CYLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.locationManager = [[CLLocationManager alloc] init];
        if (@available(iOS 8, *)) {
            [manager.locationManager requestWhenInUseAuthorization];
        }
    });
    return manager;
}

- (void)startLocation {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:nil];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    [self startLocationWithSuccessBlock:successBlock failureBlock:failureBlock geocoderBlock:nil];
}

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:geocoderBlock];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self.locationManager startUpdatingLocation];
    _successBlock = successBlock;
    _geocodeBlock = geocoderBlock;
    _failureBlock = failureBlock;
}

#pragma mark - CLLocationManagerDelegate

/// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    
    if (_successBlock) {
        _successBlock(locations);
    }
    
    if (_geocodeBlock && locations.count) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[locations firstObject] completionHandler:^(NSArray *array, NSError *error) {
            self.geocodeBlock(array);
        }];
    }
}

/// 定位失败回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败, 错误: %@",error);
    switch([error code]) {
        case kCLErrorDenied: { // 用户禁止了定位权限
            
        } break;
        default: break;
    }
    if (_failureBlock) {
        _failureBlock(error);
    }
}

@end
