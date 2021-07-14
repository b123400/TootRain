//
//  BRMastodonClient.h
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import <Foundation/Foundation.h>
#import "BRMastodonApp.h"
#import "BRMastodonAccount.h"
#import "BRMastodonOAuthResult.h"
#import "BRMastodonStatus.h"
#import "BRMastodonStreamHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonClient : NSObject

+ (instancetype)shared;

- (void)registerAppFor:(NSString*)hostname completionHandler:(void (^)(BRMastodonApp * _Nullable app, NSError * _Nullable error))callback;

- (void)getAccessTokenWithApp:(BRMastodonApp *)app
                         code:(NSString *)code
            completionHandler:(void (^)(BRMastodonOAuthResult * _Nullable result, NSError * _Nullable error))callback;

- (void)verifyAccountWithApp:(BRMastodonApp *)app
                 oauthResult:(BRMastodonOAuthResult *)oauthResult
           completionHandler:(void (^)(BRMastodonAccount * _Nullable account, NSError * _Nullable error))callback;

- (void)refreshAccessTokenWithApp:(BRMastodonApp *)app
                     refreshToken:(NSString *)refreshToken
                completionHandler:(void (^)(BRMastodonOAuthResult * _Nullable result, NSError * _Nullable error))callback;

- (BRMastodonStreamHandler *)streamingStatusesWithAccount:(BRMastodonAccount *)account;

- (void)replyToStatus:(BRMastodonStatus *)status
           withText:(NSString *)text
  completionHandler:(void (^_Nonnull)(BRMastodonStatus * _Nullable status, NSError * _Nullable error))callback;

- (void)bookmarkStatus:(BRMastodonStatus *)status
     completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (void)favouriteStatus:(BRMastodonStatus *)status
      completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (void)reblogStatus:(BRMastodonStatus *)status
   completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
