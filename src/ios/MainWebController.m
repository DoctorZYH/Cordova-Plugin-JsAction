//
//  MainWebController.m
//  TestDemo
//
//  Created by DoctorZhang on 2020/10/11.
//

#import "MainWebController.h"

@interface MainWebController ()<UIGestureRecognizerDelegate>

@end

@implementation MainWebController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqtt_action:) name:@"mqtt_action" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)mqtt_action:(NSNotification *)notification
{
    NSLog(@"mqtt_action");
    [self callbackJSWith:@"JsAction.onMqttMessage" params:notification.object];
}

- (void)callbackJSWith:(NSString *)callback_event params:(NSDictionary *)params
{
    if (!params) {
        params = @{};
    }
        
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:params];
    NSString *paramStr = [self jsonStringEncodedWith:dictM];
    NSString *jsStr = [NSString stringWithFormat:@"%@(%@)", callback_event, paramStr];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation MainWebCommandDelegate

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

@implementation MainWebCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}


@end


