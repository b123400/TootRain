//
//  BRMisskeyUser.m
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import "BRMisskeyUser.h"

@implementation BRMisskeyUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.username = dictionary[@"username"];
        self.displayName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : self.username;
        self.userID = dictionary[@"id"];
        self.profileImageURL = [NSURL URLWithString:dictionary[@"avatarUrl"]];
    }
    return self;
}

@end
