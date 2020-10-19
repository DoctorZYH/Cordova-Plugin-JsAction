//
//  MainWebController.h
//  TestDemo
//
//  Created by DoctorZhang on 2020/10/11.
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainWebController : CDVViewController
@property (nonatomic, weak) id <CDVCommandDelegate> command;

@end

@interface MainWebCommandDelegate : CDVCommandDelegateImpl
@end

@interface MainWebCommandQueue : CDVCommandQueue
@end

NS_ASSUME_NONNULL_END
