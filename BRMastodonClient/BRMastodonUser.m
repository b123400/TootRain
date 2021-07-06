//
//  BRMastodonUser.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRMastodonUser.h"

@implementation BRMastodonUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.username = dictionary[@"username"];
        self.accountName = dictionary[@"acct"];
        self.displayName = dictionary[@"display_name"];
        self.userID = dictionary[@"id"];
        self.note = dictionary[@"note"];
        self.profileImageURL = [NSURL URLWithString:dictionary[@"avatar"]];
        self.URL = [NSURL URLWithString:dictionary[@"url"]];
    }
    return self;
}

@end
