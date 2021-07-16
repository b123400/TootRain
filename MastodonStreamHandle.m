//
//  MastodonStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "MastodonStreamHandle.h"
#import "BRMastodonStatus.h"

@implementation MastodonStreamHandle

- (instancetype)initWithHandle:(BRMastodonStreamHandle *)handle {
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
        handle.onStatus = ^(BRMastodonStatus * _Nonnull status) {
            if (_self.onStatus) {
                _self.onStatus([[MastodonStatus alloc] initWithMastodonStatus:status]);
            }
        };
    }
    return self;
}

- (void)disconnect {
    [self.handle disconnect];
}

@end
