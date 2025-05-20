//
//  BRIrcStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import <Foundation/Foundation.h>
#import "IRCConnectionController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRIrcStreamHandle : NSObject<IRCConnectionControllerDelegate>

@property (nonatomic, strong) IRCConnectionController *cc;

@property (nonatomic, copy, nullable) void (^onMessage)(NSString *message);
//@property (nonatomic, copy, nullable) void (^onError)(NSError *error);
//@property (nonatomic, copy, nullable) void (^onConnected)();
//@property (nonatomic, copy, nullable) void (^onDisconnected)();

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
