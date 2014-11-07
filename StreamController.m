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

@interface StreamController()

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
    self.account = [[SettingManager sharedManager] selectedAccount];
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:self.account];
    [self reconnect];
    [self showNotification];
}

# pragma mark - instance methods

- (id)initWithAccount:(ACAccount*)account {
    self = [super init];
    
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    self.account = account;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:self.account];
    
    return self;
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
    self.streamConnection = [self.twitter
                             getUserStreamDelimited:nil
                             stallWarnings:nil
                             includeMessagesFromFollowedAccounts:nil
                             includeReplies:nil
                             keywordsToTrack:self.searchTerm?@[self.searchTerm]:nil
                             locationBoundingBoxes:nil
                             progressBlock:^(id response) {
                                 if (response && [response isKindOfClass:[NSDictionary class]]) {
                                     Status *status = [[Status alloc] initWithDictionary:response];
                                      if (status && [self.delegate respondsToSelector:@selector(streamController:didReceivedTweet:)]) {
                                         [self.delegate streamController:self didReceivedTweet:status];
                                     }
                                 }
                             }
                             stallWarningBlock:^(NSString *code, NSString *message, NSUInteger percentFull) {
                                 NSLog(@"stall warning %@", message);
                             }
                             errorBlock:^(NSError *error) {
                                 NSLog(@"stream controller error: %@", error.description);
                                 [self reconnect];
                             }];
}

- (void)showNotification{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Stream Connecting";
    notification.informativeText = [NSString stringWithFormat:@"User: %@",self.account.username];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
