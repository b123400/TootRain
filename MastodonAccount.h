//
//  MastodonAccount.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Cocoa/Cocoa.h>
#import "Account.h"
#import "BRMastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface MastodonAccount : Account

@property (nonatomic, strong) BRMastodonAccount *mastodonAccount;

- (instancetype)initWithMastodonAccount:(BRMastodonAccount *)account;

@end

NS_ASSUME_NONNULL_END
