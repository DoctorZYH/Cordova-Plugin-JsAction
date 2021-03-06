/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  Hello
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "MainViewController.h"
#import "GlobalManager.h"

@interface MainViewController ()<UIGestureRecognizerDelegate>

@end


@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GlobalManager defaultManager].actId = self.actId;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqtt_action:) name:@"mqtt_action" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEvent:) name:@"onEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_1:) name:@"action_1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gestureChange:) name:@"gesture" object:nil];

    // app启动或者app从后台进入前台都会调用这个方法
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.rootViewController.childViewControllers.count <= 1) {
        return NO;
    }
    [self action_3];
    return YES;
}

- (void)gestureChange:(NSNotification *)notification
{
    if ([GlobalManager defaultManager].actId == self.actId) {
        BOOL type = [notification.object[@"type"] boolValue];
        self.navigationController.interactivePopGestureRecognizer.enabled = type;
    }
}

- (void)applicationBecomeActive
{
    NSLog(@"applicationBecomeActive");
    if ([GlobalManager defaultManager].actId == self.actId) {
        NSDictionary *onEventDict = @{@"type":@(1), @"data":@{}};

        [self callbackJSWith:@"JsAction.onEventDocument" params:onEventDict];
    }
    
}

- (void)applicationEnterBackground
{
    NSLog(@"applicationEnterBackground");
    if ([GlobalManager defaultManager].actId == self.actId) {
        NSDictionary *onEventDict = @{@"type":@(2), @"data":@{}};

        [self callbackJSWith:@"JsAction.onEventDocument" params:onEventDict];
    }
}

- (void)mqtt_action:(NSNotification *)notification
{
    NSLog(@"mqtt_action");
    
    if ([GlobalManager defaultManager].actId == self.actId) {
        NSDictionary *onMqttMessageDict = @{@"type":notification.object[@"type"], @"data":[self jsonStringEncodedWith:notification.object[@"data"]]};

        [self callbackJSWith:@"JsAction.onMqttMessage" params:onMqttMessageDict];
    }
}

- (void)onEvent:(NSNotification *)notification
{
    NSLog(@"onEvent");
    
    if ([GlobalManager defaultManager].actId == self.actId) {
        NSDictionary *onEventDict = @{@"type":notification.object[@"type"], @"data":[self arrayToJsonString:notification.object[@"data"]]};

        [self callbackJSWith:@"JsAction.onEvent" params:onEventDict];
    }
}

// 页面间通信
- (void)action_1:(NSNotification *)notification
{
    NSLog(@"action_1");
//    NSDictionary *onEventDict = @{@"type":@"'close'", @"data":array};

    NSDictionary *onEventDict = @{@"type":[NSString stringWithFormat:@"'%@'", notification.object[@"event"]], @"data":[self jsonStringEncodedWith:notification.object[@"params"]]};

    [self callbackJSWith:@"JsAction.onEvent" params:onEventDict];

}

// 手势返回通知js
- (void)action_3
{
    NSDictionary *onEventDict = @{@"type":@(3), @"data":@{}};
    [self callbackJSWith:@"JsAction.onEventDocument" params:onEventDict];
}

- (void)callbackJSWith:(NSString *)callback_event params:(NSDictionary *)params
{
    if (!params) {
        params = @{};
    }
        
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:params];
//    NSString *paramStr = [self jsonStringEncodedWith:dictM[@"data"]];
    NSString *jsStr = [NSString stringWithFormat:@"%@(%@,%@)", callback_event, dictM[@"type"], dictM[@"data"]];
    NSLog(@"%@", jsStr);
    
    [self.commandDelegate evalJs:jsStr];
}

- (NSString *)jsonStringEncodedWith:(NSDictionary *)params
{
    if ([NSJSONSerialization isValidJSONObject:params]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return @"";
}

- (NSString *)arrayToJsonString:(NSArray *)array{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

- (void)dealloc
{
    NSMutableArray * array = [GlobalManager defaultManager].actIdArray;
    for(NSString *str in array) {
        NSLog(@"%@",str);
        if([str isEqualToString:self.actId]) {
            [array removeObject:str];
            break;
        }
    }
    [GlobalManager defaultManager].actIdArray = array;
    
    NSDictionary *onEventDict = @{@"type":@"'close'", @"data":array};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onEvent" object:onEventDict];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"---------------------------------------------------------------");
}


@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
