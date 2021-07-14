//
//  BRSlackClient.h
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import <Foundation/Foundation.h>
#import "BRSlackAccount.h"
#import "BRSlackStreamHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackClient : NSObject

+ (instancetype)shared;

- (void)receivedMagicLoginURL:(NSURL *)magicUrl completionHandler:(void (^)(BRSlackAccount* account, NSError *error))callback;
- (BRSlackStreamHandler *)streamMessageWithAccount:(BRSlackAccount *)account;

@end

NS_ASSUME_NONNULL_END
