//
//  BRSlackClient.h
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import <Foundation/Foundation.h>
#import "BRSlackAccount.h"
#import "BRSlackStreamHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackClient : NSObject

+ (instancetype)shared;

- (void)receivedMagicLoginURL:(NSURL *)magicUrl
                   withWindow:(NSWindow *)window
              updatingAccount:(BRSlackAccount * _Nullable)updatingAccount
            completionHandler:(void (^)(BRSlackAccount* account, NSError *error))callback;
- (BRSlackStreamHandle *)streamMessageWithAccount:(BRSlackAccount *)account;

@end

NS_ASSUME_NONNULL_END
