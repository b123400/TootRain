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
#import "BRMisskeyClient.h"

@interface SettingOAuthWindowController ()
@property (strong, nonatomic) BRMastodonApp *app;
@property (strong, nonatomic) NSURL *slackURL;
@property (strong, nonatomic) NSURL *misskeyHostName;
@property (assign, nonatomic) BOOL isHandlingSlack;
@end

@implementation SettingOAuthWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"SettingOAuthWindowController"];
}

- (instancetype)initWithApp:(BRMastodonApp *)app {
    if (self = [self init]) {
        self.app = app;
    }
    return self;
}

- (instancetype)initWithSlackURL:(NSURL *)url {
    if (self = [self init]) {
        self.slackURL = url;
    }
    return self;
}

- (instancetype)initWithMisskeyHostName:(NSURL *)url {
    if (self = [self init]) {
        self.misskeyHostName = url;
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
        self.webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36";
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.slackURL]];
    } else if (self.misskeyHostName) {
        NSURL *url = [[BRMisskeyClient shared] authURLWithHost:self.misskeyHostName];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
            // Mastodon
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
        if ([url.host isEqualToString:@"misskeyoauth"]) {
            // Misskey
            NSString *sessionId = [[[[[NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO]
                                      queryItems]
                                     filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == 'session'"]]
                                    firstObject]
                                   value];
            [[BRMisskeyClient shared] newAccountWithHost:self.misskeyHostName
                                               sessionId:sessionId
                                       completionHandler:^(BRMisskeyAccount * _Nullable account, NSError * _Nullable error) {
                if (error) {
                    [_self.delegate settingOAuthWindowController:_self
                                                  receivedError:error];
                    return;
                }
                [_self.delegate settingOAuthWindowController:_self didLoggedInMisskeyAccount:account];
            }];
        }
        return;
    }
    if (self.slackURL) {
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
        } else if ([url.scheme isEqualTo:@"https"] && [url.path hasPrefix:@"/client/"]) {
            // it's already logged in, force it to open-in-app
            decisionHandler(WKNavigationActionPolicyCancel);
            NSURL *openInAppURL = [[NSURL URLWithString:@"/ssb/redirect" relativeToURL:url] absoluteURL];
            [webView loadRequest:[NSURLRequest requestWithURL:openInAppURL]];
            return;
        } else {
            NSLog(@"URL: %@", url);
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
