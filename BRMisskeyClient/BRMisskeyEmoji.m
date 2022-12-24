//
//  BRMisskeyEmoji.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "BRMisskeyEmoji.h"

@implementation BRMisskeyEmoji

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.name = dictionary[@"name"];
        self.URL = [NSURL URLWithString:dictionary[@"url"]];
    }
    return self;
}

@end
