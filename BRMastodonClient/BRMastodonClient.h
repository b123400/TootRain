//
//  BRMastodonClient.h
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import <Foundation/Foundation.h>
#import "BRMastodonApp.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonClient : NSObject

+ (instancetype)shared;

- (void)registerAppFor:(NSString*)hostname completionHandler:(void (^)(BRMastodonApp * _Nullable app, NSError * _Nullable error))callback;

- (void)getAccessTokenWithApp:(BRMastodonApp *)app
                         code:(NSString *)code
            completionHandler:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
