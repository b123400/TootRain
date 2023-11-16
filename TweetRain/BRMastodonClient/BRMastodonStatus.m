//
//  BRMastodonStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRMastodonStatus.h"
#import "BRMastodonClient.h"

@implementation BRMastodonStatus

- (instancetype)initWithJSONDict:(NSDictionary *)dict account:(BRMastodonAccount *)account {
    if (self = [super init]) {
        NSDictionary *reblogDict = dict[@"reblog"];
        if ([reblogDict isKindOfClass:[NSDictionary class]]) {
            self = [self initWithJSONDict:reblogDict account:account];
            self.rebloggedByUser = [[BRMastodonUser alloc] initWithJSONDictionary:dict[@"account"]
                                                                          account:account];
            return self;
        }
        
        self.account = account;
        self.user = [[BRMastodonUser alloc] initWithJSONDictionary:dict[@"account"]
                                                           account:account];
        self.statusID = dict[@"id"];
        self.createdAt = [[[NSISO8601DateFormatter alloc] init] dateFromString:dict[@"created_at"]];
        self.text = dict[@"content"];
        self.spoiler = dict[@"spoiler_text"];
        self.favourited = [dict[@"favourited"] boolValue];
        self.bookmarked = [dict[@"bookmarked"] boolValue];
        self.reblogged = [dict[@"reblogged"] boolValue];
        
        if (!dict[@"emojis"]) {
            self.emojis = @[];
        } else {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *emojiDict in dict[@"emojis"]) {
                [arr addObject:[[BRMastodonEmoji alloc] initWithJSONDictionary:emojiDict]];
            }
            self.emojis = arr;
        }
    }
    return self;
}

- (NSAttributedString *)attributedString {
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
    };
    return [[NSAttributedString alloc] initWithHTML:[self.text dataUsingEncoding:NSUTF8StringEncoding]
                                            options:options
                                 documentAttributes:nil];
}

- (NSAttributedString *)attributedStringWithEmojisReplaced {
    return [BRMastodonClient attributedString:self.text withEmojisReplaced:self.emojis];
}

- (NSAttributedString *)attributedSpoilerWithEmojisReplaced {
    return [BRMastodonClient attributedString:self.spoiler withEmojisReplaced:self.emojis];
}

@end
