//
//  MastodonUser.h
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "User.h"
#import "BRMastodonUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MastodonUser : User

@property (nonatomic, strong) BRMastodonUser* mastodonUser;

- (instancetype)initWithMastodonUser:(BRMastodonUser *)user;

@end

NS_ASSUME_NONNULL_END
