//
//  SettingOAuthWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import "SettingOAuthWindowController.h"
#import "BRMastodonClient.h"
#import "BRMastodonOAuthResult.h"

@interface SettingOAuthWindowController ()
@property (strong, nonatomic) BRMastodonApp *app;
@end

@implementation SettingOAuthWindowController

- (instancetype) initWithApp:(BRMastodonApp *)app {
    if (self = [self initWithWindowNibName:@"SettingOAuthWindowController"]) {
        self.app = app;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, self.window.contentView.frame.size.width, self.window.contentView.frame.size.height)];
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    self.webView.navigationDelegate = self;
    [self.window.contentView addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[self.app authorisationURL]];
    [self.webView loadRequest:request];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
