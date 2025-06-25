//
//  SettingOAuthWindowController.h
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BRMastodonApp.h"
#import "BRMastodonAccount.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SettingOAuthWindowControllerDelegate

- (void)settingOAuthWindowController:(id)sender didLoggedInAccount:(BRMastodonAccount *)account;
- (void)settingOAuthWindowController:(nonnull id)sender didLoggedInMisskeyAccount:(nonnull BRMisskeyAccount *)account;
- (void)settingOAuthWindowController:(id)sender receivedError:(NSError *)error;

@end

@interface SettingOAuthWindowController : NSWindowController <WKNavigationDelegate>

- (instancetype)initWithApp:(BRMastodonApp *)app;
- (instancetype)initWithMisskeyHostName:(NSURL *)url;

@property (weak) id<SettingOAuthWindowControllerDelegate> delegate;
@property (strong) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
