//
//  Account.m
//  Smarkin
//
//  Created by b123400 on 07/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize username,userID,screenName,otherInfos,profileImageURL,description;

- (instancetype)initWithMastodonUser:(BRMastodonUser *)user {
    if (self = [super init]) {
        self.userID = user.userID;
        self.username = user.accountName;
        self.screenName = user.displayName;
        self.profileImageURL = user.profileImageURL;
        self.description = user.note;
    }
    return self;
}

@end
