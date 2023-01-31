//
//  BRMastodonUser.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRMastodonUser.h"
#import "BRMastodonClient.h"

@implementation BRMastodonUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMastodonAccount *)account {
    if (self = [super init]) {
        self.account = account;
        self.username = dictionary[@"username"];
        self.accountName = dictionary[@"acct"];
        self.displayName = dictionary[@"display_name"];
        self.userID = dictionary[@"id"];
        self.note = dictionary[@"note"];
        self.profileImageURL = [NSURL URLWithString:dictionary[@"avatar"]];
        self.URL = [NSURL URLWithString:dictionary[@"url"]];
        
        if (!dictionary[@"emojis"]) {
            self.emojis = @[];
        } else {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *emojiDict in dictionary[@"emojis"]) {
                [arr addObject:[[BRMastodonEmoji alloc] initWithJSONDictionary:emojiDict]];
            }
            self.emojis = arr;
        }
    }
    return self;
}

- (NSAttributedString *)attributedScreenName {
    return [BRMastodonClient attributedString:self.displayName withEmojisReplaced:self.emojis];
}

@end
