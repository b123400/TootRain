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
#import "BRSlackAccount.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SettingOAuthWindowControllerDelegate

- (void)settingOAuthWindowController:(id)sender didLoggedInAccount:(BRMastodonAccount *)account;
- (void)settingOAuthWindowController:(nonnull id)sender didLoggedInSlackAccount:(nonnull BRSlackAccount *)account;
- (void)settingOAuthWindowController:(nonnull id)sender didLoggedInMisskeyAccount:(nonnull BRMisskeyAccount *)account;
- (void)settingOAuthWindowController:(id)sender receivedError:(NSError *)error;

@end

@interface SettingOAuthWindowController : NSWindowController <WKNavigationDelegate>

- (instancetype)initWithApp:(BRMastodonApp *)app;
- (instancetype)initWithSlackURL:(NSURL *)url;
- (instancetype)initWithMisskeyHostName:(NSURL *)url;

@property (weak) id<SettingOAuthWindowControllerDelegate> delegate;
@property (strong) WKWebView *webView;
@property (strong, nonatomic, nullable) BRSlackAccount *updatingSlackAccount;

@end

NS_ASSUME_NONNULL_END
