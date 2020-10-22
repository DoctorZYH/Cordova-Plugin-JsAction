#import "GlobalManager.h"

@implementation GlobalManager
static GlobalManager *_globalManager = nil;

+ (GlobalManager *)defaultManager {
    
    if (_globalManager == nil) {
        
        _globalManager = [[GlobalManager alloc] init];
        _globalManager.actId = @"main";
    }
    return _globalManager;
}

@end
