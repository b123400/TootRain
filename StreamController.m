//
//  StreamController.m
//  flood
//
//  Created by b123400 on 2/11/14.
//
//

#import "StreamController.h"
#import <Social/Social.h>
#import <STTwitter/STTwitter.h>
#import "Status.h"
#import "SettingManager.h"

#if TARGET_OS_IPHONE
#import <SVProgressHUD/SVProgressHUD.h>
#endif

@interface StreamController() <STTwitterAPIOSProtocol>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, strong) NSURLConnection *streamConnection;

- (void)showNotification;

@end

@implementation StreamController

static StreamController *shared;

+ (instancetype)shared {
    if (!shared) {
        shared = [[StreamController alloc] initWithAccount:[[SettingManager sharedManager] selectedAccount]];
        
        // shared controller should always follow the selectedAccount
        [[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(accountStoreDidChanged:) name:ACAccountStoreDidChangeNotification object:nil];
    }
    return shared;
}

- (void)accountStoreDidChanged:(NSNotification*)notification {
    ACAccount *changedToAccount = [[SettingManager sharedManager] selectedAccount];
    if ([changedToAccount.identifier isEqualToString:self.account.identifier]) return;
    
    self.account = changedToAccount;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:self.account delegate:self];
    [self reconnect];

    [self showNotification];
}

# pragma mark - instance methods

- (id)initWithAccount:(ACAccount*)account {
    self = [super init];
    
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    self.account = account;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:self.account delegate:self];
    
    return self;
}

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSearchTerm:(NSString*)searchTerm {
    _searchTerm = searchTerm;
    [self reconnect];
}

- (void)startStreaming {
    if (!self.streamConnection) {
        [self showNotification];
    }
    [self reconnect];
}

- (void)reconnect {
    [self.streamConnection cancel];
    if (!self.account) return;
    [self.twitter getUserStreamIncludeMessagesFromFollowedAccounts:@YES
                                                    includeReplies:@YES
                                                   keywordsToTrack:self.searchTerm?@[self.searchTerm]:nil
                                             locationBoundingBoxes:nil
                                                        tweetBlock:^(NSDictionary *tweet)
     {
         Status *status = [[Status alloc] initWithDictionary:tweet];
         if (status && [self.delegate respondsToSelector:@selector(streamController:didReceivedTweet:)]) {
             [self.delegate streamController:self didReceivedTweet:status];
         }
     } errorBlock:^(NSError *error)
     {
         [self showNotificationWithTitle:NSLocalizedString(@"Stream disconnected",nil)
                                    body:[NSString stringWithFormat:
                                          NSLocalizedString(@"Reconnecting to user: %@",nil),
                                          self.account.username]];
         [self reconnect];
     }];
}

- (void)showNotification {
    if (!self.account) return;
    [self showNotificationWithTitle: NSLocalizedString(@"Stream Connecting",nil)
                               body: [NSString stringWithFormat:
                                      NSLocalizedString(@"Connecting to %@",nil),
                                      self.account.username]];
}

- (void)showNotificationWithTitle:(NSString*)title body:(NSString*)body {
#if TARGET_OS_IPHONE
    [SVProgressHUD showInfoWithStatus:body];
#elif TARGET_OS_MAC
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = body;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
#endif
}

@end
