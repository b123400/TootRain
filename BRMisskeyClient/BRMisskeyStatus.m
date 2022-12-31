//
//  BRMisskeyStatus.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "BRMisskeyStatus.h"

@implementation BRMisskeyStatus

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        if ([dictionary[@"user"] isKindOfClass:[NSDictionary class]]) {
            self.user = [[BRMisskeyUser alloc] initWithJSONDictionary:dictionary[@"user"]];
        }
        if ([dictionary[@"emojis"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *emojis = [NSMutableArray array];
            for (NSDictionary *emojiDict in dictionary[@"emojis"]) {
                [emojis addObject:[[BRMisskeyEmoji alloc] initWithJSONDictionary:emojiDict]];
            }
            self.emojis = emojis;
        } else {
            self.emojis = @[];
        }
        
        self.statusID = dictionary[@"id"];
        self.text = [dictionary[@"text"] isKindOfClass:[NSString class]] ? dictionary[@"text"] : @"";
        self.contentWarning = [dictionary[@"cw"] isKindOfClass:[NSString class]] ? dictionary[@"cw"] : @"";
        
        if ([dictionary[@"renote"] isKindOfClass:[NSDictionary class]]) {
            self.renote = [[BRMisskeyStatus alloc] initWithJSONDictionary:dictionary[@"renote"]];
        }
    }
    return self;
}

- (NSAttributedString *)attributedStringWithEmojisReplaced {
    NSMutableString *text = [self.text mutableCopy];
    for (BRMisskeyEmoji *emoji in self.emojis) {
        [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji.name]
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
