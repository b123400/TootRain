//
//  BRMisskeyStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyStatus.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyStreamHandle : NSObject

@property (nonatomic, copy, nullable) void (^onStatus)(BRMisskeyStatus *status);
@property (nonatomic, copy, nullable) void (^onError)(NSError *error);
@property (nonatomic, copy, nullable) void (^onConnected)();
@property (nonatomic, copy, nullable) void (^onDisconnected)();
@property (nonatomic, strong) NSURLSessionWebSocketTask *task;
@property (nonatomic, strong) BRMisskeyAccount *account;

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
