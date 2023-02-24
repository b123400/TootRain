//
//  SlackUser.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "SlackUser.h"

@implementation SlackUser

- (instancetype)initWithSlackUser:(BRSlackUser *)user {
    if (self = [super init]) {
        self.username = user.username;
        self.screenName = user.displayName;
        self.profileImageURL = user.profileImageURL;
        
        self.slackUser = user;
    }
    return self;
}

@end
