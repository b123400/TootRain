//
//  BRStreamHandler.h
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import <Foundation/Foundation.h>
#import "BRMastodonStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonStreamHandler : NSObject

@property (nonatomic, copy, nullable) void (^onStatus)(BRMastodonStatus *status);
@property (nonatomic, copy, nullable) void (^onError)(NSError *error);
@property (nonatomic, copy, nullable) void (^onConnected)();
@property (nonatomic, copy, nullable) void (^onDisconnected)();
@property (nonatomic, strong) NSURLSessionWebSocketTask *task;

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
