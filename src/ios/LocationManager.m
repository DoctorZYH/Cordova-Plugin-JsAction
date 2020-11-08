//
//  LocationManager.m
//  Hello
//
//  Created by DoctorZhang on 2020/11/7.
//

#import "LocationManager.h"
#import "DevicePermission.h"

typedef void(^LCLocationAuthStatusHandler)(BOOL granted);
@interface LocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, copy  ) LCLocationAuthStatusHandler       locationAuthStatusHandler;

@end

@implementation LocationManager

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

// 获取定位权限
- (void)checkLocationPermission:(void(^)(BOOL granted))hander
{

    // 1.定位服务是否开启
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    if (enabled) {
        // 2.app授权状态检测
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
            {
                _locationAuthStatusHandler = hander;
                [self requestWhenInUseAuthorization];
//                hander(YES);
            }
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied: //用户拒绝
            {
                
                if (hander) {
                    hander(NO);
                }
            }
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            {
                if (hander) {
                    hander(YES);
                }
            }
                break;
            default:
                break;
        }
    }else {
        [DevicePermission showLocationServiceFailAlert];
        if (hander) {
            hander(NO);
        }

    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%d",status);
    
    switch (status) {
        case kCLAuthorizationStatusDenied:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.locationAuthStatusHandler) {
                    self.locationAuthStatusHandler(NO);
                }
            });
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.locationAuthStatusHandler) {
                    self.locationAuthStatusHandler(YES);
                }
            });
        }
            break;
        default:
            break;
    }
}
@end
