/********* JsAction.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "MainWebController.h"

@interface JsAction : CDVPlugin {
  // Member variables go here.
}

- (void)open:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)action:(CDVInvokedUrlCommand*)command;
- (void)onEvent:(CDVInvokedUrlCommand*)command;
- (void)sendMessage:(CDVInvokedUrlCommand*)command;

@end

@implementation JsAction

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
//    NSString *callback_event = dict[@"callback_event"];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainWebController *viewController = [[MainWebController alloc] init];
    viewController.startPage = page;
    viewController.command = self.commandDelegate;
//    viewController.js_callback_event = callback_event;
    [(UINavigationController *)window.rootViewController pushViewController:viewController animated:YES];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [(UINavigationController *)window.rootViewController popViewControllerAnimated:YES];
}

- (void)action:(CDVInvokedUrlCommand*)command
{

}

- (void)onEvent:(CDVInvokedUrlCommand*)command
{

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
