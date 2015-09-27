//
//  LXAuthViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AppDelegate.h"
#import "LXOAuthInfo.h"
#import "AFNetworking.h"
#import "LXOAuthInfoManager.h"
#import "LXAuthViewController.h"
#import "MBProgressHUD+LXExtension.h"

static NSString * const kLXAuthorizeURLString   = @"https://api.weibo.com/oauth2/authorize?client_id=2547705806&redirect_uri=http://";
static NSString * const kLXAccessTokenURLString = @"https://api.weibo.com/oauth2/access_token";

@interface LXAuthViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *code;

@end

@implementation LXAuthViewController

#pragma mark - 加载授权页面

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(UIWebView *)self.view loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:kLXAuthorizeURLString]]];
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
    NSAssert(self.code, @"code 为 nil.");

    LXLog(@"正在授权...");

    [MBProgressHUD lx_showMessage:@"正在授权..."];

    NSDictionary *parameters = @{ @"client_id"     : LXAppKey,
                                  @"client_secret" : LXAppSecret,
                                  @"grant_type"    : @"authorization_code",
                                  @"code"          : self.code,
                                  @"redirect_uri"  : @"http://", };

    [[AFHTTPRequestOperationManager manager] POST:kLXAccessTokenURLString
                                       parameters:parameters
                                          success:
     ^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {

         LXLog(@"授权成功");

         [MBProgressHUD lx_hideHUD];

         LXOAuthInfo *OAuthInfo = [LXOAuthInfo OAuthInfoWithDictionary:responseObject];
         [LXOAuthInfoManager saveOAuthInfo:OAuthInfo];

         [UIStoryboard lx_showInitialVCWithStoryboardName:@"NewFeature"];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         [MBProgressHUD lx_hideHUD];
         [MBProgressHUD lx_showError:@"授权出错!"];

         LXLog(@"授权出错 \n%@", error);
     }];
}

@end