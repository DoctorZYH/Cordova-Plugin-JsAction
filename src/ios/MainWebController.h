#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainWebController : CDVViewController
@property (nonatomic, weak) id <CDVCommandDelegate> command;
@property (nonatomic, copy) NSString *actId;
@end

@interface MainWebCommandDelegate : CDVCommandDelegateImpl
@end

@interface MainWebCommandQueue : CDVCommandQueue
@end

NS_ASSUME_NONNULL_END
