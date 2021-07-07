//
//  BRMastodonStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRMastodonStatus.h"

@implementation BRMastodonStatus

- (instancetype)initWithJSONDict:(NSDictionary *)dict account:(BRMastodonAccount *)account {
    if (self = [super init]) {
        self.account = account;
        self.user = [[BRMastodonUser alloc] initWithJSONDictionary:dict[@"account"]];
        self.statusID = dict[@"id"];
        self.createdAt = [[[NSISO8601DateFormatter alloc] init] dateFromString:dict[@"created_at"]];
        self.text = dict[@"content"];
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
    NSMutableString *text = [self.text mutableCopy];
    for (BRMastodonEmoji *emoji in self.emojis) {
        [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji.shortcode]
                              withString:[NSString stringWithFormat:@"<img src=\"%@\">", emoji.URL]
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, text.length)];
    }
    
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
    };
    return [[NSAttributedString alloc] initWithHTML:[text dataUsingEncoding:NSUTF8StringEncoding]
                                            options:options
                                 documentAttributes:nil];
}

@end
