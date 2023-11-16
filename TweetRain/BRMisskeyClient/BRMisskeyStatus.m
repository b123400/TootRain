//
//  BRMisskeyStatus.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "BRMisskeyStatus.h"

@implementation BRMisskeyStatus

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMisskeyAccount *)account {
    if (self = [super init]) {
        self.account = account;
        if ([dictionary[@"user"] isKindOfClass:[NSDictionary class]]) {
            self.user = [[BRMisskeyUser alloc] initWithJSONDictionary:dictionary[@"user"] account:account];
        }
        if ([dictionary[@"emojis"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *emojis = [NSMutableArray array];
            for (NSDictionary *emojiDict in dictionary[@"emojis"]) {
                [emojis addObject:[[BRMisskeyEmoji alloc] initWithJSONDictionary:emojiDict]];
            }
            self.emojis = emojis;
        } else {
            self.emojis = nil;
        }
        
        self.statusID = dictionary[@"id"];
        self.text = [dictionary[@"text"] isKindOfClass:[NSString class]] ? dictionary[@"text"] : @"";
        self.contentWarning = [dictionary[@"cw"] isKindOfClass:[NSString class]] ? dictionary[@"cw"] : @"";
        
        if ([dictionary[@"renote"] isKindOfClass:[NSDictionary class]]) {
            self.renote = [[BRMisskeyStatus alloc] initWithJSONDictionary:dictionary[@"renote"] account:account];
        }
    }
    return self;
}

- (NSAttributedString *)attributedStringWithEmojisReplaced {
    return [self.account attributedString:self.text
                                 withHost:self.user.host
                           emojisReplaced:self.emojis];
}

- (NSAttributedString *)attributedContentWarningWithEmojisReplaced {
    return [self.account attributedString:self.contentWarning
                                 withHost:self.user.host
                           emojisReplaced:self.emojis];
}

@end
