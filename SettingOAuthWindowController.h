//
//  SettingOAuthWindowController.h
//  TweetRain
//
//  Created by b123400 on 2021/07/01.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BRMastodonApp.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SettingOAuthWindowControllerDelegate

- (void)settingOAuthWindowController:(id)sender receivedAccessToken:(NSString *)accessToken;
- (void)settingOAuthWindowController:(id)sender receivedError:(NSError *)error;

@end

@interface SettingOAuthWindowController : NSWindowController <WKNavigationDelegate>

- (instancetype) initWithApp:(BRMastodonApp *)app;

@property (weak) id<SettingOAuthWindowControllerDelegate> delegate;
@property (strong) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
