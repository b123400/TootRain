//
//  SlackStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "SlackStreamHandle.h"
#import "BRSlackMessage.h"

@implementation SlackStreamHandle

- (instancetype)initWithHandle:(BRSlackStreamHandle *)handle {
    if (self = [super init]) {
        self.handle = handle;
        typeof(self) __weak _self = self;
        handle.onConnected = ^{
            if (_self.onConnected) {
                _self.onConnected();
            }
        };
        handle.onDisconnected = ^{
            if (_self.onDisconnected) {
                _self.onDisconnected();
            }
        };
        handle.onError = ^(NSError * _Nonnull error) {
            if (_self.onError) {
                _self.onError(error);
            }
        };
        handle.onMessage = ^(BRSlackMessage * _Nonnull message) {
            if (_self.onMessage) {
                _self.onMessage([[SlackStatus alloc] initWithSlackStatus:message]);
            }
        };
    }
    return self;
}

- (void)disconnect {
    [self.handle disconnect];
}

@end
