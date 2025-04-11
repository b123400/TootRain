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
#import "MastodonStatus.h"
#import "DummyStatus.h"
#import "StreamHandle.h"
#import "MastodonStreamHandle.h"
#import "SettingViewController.h"
#import "BRMisskeyClient.h"
#import "MisskeyStreamHandle.h"
#import "IRC/BRIrcAccount.h"
#import "IRC/BRIrcClient.h"
#import "IrcStreamHandle.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController()

@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) StreamHandle *streamHandle;
@property (atomic, assign) bool scheduledReconnect;

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

- (void)reconnectAfterAWhile {
    if (self.scheduledReconnect) return;
    self.scheduledReconnect = true;
    if (self.streamHandle) {
        [self.streamHandle disconnect];
    }
    typeof(self) __weak _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _self.scheduledReconnect = false;
        [_self reconnect];
    });
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
            [_self showStatus:status];
        };
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), mastondonAccount.displayName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Reconnecting to %@",nil), mastondonAccount.displayName]];
            [_self reconnectAfterAWhile];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Reconnecting to %@",nil), mastondonAccount.displayName]];
            [_self reconnectAfterAWhile];
        };
        self.streamHandle = newHandle;
    } else if ([selectedAccount isKindOfClass:[BRMisskeyAccount class]]) {
        BRMisskeyAccount *misskeyAccount = (BRMisskeyAccount *)selectedAccount;
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
            [_self reconnectAfterAWhile];
        };
        newHandle.onError = ^(NSError * _Nonnull error) {
            [_self reconnectAfterAWhile];
        };
        self.streamHandle = newHandle;
    } else if ([selectedAccount isKindOfClass:[BRIrcAccount class]]) {
        BRIrcAccount *ircAccount = (BRIrcAccount *)selectedAccount;
        BRIrcStreamHandle *handle = [[BRIrcClient shared] streamWithAccount:ircAccount];
        IrcStreamHandle *newHandle = [[IrcStreamHandle alloc] initWithHandle:handle];
        newHandle.onStatus = ^(DummyStatus * _Nonnull status) {
            [_self showNotificationWithText:status.text];
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
    [self showStatus:status];
#endif
}

- (void)showStatus:(Status *)status {
    if ([self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
        [self.delegate streamController:self didReceivedStatus:status];
    }
}

@end
