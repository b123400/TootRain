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
            self.user = [[BRMisskeyUser alloc] initWithJSONDictionary:dictionary[@"user"]];
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
    NSMutableString *text = [self.text mutableCopy];
    if (!self.emojis) {
        // Since misskey v13 the emojis field is gone from the response
        // Thank you @uakihir0 for this regex
        // https://github.com/uakihir0/SocialHub/commit/d6577a4fa535ba226fdf5e97bfbd1777d2048b17#diff-94352a4ed45b0f89971e682d1a08e80495c4dfa6685d5bde8b80dadf3f5a507bR867
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":([a-zA-Z0-9_]+(@[a-zA-Z0-9-.]+)?):" options:0 error:nil];
        NSArray<NSTextCheckingResult*> *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        NSLog(@"results %@", results);
        // Loop from back so replacing strings won't affect the range
        for (int i = results.count - 1; i >= 0; i--) {
            NSTextCheckingResult *r = results[i];
            NSRange range = [r rangeAtIndex:0];
            NSString *emojiToken = [[text substringWithRange:range] stringByReplacingOccurrencesOfString:@":" withString:@""]; // e.g. ":hello:" "hello@example.com"
            [text replaceCharactersInRange:range withString:[NSString stringWithFormat:@"<img src=\"%@\">", [self urlForEmojiToken:emojiToken].absoluteString]];
        }
    } else {
        for (BRMisskeyEmoji *emoji in self.emojis) {
            [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji.name]
                                  withString:[NSString stringWithFormat:@"<img src=\"%@\">", emoji.URL.absoluteString]
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

- (NSURL *)urlForEmojiToken:(NSString *)token {
    NSURL *url = [self.account urlForEmoji:token];
    if (url) return url;
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.account.hostName];
    [urlComponents setPath:[NSString stringWithFormat:@"/emoji/%@.webp", token]];
    return [urlComponents URL];
}

@end
