//
//  StreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamHandle : NSObject

@property (nonatomic, copy, nullable) void (^onError)(NSError *error);
@property (nonatomic, copy, nullable) void (^onConnected)();
@property (nonatomic, copy, nullable) void (^onDisconnected)();

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
