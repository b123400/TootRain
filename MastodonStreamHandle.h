//
//  MastodonStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Cocoa/Cocoa.h>
#import "StreamHandle.h"
#import "MastodonStatus.h"
#import "BRMastodonStreamHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface MastodonStreamHandle : StreamHandle

@property (nonatomic, copy, nullable) void (^onStatus)(MastodonStatus *status);
@property (nonatomic, strong) BRMastodonStreamHandle *handle;

- (instancetype)initWithHandle:(BRMastodonStreamHandle *)handle;

@end

NS_ASSUME_NONNULL_END
