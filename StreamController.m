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

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController()

@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) StreamHandle *streamHandle;

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
    if (!changedToAccount && self.streamHandle) {
        // Nothing is selected, but we are connected to sth, need to disconnect
        [self.streamHandle disconnect];
        self.streamHandle = nil;
        self.account = nil;
    }

    self.account = changedToAccount;
    [self reconnect];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startStreaming {
    [self reconnect];
}

- (void)reconnect {
    typeof(self) __weak _self = self;
    if (!self.account) return;
    
    if (self.streamHandle) {
        [self.streamHandle disconnect];
    }
    Account *selectedAccount = [[SettingManager sharedManager] selectedAccount];
    if ([selectedAccount isKindOfClass:[BRMastodonAccount class]]) {
        BRMastodonAccount *mastondonAccount = (BRMastodonAccount *)selectedAccount;
        BRMastodonStreamHandle *brHandle = [[BRMastodonClient shared] streamingStatusesWithAccount:mastondonAccount];
        MastodonStreamHandle *newHandle = [[MastodonStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onStatus = ^(MastodonStatus * _Nonnull status) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                [_self.delegate streamController:_self didReceivedStatus:status];
            }
        };
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), mastondonAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), mastondonAccount.displayName]];
        };
        self.streamHandle = newHandle;
    } else if ([selectedAccount isKindOfClass:[BRSlackAccount class]]) {
        BRSlackAccount *slackAccount = (BRSlackAccount*)selectedAccount;
        BRSlackStreamHandle *brHandle = [[BRSlackClient shared] streamMessageWithAccount:slackAccount];
        SlackStreamHandle *newHandle = [[SlackStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), slackAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), slackAccount.teamName]];
        };
        newHandle.onMessage = ^(SlackStatus * _Nonnull message) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                [_self.delegate streamController:_self didReceivedStatus:message];
            }
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
        self.streamHandle = newHandle;
    } else if ([selectedAccount isKindOfClass:[BRMisskeyAccount class]]) {
        BRMisskeyAccount *misskeyAccount = (BRMisskeyAccount *)selectedAccount;
        BRMisskeyStreamHandle *brHandle = [[BRMisskeyClient shared] streamStatusWithAccount:misskeyAccount];
        MisskeyStreamHandle *newHandle = [[MisskeyStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onStatus = ^(MisskeyStatus * _Nonnull status) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                [_self.delegate streamController:_self didReceivedStatus:status];
            }
        };
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), misskeyAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), misskeyAccount.displayName]];
        };
        self.streamHandle = newHandle;
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
