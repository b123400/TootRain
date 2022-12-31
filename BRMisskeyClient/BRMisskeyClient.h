//
//  BRMisskeyClient.h
//  TweetRain
//
//  Created by b123400 on 2022/12/22.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyAccount.h"
#import "BRMisskeyStreamHandle.h"

NS_ASSUME_NONNULL_BEGIN

#define MISSKEY_OAUTH_REDIRECT_DEST @"tootrain://misskeyoauth"

@interface BRMisskeyClient : NSObject

+ (instancetype)shared;

- (NSURL *)authURLWithHost:(NSURL *)host;

- (void)newAccountWithHost:(NSURL *)host
                 sessionId:(NSString *)sessionId
         completionHandler:(void (^_Nonnull)(BRMisskeyAccount * _Nullable account, NSError * _Nullable error))callback;

- (BRMisskeyStreamHandle *)streamStatusWithAccount:(BRMisskeyAccount *)account;

- (void)getAntennaSourcesWithAccount:(BRMisskeyAccount *)account
                   completionHandler:(void (^_Nonnull)(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error))callback;

- (void)getUserListSourcesWithAccount:(BRMisskeyAccount *)account
                    completionHandler:(void (^_Nonnull)(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error))callback;

- (void)getChannelSourcesWithAccount:(BRMisskeyAccount *)account
                   completionHandler:(void (^_Nonnull)(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
