#import "MqttManager.h"
#import "Reachability.h"

@interface MqttManager ()<MQTTSessionDelegate>
@property (nonatomic, strong) MQTTSession           *session;
//@property (nonatomic, assign) BOOL                  didRegisterMQTTSection;
@property (nonatomic, assign) BOOL                  isjustConnected;
@property (nonatomic, strong) Reachability          *reachability;
@property (nonatomic, assign) NSInteger             oldNetState;

@end

@implementation MqttManager

static MqttManager *_mqttManager = nil;

+ (MqttManager *)defaultManager {
    
    if (_mqttManager == nil) {
        
        _mqttManager = [[MqttManager alloc] init];
        _mqttManager.MQTTStatus = LCMQTTStatusConnecting;
        [_mqttManager observeNetworkStatus];
        _mqttManager.oldNetState = -1;
//        _mqttManager.socketConfig = [[LCSocketConfig alloc] init];
    }
    return _mqttManager;
}

- (void)releaseManager {
    
    if (_mqttManager) {
        [_session disconnect];
//        [_session close];
        _session = nil;
        
        _mqttManager = nil;
    }
}

- (void)observeNetworkStatus {
    [MqttManager defaultManager].oldNetState = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [MqttManager defaultManager].reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[MqttManager defaultManager].reachability startNotifier];
}

#pragma mark - Private Methods
- (void)setMQTTStatus:(LCMQTTStatus)MQTTStatus {
    if (MQTTStatus != _MQTTStatus) {
        _MQTTStatus = MQTTStatus;
    }
}

/* 订阅主题 */
- (void)subscribeTopic:(NSString *)topic subscribeHandler:(MQTTLCSubscribeHandler)subscribeHandler {
    
    [_session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
        if (subscribeHandler) {
            subscribeHandler(error, gQoss);
        }
    }];
}

- (void)subscribeToTopics:(NSDictionary *)topics subscribeHandler:(MQTTLCSubscribeHandler)subscribeHandler {
    
    [_session subscribeToTopics:topics subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
        if (subscribeHandler) {
            subscribeHandler(error, gQoss);
        }
    }];
}

/** 取消订阅主题 */
- (void)unsubscribeTopic:(NSString *)topic unsubscribeHandler:(MQTTLCUnsubscribeHandler)unsubscribeHandler {
    [_session unsubscribeTopic:topic unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"=*=*=*=*=*= Unsubscribe topic fail =*=*=*=*=*=");
        } else {
            NSLog(@"=*=*=*=*=*= Unsubscribe topic success=*=*=*=*=*=");
        }
        if (unsubscribeHandler) {
            unsubscribeHandler(error);
        }
    }];
}

- (BOOL)publishData:(NSData*)data onTopic:(NSString*)topic retain:(BOOL)retainFlag {
    //    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    //                NSDictionary *dict = @{@"test":@"hahaha"};
    //                [session publishJson:dict onTopic:@"example"];
    return [_session publishAndWaitData:data onTopic:topic retain:retainFlag qos:MQTTQosLevelExactlyOnce timeout:30];
//    return [_session publishAndWaitData:data onTopic:topic retain:retainFlag qos:MQTTQosLevelExactlyOnce];
}

//- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
//
//    if (qos > MQTTQosLevelAtMostOnce) {
//        // 需要回执
////        _session
//    }
//    NSData *subData = [data subdataWithRange:NSMakeRange(0, 2)];
//    NSInteger dataType = [self dataToInt:subData];
//    if (dataType == 0) {
//        NSData *contentData = [data subdataWithRange:NSMakeRange(2, data.length - 2)];
//
//        NSString *receiveStr = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
//
//        NSData *transitData = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:transitData options:NSJSONReadingMutableLeaves error:nil];
//
//        NSLog(@"%@",jsonDict);
//        [self receivedSocketJson:jsonDict];
//    }
//}


- (BOOL)newMessageWithFeedback:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {

    NSArray *array = [_session.persistence allFlowsforClientId:@"" incomingFlag:YES];
    NSLog(@"%@",array);
    if (qos > MQTTQosLevelAtMostOnce) {
        // 需要回执
        //        _session
    }
//    NSData *subData = [data subdataWithRange:NSMakeRange(0, 2)];
//    NSInteger dataType = [self dataToInt:subData];
//    NSData *contentData = [data subdataWithRange:NSMakeRange(2, data.length - 2)];
    
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *transitData = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:transitData options:NSJSONReadingMutableLeaves error:nil];
//    NSDictionary *jsonDict = [self dictionaryWithJsonString:receiveStr];
    NSLog(@"%@",jsonDict);
    [self receivedSocketJson:jsonDict];
    return YES;
}

- (int)dataToInt:(NSData *)data {
    Byte byte[4] = {};
    [data getBytes:byte length:4];
    int value;
    value = (int) (((byte[0] & 0xFF)<<24)
                   | ((byte[1] & 0xFF)<<16)
                   | ((byte[2] & 0xFF)<<8)
                   | (byte[3] & 0xFF));
    
    return value;
}

#pragma mark - session delegate
- (void)connected:(MQTTSession *)session {
    NSLog(@"connected --  %ld",session.status);
    self.MQTTStatus = LCMQTTStatusConnected;

    if (_isjustConnected) {
        NSDictionary *param = @{@"type":@(102), @"data":@{}};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mqtt_action" object:param];
    }
    if (!_isjustConnected) {
        _isjustConnected = YES;
    }
//    if (!LCINSTANCE_USER.didSubscribe) {
//        [LCINSTANCE_SYNCMANAGER requestSubscribe];
//    }
}

- (void)connectionClosed:(MQTTSession *)session {

    NSLog(@"connectionClosed -- %ld",session.status);
    if (session.status == MQTTSessionStatusClosed) {
        self.MQTTStatus = LCMQTTStatusDisconnect;
        //        self.socketStatus = LCSocketStatusDisconnect;
        //        LCINSTANCE_SYNCMANAGER.syncState = LCSyncIndexState_Fail;
        // 通知js断开链接
        NSDictionary *param = @{@"type":@(100), @"data":@{}};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mqtt_action" object:param];
    }
}

- (void)reconnection {
    if (_session.status != MQTTSessionStatusConnected) {
        self.MQTTStatus = LCMQTTStatusConnecting;
        [_session connect];
    }
}

- (void)close {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    __weak typeof(self) weakSelf = self;
    if (_session.status != MQTTSessionStatusConnected) {
        return;
    }
    [_session closeWithDisconnectHandler:^(NSError *error) {
        if (!error) {
            weakSelf.MQTTStatus = LCMQTTStatusDisconnect;
            //            LCINSTANCE_SYNCMANAGER.syncState = LCSyncIndexState_Fail;
        }
    }];
}

//- (void)changeIsjustConnectedToNo {
//    _isjustConnected = NO;
//}

- (void)startMqttServiceWithConfig:(NSDictionary *)config {
    NSLog(@"startMqttServiceWithConfig: %@", config);
    NSLog(@"startMqttServiceWithConfig: %@", config[@"mqtt_port_tcp"]);
    if ([config[@"is_connect"] integerValue] == 1) {
//        if (!_didRegisterMQTTSection) {
        if (config[@"mqtt_host"] && [config[@"mqtt_port_tcp"] intValue] > 0) {
            MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
            transport.host = config[@"mqtt_host"];
            transport.port = [config[@"mqtt_port_tcp"] intValue];
            _session = [[MQTTSession alloc] init];
            _session.persistence.persistent = YES;
            _session.transport = transport;
            _session.delegate = self;
            _session.cleanSessionFlag = NO;
            _session.clientId = config[@"client_id"];
            _session.userName = [NSString stringWithFormat:@"%@",config[@"username"]];
            _session.password = config[@"password"];
            _session.keepAliveInterval = 60;
            
//            _didRegisterMQTTSection = YES;
//            }
        }
        // 如果已经连上或正在连接中，return
        if (_session.status == MQTTSessionStatusConnected || _session.status == MQTTSessionStatusConnecting) {
            return;
        }
        _MQTTStatus = LCMQTTStatusConnecting;
        
        // 会话链接并设置超时时间
        [_session connectAndWaitTimeout:1];
    }else if ([config[@"is_connect"] integerValue] == 2) {
        [self reconnection];
    }else if ([config[@"is_connect"] integerValue] == 0) {
        [self close];
    }
    
}

#pragma mark - 接收socket消息
- (void)receivedSocketJson:(NSDictionary *)json {
    
    NSLog(@"###socket: receivedSocketJson: %@", json);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mqtt_action" object:json];
}


-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if([MqttManager defaultManager].oldNetState == netStatus) {
        return;
    }
    [MqttManager defaultManager].oldNetState = netStatus;
    
    if([reach isReachable])
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Notification Says Reachable(%@)", reach.currentReachabilityString];
        NSLog(@"%@", temp);
        if (_MQTTStatus == LCMQTTStatusDisconnect) {
            [self reconnection];
        }
    }
    else
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Notification Says Unreachable(%@)", reach.currentReachabilityString];
        NSLog(@"%@", temp);
    }
    
}


@end
