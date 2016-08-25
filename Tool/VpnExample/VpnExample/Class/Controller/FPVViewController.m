//
//  FPVViewController.m
//  Free PPTP VPN
//
//  Created by iwevon on 16/5/12.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "FPVViewController.h"
#import "YYFPSLabel.h"
#import "FPVNetWork.h"
#import "UIView+Toast.h"
#import <NetworkExtension/NetworkExtension.h>

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f                                                                                 alpha:(a)]

#define ScreenSize      ([UIScreen mainScreen].bounds.size)
#define ScreenWidth     ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight    ([UIScreen mainScreen].bounds.size.height)

#define kDefaultColor   ([UIColor grayColor])
#define kLoadColor      ([UIColor redColor])
#define kSkyBlueColor   RGBACOLOR(135, 206, 255, 1.0)

#define kDefaultFont   ([UIFont systemFontOfSize:16.0])
#define kLoadFont      ([UIFont systemFontOfSize:12.0])

#define kDefaultIPStr       @"IP: "
#define kDefaultAccountStr  @"Account: "
#define kDefaultPasswordStr @"Password: "

CGFloat const kDefaultDelay = 60;
CGFloat const kAnimateDuration = 0.5;

@interface FPVViewController () <UIScrollViewDelegate, UIWebViewDelegate> {
    
    CADisplayLink *_link;
    NSTimeInterval _curRequestTime; //当前请求数据的时间
}
@property (strong, nonatomic) UIButton *vpnButton;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) YYFPSLabel *fpsLabel;

@property (strong, nonatomic) UIView *resultView;
@property (strong, nonatomic) UIButton *ipButton;
@property (strong, nonatomic) UIButton *accountButton;
@property (strong, nonatomic) UIButton *passwordButton;

@property (strong, nonatomic) UIActivityIndicatorView *activity;
@end

@implementation FPVViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        webView.scrollView.delegate = self;
        webView.scrollView.showsHorizontalScrollIndicator = NO;
        [webView loadHTMLString:[self htmlForJPGImage:[UIImage imageNamed:@"bg"]] baseURL:nil];
        [self.view addSubview:webView];
        webView;
    });
    
    self.fpsLabel =({
        YYFPSLabel *fpsLabel = [YYFPSLabel new];
        [fpsLabel sizeToFit];
        fpsLabel.frame = CGRectMake(ScreenWidth - 60, 20, 55, 20);
        fpsLabel.alpha = 0;
        [self.view addSubview:fpsLabel];
        fpsLabel;
    });
    
    self.vpnButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((ScreenWidth - 100)*0.5, 50, 100, 50);
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.font = kDefaultFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:@"获取VPN" forState:UIControlStateNormal];
        [button setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(requestVpnLink:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 8.0f;
        button.clipsToBounds = YES;
        button.layer.borderColor = kDefaultColor.CGColor;
        button.layer.borderWidth = 2.0f;
        [self.view addSubview:button];
        button;
    });
    
    self.resultView = ({
        CGFloat resultViewW = 300;
        CGFloat resultViewH = 180;
        
        UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - 300)*0.5, 150, resultViewW, resultViewH)];
        resultView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        resultView.layer.cornerRadius = 10.0f;
        resultView.clipsToBounds = YES;
        resultView.layer.borderColor = kDefaultColor.CGColor;
        resultView.layer.borderWidth = 2.0f;
        resultView.alpha = 0.0f;
        [self.view addSubview:resultView];
        
        CGFloat buttonW = resultViewW;
        CGFloat buttonH = resultViewH/3;
        CGFloat buttonX = (resultViewW - buttonW)*0.5;
        CGFloat buttonY = 0;
        
        CGRect ipButtonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        self.ipButton = [self createVPNInfoButtonWithFrame:ipButtonFrame
                                                    action:@selector(copyInfo:)
                                                 superView:resultView];
        
        buttonY += buttonH;
        CGRect accountButtonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        self.accountButton = [self createVPNInfoButtonWithFrame:accountButtonFrame
                                                         action:@selector(copyInfo:)
                                                      superView:resultView];
        
        buttonY += buttonH;
        CGRect passwordButtonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        self.passwordButton = [self createVPNInfoButtonWithFrame:passwordButtonFrame
                                                          action:@selector(copyInfo:)
                                                       superView:resultView];
        
        resultView;
    });
    
    
    self.activity = ({
    
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        activity.center = self.view.center;
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:activity];
        activity;
    });
}


- (UIButton *)createVPNInfoButtonWithFrame:(CGRect)frame action:(SEL)action superView:(UIView *)superView {
    
    UIButton *vpnInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [vpnInfoButton setTitleColor:kSkyBlueColor forState:UIControlStateNormal];
    vpnInfoButton.frame = frame;
    vpnInfoButton.layer.borderWidth = 0.5f;
    vpnInfoButton.layer.borderColor = kSkyBlueColor.CGColor;
    [vpnInfoButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:vpnInfoButton];
    return vpnInfoButton;
}


#pragma mark - UIButton click occurrences

- (void)copyInfo:(UIButton *)button {
    
    NSString *replacingStr = nil;
    if (button == self.ipButton) {
        
        replacingStr = kDefaultIPStr;
    } else if (button == self.accountButton) {
        replacingStr = kDefaultAccountStr;
    } else if (button == self.passwordButton) {
        replacingStr = kDefaultPasswordStr;
    }
    
    [[UIPasteboard generalPasteboard] setString:[button.currentTitle stringByReplacingOccurrencesOfString:replacingStr withString:@""]];
    [self.view makeToast:[NSString stringWithFormat:@"已复制  %@", button.currentTitle]];
}

- (void)requestVpnLink:(UIButton *)button {
    
    button.enabled = NO;
    
    NSTimeInterval interval = [self intervalRequestDataWithDelay:kDefaultDelay saveCurrentTime:YES];
    if (interval) {
        
        [button setTitle:[NSString stringWithFormat:@"%.1f后\n再重新获取", interval] forState:UIControlStateNormal];
        button.titleLabel.font = kLoadFont;
        
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    } else {
        
        [self hiddenResultViewStatus:YES];
        
        [button setTitle:@"加载中..." forState:UIControlStateNormal];
        [button setTitleColor:kLoadColor forState:UIControlStateNormal];
        button.titleLabel.font = kDefaultFont;
        button.layer.borderColor = kLoadColor.CGColor;
        
        //显示网络状态
        [self.activity startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [FPVNetWork getFreeVpnInfoBlock:^(NSString *htmlstring, NSString *filePath, FPVAccountModel *accountModel) {
            if (accountModel) {
                
                if (!self.webView.delegate) {
                    self.webView.delegate = self;
                }
                
                [self.ipButton setTitle:[NSString stringWithFormat:@"%@%@", kDefaultIPStr, accountModel.ipStr] forState:UIControlStateNormal];
                [self.accountButton setTitle:[NSString stringWithFormat:@"%@%@", kDefaultAccountStr, accountModel.accountStr] forState:UIControlStateNormal];
                [self.passwordButton setTitle:[NSString stringWithFormat:@"%@%@", kDefaultPasswordStr,  accountModel.passwordStr] forState:UIControlStateNormal];
                
                [self.webView loadHTMLString:htmlstring baseURL:[NSURL URLWithString:filePath]];
                
            } else {
                
                [self.vpnButton setTitle:@"获取VPN" forState:UIControlStateNormal];
                [self.vpnButton setTitleColor:kDefaultColor forState:UIControlStateNormal];
                self.vpnButton.layer.borderColor = kDefaultColor.CGColor;
                if (!_link) {
                    self.vpnButton.enabled = YES;
                }
            }
            [self.activity stopAnimating];
        }];
    }
}


#pragma mark - Timing operation

- (void)tick:(CADisplayLink *)link {
    
    NSTimeInterval interval = [self intervalRequestDataWithDelay:kDefaultDelay saveCurrentTime:NO];
    if (interval) {
        [self.vpnButton setTitle:[NSString stringWithFormat:@"%.1f后\n再重新获取", interval] forState:UIControlStateNormal];
    } else {
        
        /* 二选一 */
        [self requestVpnLink:self.vpnButton];
        //        [self.vpnButton setTitle:@"获取VPN" forState:UIControlStateNormal];
        //        self.vpnButton.titleLabel.font = kDefaultFont;
        //        self.vpnButton.enabled = YES;
        
        [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_link invalidate];
        _link = nil;
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    
    [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_link invalidate];
    _link = nil;
}


#pragma mark - ResultView operation Animation

- (void)hiddenResultViewStatus:(BOOL)status {
    
    if (status) {
        
        if (0 == self.resultView.alpha) { return; }
        [UIView animateWithDuration:kAnimateDuration animations:^{
            self.resultView.transform = CGAffineTransformMakeTranslation(0, 80);
            self.resultView.alpha = 0;
            
        }];
        
    } else {
        
        if (1.0 == self.resultView.alpha) { return; }
        [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.resultView.alpha = 1.0;
            self.resultView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    if (point.x > 0) {
        // 过滤左右滑动
        scrollView.contentOffset = CGPointMake(0, point.y);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (_fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (0 == self.resultView.alpha)  {
        [self hiddenResultViewStatus:NO];
        [self.vpnButton setTitle:@"获取VPN" forState:UIControlStateNormal];
        [self.vpnButton setTitleColor:kDefaultColor forState:UIControlStateNormal];
        self.vpnButton.layer.borderColor = kDefaultColor.CGColor;
        if (!_link) {
            self.vpnButton.enabled = YES;
        }
        
        //不显示网络状态
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


/**
 *  是否需要请求网络
 *
 *  @param delay 每次请求网络间隔时间
 */
- (NSTimeInterval)intervalRequestDataWithDelay:(NSTimeInterval)delay saveCurrentTime:(BOOL)status
{
    // 现在的时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // delay秒后请求网络
    if (currentTime >= _curRequestTime + delay) {
        if (status) {
            _curRequestTime = currentTime;
        }
        return 0;
    } else {
        return delay - (currentTime - _curRequestTime);
    }
}




//编码图片
- (NSString *)htmlForJPGImage:(UIImage *)image
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(ScreenSize);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage,1.0);
    
    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[imageData base64Encoding]];
    return [NSString stringWithFormat:@"<img src = \"%@\" />", imageSource];
}
@end
