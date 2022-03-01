//
//  SettingOAuthWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import "SettingOAuthWindowController.h"
#import "BRMastodonClient.h"
#import "BRMastodonOAuthResult.h"
#import "BRSlackClient.h"

@interface SettingOAuthWindowController ()
@property (strong, nonatomic) BRMastodonApp *app;
@property (strong, nonatomic) NSURL *slackURL;
@property (assign, nonatomic) BOOL isHandlingSlack;
@end

@implementation SettingOAuthWindowController

- (instancetype)initWithApp:(BRMastodonApp *)app {
    if (self = [super initWithWindowNibName:@"SettingOAuthWindowController"]) {
        self.app = app;
    }
    return self;
}

- (instancetype)initWithSlackURL:(NSURL *)url {
    if (self = [super initWithWindowNibName:@"SettingOAuthWindowController"]) {
        self.slackURL = url;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, self.window.contentView.frame.size.width, self.window.contentView.frame.size.height)];
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    self.webView.navigationDelegate = self;
    [self.window.contentView addSubview:self.webView];
    
    if (self.app) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[self.app authorisationURL]];
        [self.webView loadRequest:request];
    } else if (self.slackURL) {
        self.webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36";
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.slackURL]];
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    typeof(self) __weak _self = self;
    if ([url.scheme isEqualToString:@"tootrain"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([url.host isEqualToString:@"oauth"]) {
            NSString *code = [[[[[NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO]
                                 queryItems]
                                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == 'code'"]]
                               firstObject]
                              value];
            [[BRMastodonClient shared] getAccessTokenWithApp:_self.app
                                                        code:code
                                           completionHandler:^(BRMastodonOAuthResult * _Nullable oauthResult, NSError * _Nullable error) {
                if (error) {
                    [_self.delegate settingOAuthWindowController:_self
                                                  receivedError:error];
                    return;
                }
                [[BRMastodonClient shared] verifyAccountWithApp:_self.app
                                                    oauthResult:oauthResult
                                              completionHandler:^(BRMastodonAccount * _Nullable account, NSError * _Nullable error) {
                    [_self.delegate settingOAuthWindowController:_self didLoggedInAccount:account];
                }];
            }];
        }
        return;
    }
    if ([url.scheme isEqualToString:@"slack"]) {
        if (!self.isHandlingSlack) {
            self.isHandlingSlack = YES;
            [[BRSlackClient shared] receivedMagicLoginURL:url
                                               withWindow:self.window
                                          updatingAccount:self.updatingSlackAccount
                                        completionHandler:^(BRSlackAccount * _Nonnull account, NSError * _Nonnull error) {
                if (account) {
                    [_self.delegate settingOAuthWindowController:_self didLoggedInSlackAccount:account];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [[NSAlert alertWithError:error] runModal];
                        }
                        [_self.window close];
                    });
                }
            }];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
