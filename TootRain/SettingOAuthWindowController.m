//
//  SettingOAuthWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import "SettingOAuthWindowController.h"
#import "BRMastodonClient.h"
#import "BRMastodonOAuthResult.h"
#import "BRMisskeyClient.h"

@interface SettingOAuthWindowController ()
@property (strong, nonatomic) BRMastodonApp *app;
@property (strong, nonatomic) NSURL *misskeyHostName;
@property (strong, nonatomic) NSProgressIndicator *loadingIndicator;
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

    self.loadingIndicator = [[NSProgressIndicator alloc] init];
    self.loadingIndicator.style = NSProgressIndicatorStyleSpinning;
    self.loadingIndicator.displayedWhenStopped = NO;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.accessibilityLabel = NSLocalizedString(@"Loading", @"oauth window spinner");
    [self.window.contentView addSubview:self.loadingIndicator];
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.window.contentView.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.window.contentView.centerYAnchor],
    ]];
    // Watching the web view itself rather than the navigation callbacks: it is
    // the one thing that stays right across the redirects an OAuth log-in makes.
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionInitial
                      context:NULL];

    if (self.app) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[self.app authorisationURL]];
        [self.webView loadRequest:request];
    } else if (self.misskeyHostName) {
        NSURL *url = [[BRMisskeyClient shared] authURLWithHost:self.misskeyHostName];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (object != self.webView || ![keyPath isEqualToString:@"loading"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if (self.webView.loading) {
        [self.loadingIndicator startAnimation:nil];
    } else {
        [self.loadingIndicator stopAnimation:nil];
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"loading"];
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
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
