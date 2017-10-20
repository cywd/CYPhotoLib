//
//  CYLocationManager.h
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/10/20.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CYLocationManager : NSObject

+ (instancetype)manager;

- (void)startLocation;
- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location, CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;
- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location,CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

@end
