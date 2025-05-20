//
//  MisskeyStreamHandle.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "StreamHandle.h"
#import "BRMisskeyStatus.h"
#import "BRMisskeyStreamHandle.h"
#import "MisskeyStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface MisskeyStreamHandle : StreamHandle

@property (nonatomic, copy, nullable) void (^onStatus)(MisskeyStatus *status);
@property (nonatomic, strong) BRMisskeyStreamHandle *handle;

- (instancetype)initWithHandle:(BRMisskeyStreamHandle *)handle;

@end

NS_ASSUME_NONNULL_END
