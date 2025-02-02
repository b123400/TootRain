//
//  IrcStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import "StreamHandle.h"
#import "IRC/BRIrcStreamHandle.h"
#import "DummyStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface IrcStreamHandle : StreamHandle

@property (nonatomic, copy, nullable) void (^onStatus)(DummyStatus *status);
@property (nonatomic, strong) BRIrcStreamHandle *handle;

- (instancetype)initWithHandle:(BRIrcStreamHandle *)handle;

@end

NS_ASSUME_NONNULL_END
