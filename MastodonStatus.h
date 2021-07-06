//
//  MastodonStatus.h
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "Status.h"
#import "BRMastodonStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface MastodonStatus : Status

@property (nonatomic, strong) BRMastodonStatus *mastodonStatus;

- (id)initWithMastodonStatus:(BRMastodonStatus *)status;

@end

NS_ASSUME_NONNULL_END
