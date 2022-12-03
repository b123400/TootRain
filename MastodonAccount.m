//
//  MastodonAccount.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "MastodonAccount.h"

@implementation MastodonAccount

- (instancetype)initWithMastodonAccount:(BRMastodonAccount *)account {
    if (self = [super init]) {
        self.mastodonAccount = account;
    }
    return self;
}

- (NSString *)identifier {
    return [self.mastodonAccount identifier];
}

- (NSString *)displayName {
    return [self.mastodonAccount displayName];
}

- (NSString *)shortDisplayName {
    return self.mastodonAccount.shortDisplayName;
}

- (void)deleteAccount {
    [self.mastodonAccount deleteAccount];
}

@end
