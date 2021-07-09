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
#import "BRStreamHandler.h"
#import "MastodonStatus.h"
#import "DummyStatus.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController()

@property (nonatomic, strong) BRMastodonAccount *account;
@property (nonatomic, strong) BRStreamHandler *streamHandler;

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

- (id)initWithAccount:(BRMastodonAccount*)account {
    self = [super init];

    self.account = account;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedAccountChanged:)
                                                 name:kSelectedAccountChanged
                                               object:nil];

    return self;
}

- (void)selectedAccountChanged:(NSNotification *)notification {
    BRMastodonAccount *changedToAccount = [[SettingManager sharedManager] selectedAccount];
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
    
    [self.streamHandler.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];

    self.streamHandler = [[BRMastodonClient shared] streamingStatusesWithAccount:[[SettingManager sharedManager] selectedAccount]];
    self.streamHandler.onStatus = ^(BRMastodonStatus * _Nonnull status) {
        if ([_self.delegate respondsToSelector:@selector(streamController:didReceivedStatus:)]) {
            [_self.delegate streamController:_self didReceivedStatus:[[MastodonStatus alloc] initWithMastodonStatus:status]];
        }
    };
    self.streamHandler.onConnected = ^{
        [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Connecting to %@",nil), _self.account.displayName]];
    };
    self.streamHandler.onDisconnected = ^{
        [_self showNotificationWithText: [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@",nil), _self.account.displayName]];
    };
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
