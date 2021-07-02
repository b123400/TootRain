//
//  BRMastodonAccount.h
//  TweetRain
//
//  Created by b123400 on 2021/07/02.
//

#import <Foundation/Foundation.h>
#import "BRMastodonApp.h"
#import "BRMastodonOAuthResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonAccount : NSObject

@property (nonatomic, strong) BRMastodonApp *app;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic, strong, nullable) NSString *refreshToken;
@property (nonatomic, strong, nullable) NSDate *expires;

+ (NSDictionary<NSString *, NSArray<BRMastodonAccount*>*> *)allAccounts;

+ (instancetype)accountWithApp:(BRMastodonApp *)app accountId:(NSString *)accountId;

- (instancetype)initWithApp:(BRMastodonApp *)app
                  accountId:(NSString *)accountId
                        url:(NSString *)url
                oauthResult:(BRMastodonOAuthResult *)oauthResult;

- (void)save;

- (void)renew:(BRMastodonOAuthResult *)oauthResult;
- (void)deleteAccount;

@end

NS_ASSUME_NONNULL_END
