//
//  BRSlackStreamHandler.h
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import <Foundation/Foundation.h>
#import "BRSlackMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackStreamHandle : NSObject

@property (nonatomic, copy, nullable) void (^onMessage)(BRSlackMessage *message);
@property (nonatomic, copy, nullable) void (^onError)(NSError *error);
@property (nonatomic, copy, nullable) void (^onConnected)();
@property (nonatomic, copy, nullable) void (^onDisconnected)();
@property (nonatomic, strong) NSURLSessionWebSocketTask *task;

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
