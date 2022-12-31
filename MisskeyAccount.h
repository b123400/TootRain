//
//  MissAccount.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "Account.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface MisskeyAccount : Account

@property (nonatomic, strong) BRMisskeyAccount *misskeyAccount;

- (instancetype)initWithMisskeyAccount:(BRMisskeyAccount *)account;

@end

NS_ASSUME_NONNULL_END
