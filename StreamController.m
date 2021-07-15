//
//  StreamController.m
//  flood
//
//  Created by b123400 on 2/11/14.
//
//

#import "StreamController.h"
#import <Social/Social.h>
#import "Status.h"
#import "SettingManager.h"
#import "BRMastodonClient.h"
#import "BRMastodonStatus.h"
#import "BRMastodonStreamHandler.h"
#import "BRSlackStreamHandler.h"
#import "MastodonStatus.h"
#import "DummyStatus.h"
#import "BRSlackClient.h"
#import "MastodonAccount.h"
#import "SlackAccount.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController()

@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) id streamHandler;

@end

@implementation StreamController

static StreamController *shared;

+ (instancetype)shared {
    if (!shared) {
        shared = [[StreamController alloc] initWithAccount:[[SettingManager sharedManager] selectedAccount]];
    }
    return shared;
}

# pragma mark - instance methods

- (id)initWithAccount:(Account*)account {
    self = [super init];

    self.account = account;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedAccountChanged:)
                                                 name:kSelectedAccountChanged
                                               object:nil];

    return self;
}

- (void)selectedAccountChanged:(NSNotification *)notification {
    Account *changedToAccount = [[SettingManager sharedManager] selectedAccount];
    if ([changedToAccount.identifier isEqualToString:self.account.identifier]) return;

    self.account = changedToAccount;
    [self reconnect];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSearchTerm:(NSString*)searchTerm {
    _searchTerm = searchTerm;
    [self reconnect];
}

- (void)startStreaming {
    [self reconnect];
}

- (void)reconnect {
    typeof(self) __weak _self = self;
    if (!self.account) return;

    if ([self.streamHandler isKindOfClass:[BRMastodonStreamHandler class]]) {
        BRMastodonStreamHandler *handler = (BRMastodonStreamHandler *)self.streamHandler;
        [handler.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
    } else if ([self.streamHandler isKindOfClass:[BRSlackStreamHandler class]]) {
        BRSlackStreamHandler *handler = (BRSlackStreamHandler *)self.streamHandler;
        [handler.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
    }
    Account *selectedAccount = [[SettingManager sharedManager] selectedAccount];
    if ([selectedAccount isKindOfClass:[MastodonAccount class]]) {
        BRMastodonAccount *mastondonAccount = [(MastodonAccount *)selectedAccount mastodonAccount];
        BRMastodonStreamHandler *newHandler = [[BRMastodonClient shared] streamingStatusesWithAccount:mastondonAccount];
        newHandler.onStatus = ^(BRMastodonStatus * _Nonnull status) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                [_self.delegate streamController:_self didReceivedStatus:[[MastodonStatus alloc] initWithMastodonStatus:status]];
            }
        };
        newHandler.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), mastondonAccount.displayName]];
        };
        newHandler.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), mastondonAccount.displayName]];
        };
        self.streamHandler = newHandler;
    } else if ([selectedAccount isKindOfClass:[SlackAccount class]]) {
        BRSlackAccount *slackAccount = [(SlackAccount *)selectedAccount slackAccount];
        BRSlackStreamHandler *handler = [[BRSlackClient shared] streamMessageWithAccount:slackAccount];
        handler.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@ #%@",nil), slackAccount.teamName, slackAccount.channelName]];
        };
        handler.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@ #%@",nil), slackAccount.teamName, slackAccount.channelName]];
        };
        handler.onMessage = ^(NSString * _Nonnull message) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                DummyStatus *s = [[DummyStatus alloc] init];
                s.text = message;
                [_self.delegate streamController:_self didReceivedStatus:s];
            }
        };
        self.streamHandler = handler;
    }
}

- (void)showNotificationWithText:(NSString *)text {
#if TARGET_OS_IPHONE
    [SVProgressHUD showInfoWithStatus:text];
#elif TARGET_OS_MAC
    DummyStatus *status = [[DummyStatus alloc] init];
    status.text = text;
    [self.delegate streamController:self didReceivedStatus:status];
#endif
}

@end
