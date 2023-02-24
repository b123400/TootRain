//
//  BRSlackMessage.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "BRSlackMessage.h"

@implementation BRSlackMessage

- (instancetype)initWithJSONDict:(NSDictionary *)dict user:(BRSlackUser *)user account:(BRSlackAccount *)account {
    if (self = [super init]) {
        self.account = account;
        self.user = user;
        self.text = dict[@"text"];
        
        self.emojis = [self findEmojiFromNestedObj:dict[@"blocks"]];
    }
    return self;
}

- (NSArray<NSString*> *)findEmojiFromNestedObj:(id)obj {
    NSMutableArray *emojis = [NSMutableArray array];
    if ([obj isKindOfClass:[NSArray class]]) {
        for (id o in (NSArray*)obj) {
            [emojis addObjectsFromArray:[self findEmojiFromNestedObj:o]];
        }
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        if ([[obj objectForKey:@"type"] isKindOfClass:[NSString class]] && [[obj objectForKey:@"type"] isEqualTo:@"emoji"]) {
            [emojis addObject:obj[@"name"]];
        } else {
            for (id o in [(NSDictionary*)obj allValues]) {
                [emojis addObjectsFromArray:[self findEmojiFromNestedObj:o]];
            }
        }
    }
    return emojis;
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
    NSMutableArray *allEmojis = [self.emojis mutableCopy];
    [allEmojis addObjectsFromArray:@[@"skin-tone-2", @"skin-tone-3", @"skin-tone-4", @"skin-tone-5", @"skin-tone-6"]];
    for (NSString *emoji in allEmojis) {
        NSString *emojiURL = [self.account urlForEmoji:emoji];
        if (emojiURL) {
            [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji]
                                  withString:[NSString stringWithFormat:@"<img src=\"%@\">", emojiURL]
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, text.length)];
        } else if ([[BRSlackMessage standardEmojiDict] objectForKey:emoji]) {
            [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji]
                                  withString:[[BRSlackMessage standardEmojiDict] objectForKey:emoji]
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, text.length)];
        }
    }
    
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
    };
    return [[NSAttributedString alloc] initWithHTML:[text dataUsingEncoding:NSUTF8StringEncoding]
                                            options:options
                                 documentAttributes:nil];
}

+ (NSDictionary *)standardEmojiDict {
    static NSDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"]];
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
    });
    return dict;
}

@end
