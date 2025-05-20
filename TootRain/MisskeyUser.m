//
//  MisskeyUser.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "MisskeyUser.h"

@implementation MisskeyUser

- (instancetype)initWithMisskeyUser:(BRMisskeyUser *)user {
    if (self = [super init]) {
        self.userID = user.userID;
        self.username = user.username;
        self.screenName = user.displayName;
        self.profileImageURL = user.profileImageURL;
        
        self.misskeyUser = user;
        // Make attributed string in init, so the images are loaded when status is init-ed
        // such that we can load the image in background
        self.attributedScreenName = self.misskeyUser.attributedScreenName;
    }
    return self;
}

@end
