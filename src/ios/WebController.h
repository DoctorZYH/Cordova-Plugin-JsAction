#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebController : UIViewController

@property (nonatomic, copy  ) NSString *projectUrl;
@property (nonatomic, assign) BOOL isFromLoginVC;
@property (nonatomic, assign) BOOL needNav;

@property (nonatomic, copy  ) NSString *secret_url;
@end

NS_ASSUME_NONNULL_END
