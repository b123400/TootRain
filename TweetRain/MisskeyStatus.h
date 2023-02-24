//
//  MisskeyStatus.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "Status.h"
#import "BRMisskeyStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface MisskeyStatus : Status

@property (nonatomic, strong) BRMisskeyStatus *misskeyStatus;

- (id)initWithMisskeyStatus:(BRMisskeyStatus *)status;

@end

NS_ASSUME_NONNULL_END
