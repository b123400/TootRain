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

typedef enum : NSUInteger {
    BRMastodonStreamSourcePublic,
    BRMastodonStreamSourcePublicLocal,
    BRMastodonStreamSourcePublicRemote,
    BRMastodonStreamSourceHashtag,
    BRMastodonStreamSourceHashtagLocal,
    BRMastodonStreamSourceUser,
    BRMastodonStreamSourceUserNotification,
    BRMastodonStreamSourceList,
    BRMastodonStreamSourceDirect,
} BRMastodonStreamSource;

@interface BRMastodonAccount : NSObject

@property (nonatomic, strong) BRMastodonApp *app;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic, strong, nullable) NSString *refreshToken;
@property (nonatomic, strong, nullable) NSDate *expires;
@property (nonatomic, assign) BRMastodonStreamSource source;
@property (nonatomic, strong) NSString *sourceHashtag;
@property (nonatomic, strong) NSString *sourceListId;
@property (nonatomic, strong) NSString *sourceListName;

+ (NSArray<BRMastodonAccount*> *)allAccounts;

+ (instancetype)accountWithApp:(BRMastodonApp *)app accountId:(NSString *)accountId;

- (instancetype)initWithApp:(BRMastodonApp *)app
                  accountId:(NSString *)accountId
                        url:(NSString *)url
                displayName:(NSString *)displayName
                oauthResult:(BRMastodonOAuthResult *)oauthResult;

- (void)save;

- (void)renew:(BRMastodonOAuthResult *)oauthResult;
- (void)deleteAccount;

- (NSString *)identifier;
- (NSString *)shortDisplayName;
- (NSString *)displayNameForStreamSource;

@end

NS_ASSUME_NONNULL_END
