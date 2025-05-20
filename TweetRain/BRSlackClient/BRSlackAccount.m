//
//  BRSlackAccount.m
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import "BRSlackAccount.h"

@implementation BRSlackAccount

+ (NSArray *)allAccounts {
    NSMutableArray *result = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *accounts = (NSDictionary*)[defaults objectForKey:@"BRSlackAccount"];
    if (!accounts) {
        return result;
    }
    for (NSString *uuid in accounts) {
        [result addObject:[[BRSlackAccount alloc] initWithDictionary:accounts[uuid]]];
    }
    return result;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.uuid = dict[@"uuid"];
        self.url = [NSURL URLWithString:dict[@"url"]];
        self.accountId = dict[@"accountId"];
        self.teamId = dict[@"teamId"];
        self.teamName = dict[@"teamName"];
        if (dict[@"channelIds"]) {
            self.channelIds = dict[@"channelIds"];
        } else if (dict[@"channelId"]) {
            self.channelIds = @[dict[@"channelId"]];
        }
        if (dict[@"chanelNames"]) {
            self.channelNames = dict[@"chanelNames"];
        } else if (dict[@"chanelName"]) {
            self.channelNames = @[dict[@"chanelName"]];
        }
        self.threadId = dict[@"threadId"];
        self.token = dict[@"token"];
        self.responseHeaderWithCookies = dict[@"headers"];
    }
    return self;
}

- (NSString *)identifier {
    return self.uuid;
}

- (NSString *)displayName {
    NSString *channelName = [self.channelNames componentsJoinedByString:@", "];
    if (channelName.length > 30) {
        channelName = [NSString stringWithFormat:@"#%@...", [channelName substringToIndex:29]];
    } else if (self.channelNames.count) {
        channelName = [NSString stringWithFormat:@"#%@", channelName];
    }
    NSString *threadString = self.threadId.length > 0 ? @"Thread" : @"";
    return [NSString stringWithFormat:@"(Slack) %@ %@ %@",
            self.teamName,
            channelName,
            threadString];
}

- (NSString *)shortDisplayName {
    return self.teamName;
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *accounts = [(NSDictionary*)[defaults objectForKey:@"BRSlackAccount"] mutableCopy] ?: [NSMutableDictionary dictionary];
    accounts[self.uuid] = [self dictionaryRepresentation];
    [defaults setObject:accounts forKey:@"BRSlackAccount"];
    [defaults synchronize];
}

- (NSImage *)serviceImage {
    return [NSImage imageNamed:@"Slack"];
}

- (void)deleteAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *accounts = [(NSDictionary*)[defaults objectForKey:@"BRSlackAccount"] mutableCopy] ?: [NSMutableDictionary dictionary];
    [accounts removeObjectForKey:self.uuid];
    [defaults setObject:accounts forKey:@"BRSlackAccount"];
    [defaults synchronize];
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"uuid": self.uuid,
        @"url": self.url.absoluteString,
        @"accountId": self.accountId,
        @"teamId": self.teamId,
        @"teamName": self.teamName,
        @"channelIds": self.channelIds,
        @"chanelNames": self.channelNames,
        @"threadId": self.threadId ?: @"",
        @"token": self.token,
        @"headers": self.responseHeaderWithCookies,
    };
}

- (NSDictionary *)headersForRequest {
    return [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookie cookiesWithResponseHeaderFields:self.responseHeaderWithCookies forURL:[NSURL URLWithString:@"https://app.slack.com/api/auth.loginMagicBulk"]]];
}

+ (NSMutableDictionary *)accountIdToEmojiDicts {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary dictionary];
    });
    return dict;
}

- (void)setEmojiDict:(NSDictionary<NSString *, NSString *> *)dict {
    [[BRSlackAccount accountIdToEmojiDicts] setObject:dict forKey:self.uuid];
}

- (NSString *)urlForEmoji:(NSString *)emoji {
    NSDictionary *emojiDict = [[BRSlackAccount accountIdToEmojiDicts] objectForKey:self.uuid];
    return emojiDict[emoji];
}

@end
