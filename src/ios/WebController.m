#import "WebController.h"
#import <WebKit/WebKit.h>

@interface WebController ()<WKNavigationDelegate,WKUIDelegate>

//@property (strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) CALayer *progresslayer;

@end

@implementation WebController

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needNav) {
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)back {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
//        self.navigationItem.leftItemsSupplementBackButton = YES;
//        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem;
//        return NO;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
//        return YES;
    }
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%@", change);
        self.progresslayer.opacity = 1;
        self.progresslayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[NSKeyValueChangeNewKey] floatValue], 3);
        if ([change[NSKeyValueChangeNewKey] floatValue] == 1) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progresslayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progresslayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            self.navigationItem.title = self.webView.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (CGFloat)getWindowSafeAreaTop {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;//44
    }
    return 0.0;
}

- (UIBarButtonItem *)barBtnWithImage:(UIImage *)image action:(SEL)action {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return barBtnItem;
}

- (void)addBackBtnWithImage:(UIImage *)image action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(15, [self getWindowSafeAreaTop] + 18, 44, 44);
    [self.view addSubview:btn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (!IsStringWithAnyText(_projectUrl)) {
//        return;
//    }

    // 应用于 ajax 请求的 cookie 设置
    WKUserContentController *userContentController = WKUserContentController.new;
//    NSString *cookieSource = [NSString stringWithFormat:@"document.cookie = 'token=%@';", YFINSTANCE_USER.token];
//    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//    [userContentController addUserScript:cookieScript];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_projectUrl]];
    
    // 应用于 request 的 cookie 设置
    NSDictionary *headFields = request.allHTTPHeaderFields;
//    NSString *cookie = headFields[@"token"];
//    if (cookie == nil) {
//        [request addValue:[NSString stringWithFormat:@"token=%@", YFINSTANCE_USER.token] forHTTPHeaderField:@"Cookie"];
//    }
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.webView loadRequest:request];
    
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavBarHeight)];
//    webView.scalesPageToFit = YES;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];

    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    
    [self.view addSubview:_webView];
//    self.webView = webView;
    
    //进度条
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [progress.layer addSublayer:layer];
    self.progresslayer = layer;

    if (self.needNav) {
        self.navigationItem.leftBarButtonItem = [self barBtnWithImage:[UIImage imageNamed:@"icon_back"] action:@selector(back)];
    }else {
        [self addBackBtnWithImage:[UIImage imageNamed:@"icon_return"] action:@selector(back)];
    }
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_projectUrl]];
//    [request addValue:YFINSTANCE_USER.token forHTTPHeaderField:@"token"];
//    [self.webView loadRequest:request];
}


#pragma mark - webview delegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// 类似 UIWebView的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL * url = navigationAction.request.URL;
//    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURLRequest * request =   navigationAction.request;
//    NSMutableURLRequest * mutRequest = [request mutableCopy];
//    NSString * urlString = request.URL.absoluteString;
//    NSLog(@"====== >>>>url----- %@ request %@",urlString,[request allHTTPHeaderFields]);
//    NSDictionary * dictHader = request.allHTTPHeaderFields;
//    if (![dictHader objectForKey:@"appNavigation"]) {
//        [mutRequest addValue:@"true" forHTTPHeaderField:@"appNavigation"];
//        [webView loadRequest:mutRequest];
//        decisionHandler(WKNavigationActionPolicyCancel);
//    }
    NSLog(@"%@",url.scheme);
//    if([[url scheme] isEqualToString:@"gototaobao"]) {//主页面加载内容
//
//        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
//    }else{
    
    decisionHandler(WKNavigationActionPolicyAllow);
//    }
}

- (NSMutableDictionary*)getURLParametersWithString:(NSString *)string {
    
    NSRange range = [string rangeOfString:@"?"];
    
    if(range.location==NSNotFound) {
        
        return nil;
        
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *parametersString = [string substringFromIndex:range.location+1];
    
    if([parametersString containsString:@"&"]) {
        
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for(NSString *keyValuePair in urlComponents) {
            
            //生成key/value
            
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            
            NSString*value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            //key不能为nil
            
            if(key==nil|| value ==nil) {
                
                continue;
                
            }
            
            id existValue = [params valueForKey:key];
            
            if(existValue !=nil) {
                
                //已存在的值，生成数组。
                
                if([existValue isKindOfClass:[NSArray class]]) {
                    
                    //已存在的值生成数组
                    
                    NSMutableArray*items = [NSMutableArray arrayWithArray:existValue];
                    
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                    
                }else{
                    
                    //非数组
                    
                    [params setValue:@[existValue,value]forKey:key];
                    
                }
                
            }else{
                
                //设置值
                
                [params setValue:value forKey:key];
                
            }
            
        }
        
    }else{
        
        //单个参数生成key/value
        
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        if(pairComponents.count==1) {
            
            return nil;
            
        }
        
        //分隔值
        
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
    
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        //key不能为nil
        
        if(key ==nil|| value ==nil) {
            
            return nil;
            
        }
        
        //设置值
        
        [params setValue:value forKey:key];
        
    }
    
    return params;
    
}

//- (void)onRightBtn {
//    YFWebViewController *webVC = [[YFWebViewController alloc] init];
//    webVC.projectUrl = self.secret_url;
//    [self.navigationController pushViewController:webVC animated:YES];
//}

@end
