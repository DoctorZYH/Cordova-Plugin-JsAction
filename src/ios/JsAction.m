/********* JsAction.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "MainWebController.h"
#import "GlobalManager.h"
#import "MqttManager.h"
@interface JsAction : CDVPlugin {
  // Member variables go here.
}

- (void)connectMQ:(CDVInvokedUrlCommand*)command;
- (void)open:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)action:(CDVInvokedUrlCommand*)command;
- (void)sendMessage:(CDVInvokedUrlCommand*)command;

@end

@implementation JsAction

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
    NSArray *pluginList = dict[@"pluginList"];
    NSString *actId = dict[@"actId"];

    [[GlobalManager defaultManager].actIdArray addObject:actId];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UINavigationController *rootNavController = (UINavigationController *)window.rootViewController;

    MainWebController *viewController = [[MainWebController alloc] init];
    viewController.actId = actId;
    viewController.startPage = page;
    viewController.command = self.commandDelegate;
    [(UINavigationController *)window.rootViewController pushViewController:viewController animated:YES];

//    [rootNavController pushViewController:viewController animated:YES];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

//    NSDictionary *onEventDict = @{@"type":@"'close'", @"data":[NSString stringWithFormat:@"'%@'", [array componentsJoinedByString:@","]]};

    NSDictionary *onEventDict = @{@"type":@"'open'", @"data":[GlobalManager defaultManager].actIdArray};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onEvent" object:onEventDict];
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
    MainWebController *topVC = rootVC.viewControllers.lastObject;
    if ([topVC.actId isEqualToString:actId]) {
        [rootVC popViewControllerAnimated:YES];
    }else {
        NSMutableArray *naviVCsArr = [[NSMutableArray alloc]initWithArray:rootVC.viewControllers];
        for (MainWebController *vc in naviVCsArr) {
            if ([vc.actId isEqualToString:actId]) {
                [naviVCsArr removeObject:vc];
                break;
            }
        }
        rootVC.viewControllers = naviVCsArr;
    }
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
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

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
