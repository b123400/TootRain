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
#import "BRMastodonStreamHandle.h"
#import "BRSlackStreamHandle.h"
#import "MastodonStatus.h"
#import "DummyStatus.h"
#import "BRSlackClient.h"
#import "StreamHandle.h"
#import "MastodonStreamHandle.h"
#import "SlackStreamHandle.h"
#import "SettingViewController.h"
#import "BRMisskeyClient.h"
#import "MisskeyStreamHandle.h"
#import "IRC/BRIrcAccount.h"
#import "IRC/BRIrcClient.h"
#import "IrcStreamHandle.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamState : NSObject
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) StreamHandle *handle;
@property (atomic, assign) bool scheduledReconnect;
@end

@implementation StreamState

- (instancetype)initWithAccount:(Account *)account {
    if (self = [super init]) {
        self.account = account;
    }
    return self;
}

@end

@interface StreamController()

@property (nonatomic, strong) NSMutableDictionary<NSString*, StreamState*> *streams;

@end

@implementation StreamController

static StreamController *shared;

+ (instancetype)shared {
    if (!shared) {
        shared = [[StreamController alloc] init];
    }
    return shared;
}

# pragma mark - instance methods

- (id)init{
    self = [super init];
    
    self.streams = [NSMutableDictionary dictionary];

    return self;
}

- (void)disconnectStreamWithAccount:(Account *)account {
    StreamState *state = self.streams[account.identifier];
    if (!state) return;
    [state.handle disconnect];
    [self.streams removeObjectForKey:account.identifier];
}

- (void)reconnectAfterAWhileWithAccount:(Account *)account {
    StreamState *state = self.streams[account.identifier];
    if (!state) {
        [self startStreamingWithAccount:account];
        return;
    }
    if (state.scheduledReconnect) return;
    state.scheduledReconnect = true;
    if (state.handle) {
        [state.handle disconnect];
    }
    typeof(self) __weak _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        state.scheduledReconnect = false;
        [_self startStreamingWithAccount:account];
    });
}

- (void)startStreamingWithAccount:(Account *)account {
    if (!account) return;
    typeof(self) __weak _self = self;
    
    StreamState *state = self.streams[account.identifier];
    
    if (state) {
        [state.handle disconnect];
    } else {
        state = [[StreamState alloc] initWithAccount:account];
        self.streams[account.identifier] = state;
    }
    if ([account isKindOfClass:[BRMastodonAccount class]]) {
        BRMastodonAccount *mastondonAccount = (BRMastodonAccount *)account;
        BRMastodonStreamHandle *brHandle = [[BRMastodonClient shared] streamingStatusesWithAccount:mastondonAccount];
        MastodonStreamHandle *newHandle = [[MastodonStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onStatus = ^(MastodonStatus * _Nonnull status) {
            [_self showStatus:status];
        };
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), mastondonAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Reconnecting to %@",nil), mastondonAccount.displayName]];
            [_self reconnectAfterAWhileWithAccount:account];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Reconnecting to %@",nil), mastondonAccount.displayName]];
            [_self reconnectAfterAWhileWithAccount:account];
        };
        state.handle = newHandle;
    } else if ([account isKindOfClass:[BRSlackAccount class]]) {
        BRSlackAccount *slackAccount = (BRSlackAccount*)account;
        BRSlackStreamHandle *brHandle = [[BRSlackClient shared] streamMessageWithAccount:slackAccount];
        SlackStreamHandle *newHandle = [[SlackStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), slackAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Reconnecting to %@",nil), slackAccount.teamName]];
            [_self reconnectAfterAWhileWithAccount:account];
        };
        newHandle.onMessage = ^(SlackStatus * _Nonnull message) {
            [_self showStatus:message];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            [_self reconnectAfterAWhileWithAccount:account];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            if ([error.domain isEqualTo:@"BRSlackClient"] && error.code == 401) {
                [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Need to re-login %@",nil), slackAccount.teamName]];
                BRSlackAccount *account = error.userInfo[@"account"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[SettingViewController sharedPrefsWindowController] showWindow:_self];
                    [(SettingViewController*)[SettingViewController sharedPrefsWindowController] addAccountWithHostName: [account.url absoluteString]
                                                                                                            accountType:SettingAccountTypeSlack
                                                                                                   updatingSlackAccount:slackAccount];
                });
            }
        };
        state.handle = newHandle;
    } else if ([account isKindOfClass:[BRMisskeyAccount class]]) {
        BRMisskeyAccount *misskeyAccount = (BRMisskeyAccount *)account;
        BRMisskeyStreamHandle *brHandle = [[BRMisskeyClient shared] streamStatusWithAccount:misskeyAccount];
        MisskeyStreamHandle *newHandle = [[MisskeyStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onStatus = ^(MisskeyStatus * _Nonnull status) {
            [_self showStatus:status];
        };
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), misskeyAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), misskeyAccount.displayName]];
            [_self reconnectAfterAWhileWithAccount:account];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            [_self reconnectAfterAWhileWithAccount:account];
        };
        state.handle = newHandle;
    } else if ([account isKindOfClass:[BRIrcAccount class]]) {
        BRIrcAccount *ircAccount = (BRIrcAccount *)account;
        BRIrcStreamHandle *handle = [[BRIrcClient shared] streamWithAccount:ircAccount];
        IrcStreamHandle *newHandle = [[IrcStreamHandle alloc] initWithHandle:handle];
        newHandle.onStatus = ^(DummyStatus * _Nonnull status) {
            [_self showNotificationWithText:status.text];
        };
        state.handle = newHandle;
    }
}

- (void)showNotificationWithText:(NSString *)text {
#if TARGET_OS_IPHONE
    [SVProgressHUD showInfoWithStatus:text];
#elif TARGET_OS_MAC
    DummyStatus *status = [[DummyStatus alloc] init];
    status.text = text;
    [self showStatus:status];
#endif
}

- (void)showStatus:(Status *)status {
    if ([self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
        [self.delegate streamController:self didReceivedStatus:status];
    }
}

@end
