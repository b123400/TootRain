//
//  SlackStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Cocoa/Cocoa.h>
#import "StreamHandle.h"
#import "BRSlackStreamHandle.h"
#import "SlackStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlackStreamHandle : StreamHandle

@property (nonatomic, copy, nullable) void (^onMessage)(SlackStatus *message);
@property (nonatomic, strong) BRSlackStreamHandle *handle;

- (instancetype)initWithHandle:(BRSlackStreamHandle *)handle;

@end

NS_ASSUME_NONNULL_END
