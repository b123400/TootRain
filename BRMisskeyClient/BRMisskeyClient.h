//
//  BRMisskeyClient.h
//  TweetRain
//
//  Created by b123400 on 2022/12/22.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

#define MISSKEY_OAUTH_REDIRECT_DEST @"tootrain://misskeyoauth"

@interface BRMisskeyClient : NSObject

+ (instancetype)shared;

- (NSURL *)authURLWithHost:(NSURL *)host;

- (void)newAccountWithHost:(NSURL *)host
                 sessionId:(NSString *)sessionId
         completionHandler:(void (^_Nonnull)(BRMisskeyAccount * _Nullable account, NSError * _Nullable error))callback;

- (void)startStream;

@end

NS_ASSUME_NONNULL_END
