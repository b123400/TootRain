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
    }
    return self;
}

@end
