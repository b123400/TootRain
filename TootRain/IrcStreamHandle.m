//
//  IrcStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import "IrcStreamHandle.h"

@implementation IrcStreamHandle

- (instancetype)initWithHandle:(BRIrcStreamHandle *)handle {
    if (self = [super init]) {
        self.handle = handle;
        
        handle.onMessage = ^(NSString * _Nonnull message) {
            if (self.onStatus) {
                DummyStatus *status = [[DummyStatus alloc] init];
                status.text = message;
                self.onStatus(status);
            }
        };
    }
    return self;
}

- (void)disconnect {
    [self.handle disconnect];
}

@end
