#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : CLLocationManager
- (void)checkLocationPermission:(void(^)(BOOL granted))hander;
@end

NS_ASSUME_NONNULL_END
