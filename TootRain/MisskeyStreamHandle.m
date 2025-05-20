//
//  MisskeyStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "MisskeyStreamHandle.h"

@implementation MisskeyStreamHandle

- (instancetype)initWithHandle:(BRMisskeyStreamHandle *)handle {
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
        handle.onStatus = ^(BRMisskeyStatus * _Nonnull status) {
            if (_self.onStatus) {
                _self.onStatus([[MisskeyStatus alloc] initWithMisskeyStatus:status]);
            }
        };
    }
    return self;
}

- (void)disconnect {
    [self.handle disconnect];
}

@end
