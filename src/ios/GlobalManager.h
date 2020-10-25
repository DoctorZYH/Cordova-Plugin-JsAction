#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalManager : NSObject
@property (nonatomic, copy) NSString *actId;
@property (nonatomic, strong) NSMutableArray *actIdArray;

+ (GlobalManager *)defaultManager;

@end

NS_ASSUME_NONNULL_END
