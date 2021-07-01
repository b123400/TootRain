//
//  SettingOAuthWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import "SettingOAuthWindowController.h"
#import "BRMastodonClient.h"

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
    if ([url.scheme isEqualToString:@"tootrain"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([url.host isEqualToString:@"oauth"]) {
            NSString *code = [[[[[NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO]
                                 queryItems]
                                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == 'code'"]]
                               firstObject]
                              value];
            [[BRMastodonClient shared] getAccessTokenWithApp:self.app
                                                        code:code
                                           completionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
                if (accessToken) {
                    [self.delegate settingOAuthWindowController:self receivedAccessToken:accessToken];
                } else {
                    [self.delegate settingOAuthWindowController:self receivedError:error];
                }
            }];
        }
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
