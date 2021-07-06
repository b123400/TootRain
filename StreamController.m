//
//  StreamController.m
//  flood
//
//  Created by b123400 on 2/11/14.
//
//

#import "StreamController.h"
#import <Social/Social.h>
//#import <STTwitter/STTwitter.h>
#import "Status.h"
#import "SettingManager.h"
#import "BRMastodonClient.h"
#import "BRMastodonStatus.h"
#import "BRStreamHandler.h"
#import "MastodonStatus.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController()

@property (nonatomic, strong) BRMastodonAccount *account;
@property (nonatomic, strong) BRStreamHandler *streamHandler;

- (void)showNotification;

@end

@implementation StreamController

static StreamController *shared;

+ (instancetype)shared {
    if (!shared) {
        shared = [[StreamController alloc] initWithAccount:[[SettingManager sharedManager] selectedAccount]];
        
        // shared controller should always follow the selectedAccount
//        [[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(accountStoreDidChanged:) name:ACAccountStoreDidChangeNotification object:nil];
    }
    return shared;
}

//- (void)accountStoreDidChanged:(NSNotification*)notification {
//    BRMastodonAccount *changedToAccount = [[SettingManager sharedManager] selectedAccount];
//    if ([changedToAccount.identifier isEqualToString:self.account.identifier]) return;
//
//    self.account = changedToAccount;
//    [self reconnect];
//
//    [self showNotification];
//}

# pragma mark - instance methods

- (id)initWithAccount:(BRMastodonAccount*)account {
    self = [super init];

    self.account = account;
//    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:self.account delegate:self];
    
    return self;
}

//- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
//    // This should not happen because account is handled by OSX?
//    [self showNotificationWithTitle:NSLocalizedString(@"Account is invalid?", @"")
//                               body:NSLocalizedString(@"Please setup account in system preference", @"")];
//}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSearchTerm:(NSString*)searchTerm {
    _searchTerm = searchTerm;
    [self reconnect];
}

- (void)startStreaming {
//    if (!self.streamConnection) {
//        [self showNotification];
//    }
    [self reconnect];
}

- (void)reconnect {
    typeof(self) __weak _self = self;
    BRStreamHandler *handler = [[BRMastodonClient shared] streamingStatusesWithAccount:[[SettingManager sharedManager] selectedAccount]];
    handler.onStatus = ^(BRMastodonStatus * _Nonnull status) {
        NSLog(@"wow: %@", status);
        [self.delegate streamController:_self didReceivedStatus:[[MastodonStatus alloc] initWithMastodonStatus:status]];
    };
    self.streamHandler = handler;
//    [self.streamConnection cancel];
    if (!self.account) return;
//    [self.twitter getUserStreamIncludeMessagesFromFollowedAccounts:@YES
//                                                    includeReplies:@YES
//                                                   keywordsToTrack:self.searchTerm?@[self.searchTerm]:nil
//                                             locationBoundingBoxes:nil
//                                                        tweetBlock:^(NSDictionary *tweet)
//     {
//         Status *status = [[Status alloc] initWithDictionary:tweet];
//         if (status && [self.delegate respondsToSelector:@selector(streamController:didReceivedTweet:)]) {
//             [self.delegate streamController:self didReceivedTweet:status];
//         }
//     } errorBlock:^(NSError *error)
//     {
//         [self showNotificationWithTitle:NSLocalizedString(@"Stream disconnected",nil)
//                                    body:[NSString stringWithFormat:
//                                          NSLocalizedString(@"Reconnecting to user: %@",nil),
//                                          self.account.username]];
//         [self reconnect];
//     }];
}

- (void)showNotification {
    if (!self.account) return;
    [self showNotificationWithTitle: NSLocalizedString(@"Stream Connecting",nil)
                               body: [NSString stringWithFormat:
                                      NSLocalizedString(@"Connecting to %@",nil),
                                      self.account.url]];
}

- (void)showNotificationWithTitle:(NSString*)title body:(NSString*)body {
#if TARGET_OS_IPHONE
    [SVProgressHUD showInfoWithStatus:body];
#elif TARGET_OS_MAC
    @try {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = body;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    } @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
#endif
}

@end
