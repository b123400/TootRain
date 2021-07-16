//
//  SlackUser.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "User.h"
#import "BRSlackUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlackUser : User

@property (nonatomic, strong) BRSlackUser* slackUser;

- (instancetype)initWithSlackUser:(BRSlackUser *)user;

@end

NS_ASSUME_NONNULL_END
