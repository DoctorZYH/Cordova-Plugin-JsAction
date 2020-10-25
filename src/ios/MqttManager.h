#import <Foundation/Foundation.h>

#import "MQTTClient.h"

//#import "LCSocketConfig.h"
/* socket链接状态 */
typedef enum {
    LCMQTTStatusDisconnect = 0,
    LCMQTTStatusConnecting,
    LCMQTTStatusConnected,
} LCMQTTStatus;


typedef void (^MQTTLCConnectHandler)(NSError *error);
typedef void (^MQTTLCDisconnectHandler)(NSError *error);
typedef void (^MQTTLCSubscribeHandler)(NSError *error, NSArray<NSNumber *> *gQoss);
typedef void (^MQTTLCUnsubscribeHandler)(NSError *error);
//typedef void (^MQTTLCPublishHandler)(NSError *error);


@interface MqttManager : NSObject
@property (nonatomic, assign, readonly) LCMQTTStatus  MQTTStatus;
//@property (nonatomic, strong) LCSocketConfig    *socketConfig;

+ (MqttManager *)defaultManager;
- (void)releaseManager;

- (void)startMqttServiceWithConfig:(NSDictionary *)config;

- (void)subscribeTopic:(NSString *)topic subscribeHandler:(MQTTLCSubscribeHandler)subscribeHandler;
- (void)unsubscribeTopic:(NSString *)topic unsubscribeHandler:(MQTTLCUnsubscribeHandler)unsubscribeHandler;
- (BOOL)publishData:(NSData *)data onTopic:(NSString*)topic retain:(BOOL)retainFlag;

//- (BOOL)receiveMsgWithSession:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid;

- (void)reconnection;
- (void)close;

@end
