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
    }
    return self;
}

@end
