//
//  LXAuthViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXConst.h"
#import "LXUtilities.h"
#import "LXStatusManager.h"
#import "LXAuthViewController.h"
#import "MBProgressHUD+LXExtension.h"

@interface LXAuthViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *code;

@end

@implementation LXAuthViewController

#pragma mark - 加载授权页面

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(UIWebView *)self.view loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:LXAuthorizeURL]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    LXLog(@"正在加载...");

    [MBProgressHUD lx_showMessage:@"正在加载..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    LXLog(@"加载完成...");

    [MBProgressHUD lx_hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    LXLog(@"加载失败... \n %@", error);

    [MBProgressHUD lx_hideHUD];

    // shouldStartLoadWithRequest 方法中返回 NO 会触发此方法,如果 code 有值,说明是手动触发的.
    if (self.code) {
        [self requestAccessToken];
    } else {
        [MBProgressHUD lx_showError:@"网络繁忙!"];
    }
}

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *query = request.URL.query;

    LXLog(@"shouldStartLoadWithRequest %@", query);

    if (!query) {
        return YES;
    }

    // 如果用户同意授权,请求会重定向,页面将跳转至 YOUR_REGISTERED_REDIRECT_URI/?code=CODE .
    // 一旦发现是重定向的 URL, 返回 NO, 禁止加载重定向页面,接着会触发 didFailLoadWithError 代理方法.
    // 然后在那个代理方法中发起获取 access_token 的请求.主要是因为那个代理方法中有隐藏 HUD 的操作,
    // 如果在该方法中发起获取 access_token 的请求,刚显示的 HUD 就会被隐藏掉.
    NSRange codeRange = [query rangeOfString:@"code="
                                     options:(NSStringCompareOptions)0
                                       range:(NSRange){0,5}];

    if (codeRange.location != NSNotFound) {
        self.code = [query substringFromIndex:codeRange.location + codeRange.length];
        return NO;
    }

    return YES;
}

#pragma mark - 获取 AccessToken

- (void)requestAccessToken
{
    [MBProgressHUD lx_showMessage:@"正在授权..."];

    [LXStatusManager requestAccessTokenWithAuthorizationCode:self.code
                                                completion:
     ^(LXOAuthInfo * _Nonnull OAuthInfo) {

         [MBProgressHUD lx_hideHUD];
         [UIStoryboard lx_showInitialVCWithStoryboardName:@"NewFeature"];

     } failure:^(NSError * _Nonnull error) {
         
         [MBProgressHUD lx_hideHUD];
         [MBProgressHUD lx_showError:@"授权出错!"];
     }];
}

@end