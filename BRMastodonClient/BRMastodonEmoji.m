//
//  BRMastodonEmoji.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "BRMastodonEmoji.h"

@implementation BRMastodonEmoji

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.shortcode = dict[@"shortcode"];
        self.staticURL = [NSURL URLWithString:dict[@"static_url"]];
        self.URL = [NSURL URLWithString:dict[@"url"]];
    }
    return self;
}

@end
