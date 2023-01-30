//
//  MastodonUser.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "MastodonUser.h"

@implementation MastodonUser

- (instancetype)initWithMastodonUser:(BRMastodonUser *)user {
    if (self = [super init]) {
        self.username = user.accountName;
        self.screenName = user.displayName;
        self.profileImageURL = user.profileImageURL;
        
        self.mastodonUser = user;
    }
    return self;
}

@end
