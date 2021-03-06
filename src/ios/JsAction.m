/********* JsAction.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "MainViewController.h"
#import "GlobalManager.h"
#import "MqttManager.h"
#import "DevicePermission.h"
#import "LocationManager.h"
#import "WebController.h"

@interface JsAction : CDVPlugin {
  // Member variables go here.
}
@property (nonatomic, strong) LocationManager *locationManager;

- (void)connectMQ:(CDVInvokedUrlCommand*)command;
- (void)MQStatus:(CDVInvokedUrlCommand*)command;
- (void)open:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)action:(CDVInvokedUrlCommand*)command;
- (void)sendMessage:(CDVInvokedUrlCommand*)command;
- (void)gesture:(CDVInvokedUrlCommand*)command;

@end

@implementation JsAction

- (void)dealloc {
    NSLog(@"");
}

- (void)connectMQ:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];

    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [[MqttManager defaultManager] startMqttServiceWithConfig:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)MQStatus:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:[MqttManager defaultManager].MQTTStatus];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)open:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];

    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSString *page = dict[@"url"];
    NSString *actId = dict[@"actId"];
    NSInteger isFullScreen = [dict[@"isFullScreen"] integerValue];

    if (actId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // b-web 不带导航栏
    // n-web 带导航栏
    if ([actId isEqualToString:@"b-web"] || [actId isEqualToString:@"n-web"]) {
        WebController *webVC = [[WebController alloc] init];
        webVC.projectUrl = dict[@"url"];
        webVC.needNav = [actId isEqualToString:@"n-web"];
        [(UINavigationController *)window.rootViewController pushViewController:webVC animated:YES];
//        [self.navigationController pushViewController:webVC animated:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }else {
        [[GlobalManager defaultManager].actIdArray addObject:actId];
        
        MainViewController *viewController = [[MainViewController alloc] init];
        viewController.actId = actId;
        viewController.startPage = page;
        if (isFullScreen == 2) {
            viewController.backgroundColor = [UIColor blackColor];
        }
        viewController.command = self.commandDelegate;
        [(UINavigationController *)window.rootViewController pushViewController:viewController animated:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSDictionary *onEventDict = @{@"type":@"'open'", @"data":[GlobalManager defaultManager].actIdArray};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onEvent" object:onEventDict];
    }
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    NSString *actId = dict[@"actId"];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UINavigationController *rootVC = (UINavigationController *)window.rootViewController;
    MainViewController *topVC = rootVC.viewControllers.lastObject;
    if ([actId isEqualToString:@"all"]) {
        [rootVC popToRootViewControllerAnimated:YES];
    }else {
        if ([topVC.actId isEqualToString:actId]) {
            [rootVC popViewControllerAnimated:YES];
        }else {
            NSMutableArray *naviVCsArr = [[NSMutableArray alloc]initWithArray:rootVC.viewControllers];
            for (MainViewController *vc in naviVCsArr) {
                if ([vc.actId isEqualToString:actId]) {
                    [naviVCsArr removeObject:vc];
                    break;
                }
            }
            rootVC.viewControllers = naviVCsArr;
        }
    }
}

- (void)gesture:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gesture" object:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)action:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSInteger action = [dict[@"action"] integerValue];
    // 页面间通信
    if (action == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"action_1" object:dict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else if (action == 101) {
        [DevicePermission checkCameraPermission:^(BOOL granted) {
            
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }else if (action == 102) {
        [DevicePermission checkMicrophonePermissionWaitForRequestResult:NO complection:^(BOOL granted) {
            
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }else if (action == 103) {
        
        self.locationManager = [[LocationManager alloc] init];
        [self.locationManager checkLocationPermission:^(BOOL granted) {
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }else if (action == 104) {
        [DevicePermission checkPhotoAlbumPermission:^(BOOL granted) {
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }
}

- (void)sendMessage:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dict = command.arguments[0];

    if ([dict isKindOfClass:[NSDictionary class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mqtt_action" object:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
