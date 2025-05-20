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
        self.userID = user.userID;
        self.username = user.accountName;
        self.screenName = user.displayName;
        self.profileImageURL = user.profileImageURL;
        
        self.mastodonUser = user;
        // Make attributed string in init, so the images are loaded when status is init-ed
        // such that we can load the image in background
        self.attributedScreenName = self.mastodonUser.attributedScreenName;
    }
    return self;
}

@end
