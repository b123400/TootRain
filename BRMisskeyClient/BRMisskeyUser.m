//
//  BRMisskeyUser.m
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import "BRMisskeyUser.h"

@implementation BRMisskeyUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMisskeyAccount * _Nullable)account {
    if (self = [super init]) {
        self.account = account;
        self.username = dictionary[@"username"];
        self.displayName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : self.username;
        self.userID = dictionary[@"id"];
        self.host = dictionary[@"host"];
        if ([self.host isKindOfClass:[NSNull class]]) {
            self.host = nil;
        }
        self.profileImageURL = [NSURL URLWithString:dictionary[@"avatarUrl"]];
    }
    return self;
}

- (NSAttributedString *)attributedScreenName {
    return [self.account attributedString:self.displayName
                                 withHost:self.host
                           emojisReplaced:nil];
}

@end
