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
#import "MastodonAccount.h"
#import "SlackAccount.h"
#import "StreamHandle.h"
#import "MastodonStreamHandle.h"
#import "SlackStreamHandle.h"

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
    }
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
    
    if (self.streamHandle) {
        [self.streamHandle disconnect];
    }
    Account *selectedAccount = [[SettingManager sharedManager] selectedAccount];
    if ([selectedAccount isKindOfClass:[MastodonAccount class]]) {
        BRMastodonAccount *mastondonAccount = [(MastodonAccount *)selectedAccount mastodonAccount];
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
    } else if ([selectedAccount isKindOfClass:[SlackAccount class]]) {
        BRSlackAccount *slackAccount = [(SlackAccount *)selectedAccount slackAccount];
        BRSlackStreamHandle *brHandle = [[BRSlackClient shared] streamMessageWithAccount:slackAccount];
        SlackStreamHandle *newHandle = [[SlackStreamHandle alloc] initWithHandle:brHandle];
        newHandle.onConnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@ #%@",nil), slackAccount.teamName, slackAccount.channelName]];
        };
        newHandle.onDisconnected = ^{
            [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@ #%@",nil), slackAccount.teamName, slackAccount.channelName]];
        };
        newHandle.onMessage = ^(SlackStatus * _Nonnull message) {
            if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
                [_self.delegate streamController:_self didReceivedStatus:message];
            }
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
