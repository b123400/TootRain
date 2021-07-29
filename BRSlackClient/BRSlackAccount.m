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
        self.channelId = dict[@"channelId"];
        self.channelName = dict[@"chanelName"];
        self.token = dict[@"token"];
        self.responseHeaderWithCookies = dict[@"headers"];
    }
    return self;
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *accounts = [(NSDictionary*)[defaults objectForKey:@"BRSlackAccount"] mutableCopy] ?: [NSMutableDictionary dictionary];
    accounts[self.uuid] = [self dictionaryRepresentation];
    [defaults setObject:accounts forKey:@"BRSlackAccount"];
    [defaults synchronize];
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
        @"channelId": self.channelId,
        @"chanelName": self.channelName,
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
